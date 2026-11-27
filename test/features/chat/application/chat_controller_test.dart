import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/error/api_issue.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/platform/location/location_access.dart';
import 'package:wasli_customer/core/platform/location/location_providers.dart';
import 'package:wasli_customer/core/platform/location/location_unavailable_exception.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/features/chat/application/chat_controller.dart';
import 'package:wasli_customer/features/chat/application/chat_providers.dart';
import 'package:wasli_customer/features/chat/application/chat_state.dart';
import 'package:wasli_customer/features/chat/domain/chat_action.dart';
import 'package:wasli_customer/features/chat/domain/chat_snapshot.dart';
import 'package:wasli_customer/features/chat/domain/chat_step.dart';
import 'package:wasli_customer/features/server_config/application/server_config_providers.dart';

import '../../../support/fake_chat_repository.dart';
import '../../../support/fake_location_service.dart';

const _interval = Duration(seconds: 3);

/// The controller under test with everything around it replaced: the server, the clock, the ids and the location.
class _Harness {
  new({FakeChatRepository? repository, FakeLocationService? location})
    : repository = repository ?? FakeChatRepository(),
      location = location ?? FakeLocationService() {
    container = ProviderContainer(
      overrides: [
        chatRepositoryProvider.overrideWithValue(this.repository),
        locationServiceProvider.overrideWithValue(this.location),
        clockProvider.overrideWithValue(() => now),
        pollIntervalProvider.overrideWithValue(_interval),
        messageIdProvider.overrideWithValue(() => 'id-${++_ids}'),
      ],
    );
    container.listen(chatControllerProvider('demo-cafe'), (previous, next) {});
  }

  final FakeChatRepository repository;
  final FakeLocationService location;
  late final ProviderContainer container;
  DateTime now = DateTime.utc(2026, 11, 27, 9);
  int _ids = 0;

  ChatController get controller => container.read(chatControllerProvider('demo-cafe').notifier);

  AsyncValue<ChatState> get async => container.read(chatControllerProvider('demo-cafe'));

  ChatState get state => async.requireValue;

  void dispose() => container.dispose();
}

Future<void> _run(
  WidgetTester tester,
  Future<void> Function(_Harness h) body, {
  FakeChatRepository? repository,
  FakeLocationService? location,
}) async {
  final harness = _Harness(repository: repository, location: location);
  try {
    await tester.pump(); // the conversation opens
    await body(harness);
  } finally {
    harness.dispose();
  }
}

Future<void> _wait(WidgetTester tester, Duration duration) => tester.pump(duration);

Failure _conflict(String code) => ConflictFailure([ApiIssue(code: code)]);

void main() {
  group('opening', () {
    testWidgets('opens the conversation in the app language and shows its messages', (tester) async {
      await _run(tester, (h) async {
        expect(h.repository.calls, ['open(false,en)']);
        expect(h.state.messages.map((m) => m.text), ['Welcome to Demo Cafe.', 'What would you like to order?']);
        expect(h.state.conversation.step, ChatStep.ordering);
        expect(h.state.outgoing, isEmpty);
      });
    });

    testWidgets('a failed open is an error, and invalidating it opens again', (tester) async {
      final repository = FakeChatRepository()
        ..onOpen = (_) async => throw const NetworkFailure(NetworkFailureKind.offline);
      await _run(tester, repository: repository, (h) async {
        expect(h.async.hasError, isTrue);

        repository.onOpen = null;
        h.container.invalidate(chatControllerProvider('demo-cafe'));
        await h.container.read(chatControllerProvider('demo-cafe').future);

        expect(h.async.hasValue, isTrue);
      });
    });
  });

  group('polling', () {
    testWidgets('asks for what came after the last message every interval and merges it by seq', (tester) async {
      await _run(tester, (h) async {
        h.repository.append([botText(3, 'Anything else?')]);

        await _wait(tester, _interval);

        expect(h.repository.calls, ['open(false,en)', 'messagesAfter(2)']);
        expect(h.state.messages.map((m) => m.seq), [1, 2, 3]);

        await _wait(tester, _interval);
        expect(h.repository.calls.last, 'messagesAfter(3)');
        expect(h.state.messages, hasLength(3), reason: 'nothing is added twice');
      });
    });

    testWidgets('takes the conversation as it is now: a new step and the order', (tester) async {
      await _run(tester, (h) async {
        h.repository.conversation = demoConversation(step: ChatStep.placed);

        await _wait(tester, _interval);

        expect(h.state.conversation.step, ChatStep.placed);
      });
    });

    testWidgets('does not ask while the chat is hidden, and asks at once when it is visible again', (tester) async {
      await _run(tester, (h) async {
        h.controller.setVisible(visible: false);
        await _wait(tester, const Duration(seconds: 30));
        expect(h.repository.calls, ['open(false,en)']);

        h.controller.setVisible(visible: true);
        await _wait(tester, Duration.zero);
        await _wait(tester, Duration.zero);
        expect(h.repository.calls.last, 'messagesAfter(2)');
      });
    });

    testWidgets('stops 10 minutes after the last message, and starts again when the customer returns', (tester) async {
      await _run(tester, (h) async {
        h.now = h.now.add(chatIdleTimeout + const Duration(seconds: 1));
        await _wait(tester, _interval);
        final asked = h.repository.calls.length;
        await _wait(tester, const Duration(seconds: 30));

        expect(h.repository.calls, hasLength(asked), reason: 'idle: no more questions');

        h.controller.setVisible(visible: true);
        await _wait(tester, Duration.zero);
        await _wait(tester, Duration.zero);
        expect(h.repository.calls.length, greaterThan(asked));
      });
    });

    testWidgets('a message that arrives counts as activity', (tester) async {
      await _run(tester, (h) async {
        h.now = h.now.add(chatIdleTimeout - const Duration(seconds: 1));
        h.repository.append([botText(3, 'Still here')]);
        await _wait(tester, _interval);
        h.now = h.now.add(const Duration(minutes: 9));

        await _wait(tester, _interval);

        expect(h.repository.calls.where((c) => c.startsWith('messagesAfter')).length, 2);
      });
    });

    testWidgets('a poll that fails keeps the chat on screen and tries again later', (tester) async {
      await _run(tester, (h) async {
        var failures = 1;
        h.repository.onMessagesAfter = (after) async {
          if (failures-- > 0) {
            throw const ThrottledFailure(retryAfter: Duration(seconds: 10));
          }
          return ChatSnapshot(conversation: h.repository.conversation, messages: [botText(3, 'Back')]);
        };

        await _wait(tester, _interval);
        expect(h.state.messages, hasLength(2));
        await _wait(tester, const Duration(seconds: 10));

        expect(h.state.messages, hasLength(3));
      });
    });

    testWidgets('stops when the controller is disposed', (tester) async {
      final harness = _Harness();
      await tester.pump();
      harness.dispose();
      final asked = harness.repository.calls.length;

      await _wait(tester, const Duration(minutes: 1));

      expect(harness.repository.calls, hasLength(asked));
    });
  });

  group('sending text', () {
    testWidgets("shows the message at once, then the server's own message and reply, once each", (tester) async {
      final gate = Completer<void>();
      final repository = FakeChatRepository();
      final stored = repository.onSendText;
      expect(stored, isNull);
      await _run(tester, repository: repository, (h) async {
        repository.onSendText = (id, text) async {
          await gate.future;
          return repository.append([customerText(3, text), botText(4, 'Got it: $text')]);
        };

        final sending = h.controller.sendText('  two lattes  ');
        await tester.pump();

        expect(h.state.outgoing.single.label, 'two lattes');
        expect(h.state.outgoing.single.failed, isFalse);
        expect(h.state.messages, hasLength(2));

        gate.complete();
        await sending;

        expect(h.state.outgoing, isEmpty);
        expect(h.state.messages.map((m) => m.text), [
          'Welcome to Demo Cafe.',
          'What would you like to order?',
          'two lattes',
          'Got it: two lattes',
        ]);
        expect(repository.calls.last, 'text(id-1: two lattes)');
      });
    });

    testWidgets('refuses blank text and text over 500 code points, and counts emoji as one', (tester) async {
      await _run(tester, (h) async {
        await h.controller.sendText('   ');
        await h.controller.sendText('x' * (maxChatTextLength + 1));
        expect(h.repository.sentIds, isEmpty);

        await h.controller.sendText('😀' * maxChatTextLength);
        expect(h.repository.sentIds, hasLength(1));
      });
    });

    testWidgets('does not send a second message while one is on its way', (tester) async {
      final gate = Completer<ChatSnapshot>();
      final repository = FakeChatRepository()..onSendText = (id, text) => gate.future;
      await _run(tester, repository: repository, (h) async {
        final first = h.controller.sendText('one');
        await tester.pump();

        await h.controller.sendText('two');

        expect(repository.sentIds, hasLength(1));
        gate.complete(ChatSnapshot(conversation: repository.conversation, messages: const []));
        await first;
      });
    });

    testWidgets('a failure marks the message, and "Retry" sends it again with the same id', (tester) async {
      final repository = FakeChatRepository();
      var fail = true;
      await _run(tester, repository: repository, (h) async {
        final normal = repository.onSendText;
        expect(normal, isNull);
        repository.onSendText = (id, text) async {
          if (fail) {
            throw const NetworkFailure(NetworkFailureKind.offline);
          }
          return repository.append([customerText(3, text), botText(4, 'Got it')]);
        };

        await h.controller.sendText('two lattes');

        expect(h.state.outgoing.single.failed, isTrue);
        expect(h.state.messages, hasLength(2));

        fail = false;
        await h.controller.retry('id-1');

        expect(h.state.outgoing, isEmpty);
        expect(h.state.messages.where((m) => m.text == 'two lattes'), hasLength(1));
        expect(repository.sentIds, ['id-1', 'id-1']);
      });
    });

    testWidgets("a poll that returns the customer's own message later does not show it twice", (tester) async {
      await _run(tester, (h) async {
        await h.controller.sendText('two lattes');
        await _wait(tester, _interval);

        expect(h.state.messages.where((m) => m.text == 'two lattes'), hasLength(1));
        expect(h.state.messages.map((m) => m.seq).toSet(), hasLength(h.state.messages.length));
      });
    });
  });

  group('buttons', () {
    testWidgets("a button shows its label as the customer's message and sends its action as it is", (tester) async {
      await _run(tester, (h) async {
        await h.controller.sendReply(reply('Yes, send'));

        expect(h.repository.calls.last, 'action(ConfirmAction)');
        expect(h.state.outgoing, isEmpty);
      });
    });

    testWidgets('a failed button can be retried like text', (tester) async {
      final repository = FakeChatRepository();
      await _run(tester, repository: repository, (h) async {
        repository.onSendAction = (id, action) async => throw const UnexpectedFailure(statusCode: 500);

        await h.controller.sendReply(reply('Skip', const SkipNoteAction()));

        expect(h.state.outgoing.single.label, 'Skip');
        expect(h.state.outgoing.single.failed, isTrue);
      });
    });
  });

  group('what the server refuses', () {
    testWidgets('an expired conversation is replaced by the new empty one the server makes, with a notice', (
      tester,
    ) async {
      final repository = FakeChatRepository();
      await _run(tester, repository: repository, (h) async {
        repository
          ..onSendText = (id, text) async {
            throw _conflict('conversation_expired');
          }
          ..onOpen = (startNew) async =>
              ChatSnapshot(conversation: demoConversation(), messages: [botText(1, 'Welcome back.')]);

        await h.controller.sendText('two lattes');

        expect(h.state.messages.map((m) => m.text), ['Welcome back.']);
        expect(h.state.outgoing, isEmpty);
        expect(h.state.notice, ChatNotice.conversationRestarted);
        expect(repository.calls.last, 'open(false,en)');
      });
    });

    testWidgets('a missing phone number leaves a notice, drops the message, and keeps the chat', (tester) async {
      final repository = FakeChatRepository();
      await _run(tester, repository: repository, (h) async {
        repository.onSendAction = (id, action) async => throw const PhoneNotVerifiedFailure();

        await h.controller.sendReply(reply('Yes, send'));

        expect(h.state.notice, ChatNotice.phoneNotVerified);
        expect(h.state.outgoing, isEmpty);
        expect(h.state.messages, hasLength(2));

        h.controller.dismissNotice();
        expect(h.state.notice, isNull);
      });
    });

    testWidgets('a button that no longer applies is dropped and the chat catches up', (tester) async {
      final repository = FakeChatRepository();
      await _run(tester, repository: repository, (h) async {
        repository
          ..onSendAction = (id, action) async {
            throw _conflict('invalid_action_for_state');
          }
          ..append([botText(3, 'Moved on')]);

        await h.controller.sendReply(reply('Confirm'));

        expect(h.state.outgoing, isEmpty);
        expect(h.state.messages.map((m) => m.seq), [1, 2, 3]);
      });
    });
  });

  group('order again', () {
    testWidgets('opens a new conversation', (tester) async {
      final repository = FakeChatRepository(conversation: demoConversation(step: ChatStep.placed));
      await _run(tester, repository: repository, (h) async {
        repository.onOpen = (startNew) async =>
            ChatSnapshot(conversation: demoConversation(), messages: [botText(1, 'Fresh start')]);

        await h.controller.orderAgain();

        expect(repository.calls.last, 'open(true,en)');
        expect(h.state.messages.single.text, 'Fresh start');
        expect(h.state.conversation.step, ChatStep.ordering);
        expect(h.state.notice, isNull);
      });
    });
  });

  group('sharing the position', () {
    testWidgets('asks the system once, reads the position and sends it as gps', (tester) async {
      final location = FakeLocationService();
      await _run(tester, location: location, (h) async {
        await h.controller.shareMyLocation();

        expect(location.requests, 1);
        expect(h.repository.calls.last, 'location(gps)');
        expect(h.repository.positions.single.latitude, 25.2048);
        expect(h.repository.positions.single.accuracyMetres, 12);
        expect(h.state.locationSharing, LocationSharing.shared);
      });
    });

    testWidgets('does not show the prompt again when the customer already allowed it', (tester) async {
      final location = FakeLocationService(current: LocationAccess.allowed);
      await _run(tester, location: location, (h) async {
        await h.controller.shareMyLocation();

        expect(location.requests, 0);
        expect(h.state.locationSharing, LocationSharing.shared);
      });
    });

    testWidgets('a refusal sends nothing and the restaurant decides without it', (tester) async {
      for (final access in [LocationAccess.askable, LocationAccess.blocked]) {
        final location = FakeLocationService(afterRequest: access, current: access);
        await _run(tester, location: location, (h) async {
          await h.controller.shareMyLocation();

          expect(h.repository.positions, isEmpty, reason: access.name);
          expect(h.state.locationSharing, LocationSharing.notShared, reason: access.name);
        });
      }
    });

    testWidgets('no position, or an upload that fails, is "not shared" and never an error', (tester) async {
      final noFix = FakeLocationService(current: LocationAccess.allowed, problem: LocationProblem.timeout);
      await _run(tester, location: noFix, (h) async {
        await h.controller.shareMyLocation();
        expect(h.state.locationSharing, LocationSharing.notShared);
      });

      final repository = FakeChatRepository()..onShareLocation = (p) async => throw const UnexpectedFailure();
      await _run(tester, repository: repository, location: FakeLocationService(current: LocationAccess.allowed), (
        h,
      ) async {
        await h.controller.shareMyLocation();
        expect(h.state.locationSharing, LocationSharing.notShared);
      });
    });

    testWidgets("a test build can send the restaurant's own position as simulated, with an accuracy of 5 m", (
      tester,
    ) async {
      await _run(tester, (h) async {
        await h.controller.shareSimulatedLocation(latitude: 25.2048, longitude: 55.2708);

        final position = h.repository.positions.single;
        expect(position.simulated, isTrue);
        expect(position.accuracyMetres, 5);
        expect(h.state.locationSharing, LocationSharing.shared);
      });
    });

    testWidgets('"Not now" sends nothing', (tester) async {
      await _run(tester, (h) async {
        h.controller.skipLocation();

        expect(h.repository.positions, isEmpty);
        expect(h.state.locationSharing, LocationSharing.notShared);
      });
    });
  });
}
