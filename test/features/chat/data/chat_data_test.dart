import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/features/chat/data/chat_mapper.dart';
import 'package:wasli_customer/features/chat/data/chat_repository_impl.dart';
import 'package:wasli_customer/features/chat/domain/chat_action.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/domain/chat_step.dart';
import 'package:wasli_customer/features/chat/domain/order_result_status.dart';
import 'package:wasli_customer/features/chat/domain/shared_position.dart';

import '../../../support/api_fixtures.dart';
import '../../../support/fake_http_adapter.dart';
import '../../../support/network_harness.dart';

const _conversation = 'c0a80101-0000-4a5b-8c9d-0e1f2a3b4c10';

ChatRepositoryImpl _repositoryOver(NetworkHarness harness) => ChatRepositoryImpl(ChatClient(harness.dio));

NetworkHarness _answering(String fixture, {int status = 200}) =>
    NetworkHarness((_) => jsonResponse(status, readApiFixture(fixture)), token: 'tok-1');

void main() {
  group('chatSnapshotFromDto', () {
    test('reads a new conversation: the step, the language, no order, and a welcome with an image', () {
      final snapshot = chatSnapshotFromDto(Chat$Response.fromJson(readApiFixture('conversations_open_201')));

      expect(snapshot.conversation.step, ChatStep.ordering);
      expect(snapshot.conversation.languageCode, 'en');
      expect(snapshot.conversation.aiAvailable, isTrue);
      expect(snapshot.conversation.order, isNull);
      expect(snapshot.messages.map((m) => m.seq), [1, 2, 3]);
      expect(snapshot.messages[0], isA<TextMessage>().having((m) => m.fromCustomer, 'fromCustomer', isFalse));
      expect(
        snapshot.messages[1],
        isA<ImageMessage>().having((m) => m.imageUrl, 'imageUrl', 'https://media.example.com/menus/demo-cafe-1.jpg'),
      );
    });

    test('reads the order summary with its priced lines and its buttons', () {
      final snapshot = chatSnapshotFromDto(Chat$Response.fromJson(readApiFixture('conversations_messages_list_200')));

      final summary = snapshot.messages.whereType<OrderSummaryMessage>().single;
      final line = summary.summary!.lines.single;
      expect(line.name, 'Latte');
      expect(line.optionNames, ['Large']);
      expect(line.quantity, 1);
      expect(line.note, isNull);
      expect(line.lineTotalMinor, 1450);
      expect(summary.summary!.totalMinor, 1450);
      expect(summary.summary!.currency, 'AED');
      expect(summary.quickReplies.map((r) => r.label), ['Confirm', 'Edit']);
      expect(summary.quickReplies.first.action, isA<ConfirmAction>());
    });

    test('reads the placed conversation with its order', () {
      final snapshot = chatSnapshotFromDto(
        Chat$Response.fromJson(readApiFixture('conversations_messages_create_201_placed')),
      );

      expect(snapshot.conversation.step, ChatStep.placed);
      expect(snapshot.conversation.order?.number, 17);
      expect(snapshot.conversation.order?.status, 'placed');
    });

    group('the review and the results', () {
      final messages = chatSnapshotFromDto(
        Chat$Response.fromJson(readApiFixture('conversations_messages_list_200_review_and_results')),
      ).messages;

      test('the review has the car, the position flag and the lines', () {
        final review = messages.whereType<ReviewMessage>().single;

        expect(review.parkingNote, 'Level 2, near the lift');
        expect(review.vehiclePlate, 'A 12345');
        expect(review.vehicleModel, 'Toyota Corolla');
        expect(review.vehicleColour, 'White');
        expect(review.orderNote, isEmpty);
        expect(review.locationShared, isTrue);
        expect(review.summary!.lines.single.note, 'extra hot');
      });

      test('a quick reply the app cannot send is left out, the others keep their action', () {
        final review = messages.whereType<ReviewMessage>().single;

        expect(review.quickReplies.map((r) => r.label), [
          'Yes, send',
          'Change something',
          'Change the car',
          'Pick one',
          'Skip',
          'Start over',
        ]);
        expect(review.quickReplies[2].action, isA<EditFieldAction>().having((a) => a.field, 'field', ChatField.car));
        expect(review.quickReplies[3].action, isA<ChooseAction>().having((a) => a.value, 'value', 'opt-1'));
      });

      test('accepted, rejected, ready and an unknown status each read as themselves', () {
        final results = messages.whereType<ResultMessage>().toList();

        expect(results.map((r) => r.status), [
          OrderResultStatus.accepted,
          OrderResultStatus.rejected,
          OrderResultStatus.ready,
          OrderResultStatus.unknown,
        ]);
        expect(results[0].etaMinutes, 10);
        expect(results[0].orderNumber, 17);
        expect(results[0].rejectionNote, isNull);
        expect(results[1].rejectionNote, 'Back in an hour');
        expect(results[1].etaMinutes, isNull);
        expect(results[2].etaMinutes, isNull);
        expect(results[2].text, 'Your order #17 is ready. We are bringing it to your car.');
      });

      test('a kind the app does not know is shown as plain text', () {
        final unknown = messages.firstWhere((m) => m.seq == 15);

        expect(unknown, isA<TextMessage>().having((m) => m.text, 'text', 'A kind this version does not know.'));
      });
    });

    test('an unknown step reads as unknown, not as an error', () {
      final json = readApiFixture('conversations_open_201');
      (json['conversation']! as Map<String, Object?>)['state'] = 'cooking';

      expect(chatSnapshotFromDto(Chat$Response.fromJson(json)).conversation.step, ChatStep.unknown);
    });
  });

  group('ChatRepositoryImpl.open', () {
    test('asks for the restaurant in the app language, with the token, and never a new one by default', () async {
      final harness = _answering('conversations_open_201');

      final snapshot = await _repositoryOver(harness).open('demo-cafe', languageCode: 'ar');

      expect(snapshot.messages, hasLength(3));
      final request = harness.adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/api/v1/restaurants/demo-cafe/conversations');
      expect(request.headers['Authorization'], 'Customer tok-1');
      expect(request.data, contains('"locale":"ar"'));
      expect(request.data, contains('"start_new":false'));
      expect(request.data, contains('"order_type":"car"'));
    });

    test('a new conversation answered with 201 is read, although the generated method accepts only 200', () async {
      final harness = _answering('conversations_open_201', status: 201);

      final snapshot = await _repositoryOver(harness).open('demo-cafe', languageCode: 'en');

      expect(snapshot.conversation.id, _conversation);
      expect(snapshot.messages, hasLength(3));
    });

    test('"Order again" asks for a new one', () async {
      final harness = _answering('conversations_open_201', status: 201);

      await _repositoryOver(harness).open('demo-cafe', languageCode: 'en', startNew: true);

      expect(harness.adapter.requests.single.data, contains('"start_new":true'));
    });

    test('another failure is still a Failure', () async {
      final harness = NetworkHarness((_) => jsonResponse(404, readApiFixture('errors/not_found_404')), token: 'tok-1');

      await expectLater(_repositoryOver(harness).open('gone', languageCode: 'en'), throwsA(isA<NotFoundFailure>()));
    });

    test('a 401 ends the session', () async {
      final harness = NetworkHarness(
        (_) => jsonResponse(401, readApiFixture('errors/not_authenticated_401')),
        token: 'tok-1',
      );

      await expectLater(
        _repositoryOver(harness).open('demo-cafe', languageCode: 'en'),
        throwsA(isA<UnauthenticatedFailure>()),
      );
      expect(harness.sessionExpiredCount, 1);
    });
  });

  group('ChatRepositoryImpl messages', () {
    test('reads what came after a seq', () async {
      final harness = _answering('conversations_messages_list_200');

      final snapshot = await _repositoryOver(harness).messagesAfter(_conversation, 3);

      expect(snapshot.messages, isNotEmpty);
      final request = harness.adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/api/v1/conversations/$_conversation/messages');
      expect(request.queryParameters, {'after_seq': 3});
    });

    test('sends typed text with its message id and nothing else', () async {
      final harness = _answering('conversations_messages_create_201', status: 201);

      await _repositoryOver(harness).sendText(_conversation, clientMessageId: 'id-1', text: 'two lattes');

      final request = harness.adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.data, {'client_message_id': 'id-1', 'text': 'two lattes'});
    });

    test('sends a button as its action, and an edit with its field', () async {
      final harness = _answering('conversations_messages_create_201', status: 201);
      final repository = _repositoryOver(harness);

      await repository.sendAction(_conversation, clientMessageId: 'id-2', action: const ConfirmAction());
      await repository.sendAction(_conversation, clientMessageId: 'id-3', action: const EditFieldAction(ChatField.car));
      await repository.sendAction(_conversation, clientMessageId: 'id-4', action: const ChooseAction('opt-1'));

      expect(harness.adapter.requests[0].data, {'client_message_id': 'id-2', 'action': 'confirm'});
      expect(harness.adapter.requests[1].data, {'client_message_id': 'id-3', 'action': 'edit_field', 'field': 'car'});
      expect(harness.adapter.requests[2].data, {'client_message_id': 'id-4', 'action': 'choose', 'value': 'opt-1'});
    });

    test('a retry sends the same id again', () async {
      final harness = _answering('conversations_messages_create_201', status: 201);
      final repository = _repositoryOver(harness);

      await repository.sendText(_conversation, clientMessageId: 'id-1', text: 'a');
      await repository.sendText(_conversation, clientMessageId: 'id-1', text: 'a');

      expect(harness.adapter.requests.map((r) => (r.data as Map<String, Object?>)['client_message_id']), [
        'id-1',
        'id-1',
      ]);
    });

    test('the codes the chat acts on arrive as the right Failure', () async {
      for (final (status, code, matcher) in [
        (409, 'conversation_expired', isA<ConflictFailure>()),
        (409, 'invalid_action_for_state', isA<ConflictFailure>()),
        (403, 'phone_not_verified', isA<PhoneNotVerifiedFailure>()),
      ]) {
        final harness = NetworkHarness(
          (_) => jsonResponse(status, {
            'type': 'client_error',
            'errors': [
              {'code': code, 'detail': 'x', 'attr': null},
            ],
          }),
          token: 'tok-1',
        );

        await expectLater(
          _repositoryOver(harness).sendText(_conversation, clientMessageId: 'id', text: 'a'),
          throwsA(matcher),
          reason: code,
        );
      }
    });
  });

  group('ChatRepositoryImpl.shareLocation', () {
    test('puts the position with its source and accuracy, and logs nothing of it', () async {
      final harness = NetworkHarness((_) => ResponseBody.fromString('', 204), token: 'tok-1');

      await _repositoryOver(
        harness,
      ).shareLocation(_conversation, const SharedPosition(latitude: 25.2048, longitude: 55.2708, accuracyMetres: 12));

      final request = harness.adapter.requests.single;
      expect(request.method, 'PUT');
      expect(request.path, '/api/v1/conversations/$_conversation/location');
      expect(request.data, {'lat': 25.2048, 'lng': 55.2708, 'accuracy_m': 12.0, 'source': 'gps'});
      for (final line in harness.logger.lines) {
        expect(line, isNot(contains('25.2')));
      }
    });

    test('a simulated position says so', () async {
      final harness = NetworkHarness((_) => ResponseBody.fromString('', 204), token: 'tok-1');

      await _repositoryOver(harness).shareLocation(
        _conversation,
        const SharedPosition(latitude: 25.2, longitude: 55.3, accuracyMetres: 5, simulated: true),
      );

      expect((harness.adapter.requests.single.data as Map<String, Object?>)['source'], 'simulated');
    });
  });
}
