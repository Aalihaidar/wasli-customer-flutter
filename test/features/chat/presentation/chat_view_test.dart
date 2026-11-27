import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/error/api_issue.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/platform/location/location_access.dart';
import 'package:wasli_customer/features/account/presentation/add_contact_page.dart';
import 'package:wasli_customer/features/account/presentation/sign_in_page.dart';
import 'package:wasli_customer/features/chat/application/chat_controller.dart';
import 'package:wasli_customer/features/chat/domain/chat_action.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/domain/chat_snapshot.dart';
import 'package:wasli_customer/features/chat/domain/chat_step.dart';
import 'package:wasli_customer/features/chat/domain/order_result_status.dart';
import 'package:wasli_customer/features/chat/presentation/chat_composer.dart';
import 'package:wasli_customer/features/start/presentation/restaurant_page.dart';

import '../../../support/bidi.dart';
import '../../../support/fake_account_repository.dart';
import '../../../support/fake_chat_repository.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/pump_app.dart';

const _path = '/r/demo-cafe';
const _arabic = Locale('ar');

Future<void> _pumpChat(
  WidgetTester tester, {
  FakeChatRepository? chat,
  FakeLocationService? location,
  Locale? locale,
  bool signedIn = true,
  bool production = false,
  FakeAccountRepository? account,
}) {
  return pumpApp(
    tester,
    initialLocation: _path,
    signedIn: signedIn,
    chat: chat ?? FakeChatRepository(),
    account: account,
    location: location,
    savedLocale: locale,
    environment: production ? testEnvironment(appEnv: 'production') : null,
  );
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.tap(find.byTooltip('Send'));
  await tester.pumpAndSettle();
}

void main() {
  group('the chat when signed in', () {
    testWidgets('shows the welcome the server wrote, under the restaurant name', (tester) async {
      await _pumpChat(tester);

      expect(find.text('Demo Cafe'), findsOneWidget);
      expect(find.text('Welcome to Demo Cafe.'), findsOneWidget);
      expect(find.text('What would you like to order?'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets("typed text appears at once as the customer's message, then the reply", (tester) async {
      final gate = Completer<void>();
      final chat = FakeChatRepository();
      chat.onSendText = (id, text) async {
        await gate.future;
        return chat.append([customerText(3, text), botText(4, 'Got it')]);
      };
      await _pumpChat(tester, chat: chat);

      await tester.enterText(find.byType(TextField), 'two lattes');
      await tester.tap(find.byTooltip('Send'));
      await tester.pump();

      expect(find.text('two lattes'), findsOneWidget);
      expect(find.text('Sending…'), findsOneWidget);
      expect(
        tester.widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send)).onPressed,
        isNull,
        reason: 'one at a time',
      );

      gate.complete();
      await tester.pumpAndSettle();

      expect(find.text('two lattes'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(find.text('Sending…'), findsNothing);
    });

    testWidgets('the field is cleared after sending, and blank text sends nothing', (tester) async {
      final chat = FakeChatRepository();
      await _pumpChat(tester, chat: chat);

      await _type(tester, '   ');
      expect(chat.sentIds, isEmpty);

      await _type(tester, 'a latte');
      expect(chat.sentIds, hasLength(1));
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
    });

    testWidgets('a message that failed says so and "Retry" sends it again', (tester) async {
      final chat = FakeChatRepository();
      var fail = true;
      chat.onSendText = (id, text) async {
        if (fail) {
          throw const NetworkFailure(NetworkFailureKind.offline);
        }
        return chat.append([customerText(3, text), botText(4, 'Got it')]);
      };
      await _pumpChat(tester, chat: chat);

      await _type(tester, 'a latte');

      expect(find.text('Not sent'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Not sent'), findsNothing);
      expect(find.text('a latte'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(chat.sentIds.toSet(), hasLength(1), reason: 'the same message id both times');
    });

    testWidgets('news from the server arrives by polling', (tester) async {
      final chat = FakeChatRepository();
      await _pumpChat(tester, chat: chat);

      chat.append([botText(3, 'Anything else?')]);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();

      expect(find.text('Anything else?'), findsOneWidget);
    });

    testWidgets('the text field stops at 500 code points', (tester) async {
      const formatter = CodePointLimitFormatter();
      final tooLong = TextEditingValue(text: '😀' * (maxChatTextLength + 20));

      final result = formatter.formatEditUpdate(TextEditingValue.empty, tooLong);

      expect(result.text.runes.length, maxChatTextLength);
      expect(result.selection.baseOffset, result.text.length);
    });
  });

  group('the buttons of the latest message', () {
    testWidgets('only the latest message of the server has active buttons, and a tap sends the action', (tester) async {
      final chat = FakeChatRepository(
        messages: [
          botText(1, 'Old question', replies: [reply('Old button')]),
          botText(2, 'Confirm your order?', replies: [reply('Confirm'), reply('Edit', const EditAction())]),
        ],
      );
      await _pumpChat(tester, chat: chat);

      expect(find.widgetWithText(OutlinedButton, 'Confirm'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Edit'), findsOneWidget);
      expect(find.text('Old button'), findsNothing);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Confirm'));
      await tester.pumpAndSettle();

      expect(chat.calls.last, 'action(ConfirmAction)');
      expect(
        find.widgetWithText(OutlinedButton, 'Confirm'),
        findsNothing,
        reason: 'hidden once a newer message arrived',
      );
    });

    testWidgets('the buttons wait while a message is on its way', (tester) async {
      final gate = Completer<ChatSnapshot>();
      final chat = FakeChatRepository(
        messages: [
          botText(1, 'Confirm?', replies: [reply('Confirm')]),
        ],
      )..onSendAction = (id, action) => gate.future;
      await _pumpChat(tester, chat: chat);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Confirm'));
      await tester.pump();

      expect(find.widgetWithText(OutlinedButton, 'Confirm'), findsNothing);
      expect(find.text('Confirm'), findsOneWidget, reason: "the customer's own bubble");

      gate.complete(ChatSnapshot(conversation: chat.conversation, messages: const []));
      await tester.pumpAndSettle();
    });
  });

  group('the cards', () {
    testWidgets('the order summary shows the lines and the total the server priced', (tester) async {
      final chat = FakeChatRepository(
        messages: [
          OrderSummaryMessage(
            id: 'm-1',
            seq: 1,
            fromCustomer: false,
            createdAt: DateTime.utc(2026, 11, 27),
            text: 'Your order',
            summary: demoSummary,
            quickReplies: [reply('Confirm')],
          ),
        ],
      );
      await _pumpChat(tester, chat: chat);

      expect(find.text('Your order'), findsOneWidget);
      expect(find.text('2 × Latte'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);
      expect(find.text('AED 29.00'), findsNWidgets(2), reason: 'the line and the total');
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('the review shows the car, the parking place and whether the position was shared', (tester) async {
      final chat = FakeChatRepository(
        conversation: demoConversation(step: ChatStep.review),
        messages: [
          ReviewMessage(
            id: 'm-1',
            seq: 1,
            fromCustomer: false,
            createdAt: DateTime.utc(2026, 11, 27),
            text: 'Please check your order.',
            summary: demoSummary,
            parkingNote: 'Level 2',
            vehiclePlate: 'A 12345',
            vehicleModel: 'Toyota Corolla',
            vehicleColour: 'White',
            orderNote: '',
            locationShared: false,
            quickReplies: [reply('Yes, send')],
          ),
        ],
      );
      await _pumpChat(tester, chat: chat);

      expect(find.text('Level 2'), findsOneWidget);
      expect(find.text(ltr('A 12345')), findsOneWidget);
      expect(find.text('Toyota Corolla'), findsOneWidget);
      expect(find.text('White'), findsOneWidget);
      expect(find.text('Note'), findsNothing, reason: 'no note, no row');
      expect(find.text('Not shared'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Yes, send'), findsOneWidget);
    });

    testWidgets("accepted: a green banner with the wait time and the server's sentence", (tester) async {
      final chat = FakeChatRepository(
        conversation: demoConversation(step: ChatStep.placed),
        messages: [botResult(1, OrderResultStatus.accepted, 'Your order #17 is confirmed.', eta: 10)],
      );
      await _pumpChat(tester, chat: chat);

      expect(find.text('Confirmed · Order #17'), findsOneWidget);
      expect(find.text('Ready in about 10 minutes'), findsOneWidget);
      expect(find.text('Your order #17 is confirmed.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets("rejected: a red banner with the server's sentence and the restaurant's note", (tester) async {
      final chat = FakeChatRepository(
        conversation: demoConversation(step: ChatStep.placed),
        messages: [botResult(1, OrderResultStatus.rejected, 'Sorry, we are too busy.', note: 'Back in an hour')],
      );
      await _pumpChat(tester, chat: chat);

      expect(find.text('Rejected · Order #17'), findsOneWidget);
      expect(find.text('Sorry, we are too busy.'), findsOneWidget);
      expect(find.text('Back in an hour'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets("ready: a green banner with the server's sentence and no wait time", (tester) async {
      final chat = FakeChatRepository(
        conversation: demoConversation(step: ChatStep.placed),
        messages: [botResult(1, OrderResultStatus.ready, 'Your order #17 is ready. We are bringing it to your car.')],
      );
      await _pumpChat(tester, chat: chat);

      expect(find.text('Ready · Order #17'), findsOneWidget);
      expect(find.text('Your order #17 is ready. We are bringing it to your car.'), findsOneWidget);
      expect(find.textContaining('about'), findsNothing);
    });

    testWidgets("a status this version does not know is a plain card with the server's sentence", (tester) async {
      final chat = FakeChatRepository(
        conversation: demoConversation(step: ChatStep.placed),
        messages: [botResult(1, OrderResultStatus.unknown, 'Your order #17 was delivered.')],
      );
      await _pumpChat(tester, chat: chat);

      expect(find.text('Order update · Order #17'), findsOneWidget);
      expect(find.text('Your order #17 was delivered.'), findsOneWidget);
    });

    testWidgets('a menu image shows its caption', (tester) async {
      final chat = FakeChatRepository(
        messages: [
          ImageMessage(
            id: 'm-1',
            seq: 1,
            fromCustomer: false,
            createdAt: DateTime.utc(2026, 11, 27),
            text: 'Hot drinks',
            imageUrl: 'https://media.example.com/menus/demo-cafe-1.jpg',
          ),
        ],
      );
      await _pumpChat(tester, chat: chat);

      expect(find.text('Hot drinks'), findsOneWidget);
    });
  });

  group('the car step', () {
    FakeChatRepository carStep() => FakeChatRepository(
      conversation: demoConversation(step: ChatStep.askCar),
      messages: [botText(1, 'Where are you parked?')],
    );

    testWidgets('explains first, and shows the system prompt only on the button', (tester) async {
      final location = FakeLocationService();
      final chat = carStep();
      await _pumpChat(tester, chat: chat, location: location);

      expect(find.text('Share your location'), findsOneWidget);
      expect(find.textContaining('only the restaurant that gets your order'), findsOneWidget);
      expect(location.requests, 0);
      expect(chat.positions, isEmpty);

      await tester.tap(find.widgetWithText(FilledButton, 'Share my location'));
      await tester.pumpAndSettle();

      expect(location.requests, 1);
      expect(chat.calls.last, 'location(gps)');
      expect(find.text('Share your location'), findsNothing, reason: 'asked once');
    });

    testWidgets('"Not now" sends nothing and the customer can still answer', (tester) async {
      final chat = carStep();
      await _pumpChat(tester, chat: chat);

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(chat.positions, isEmpty);
      expect(find.text('Share your location'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('a test build can pretend to be at the restaurant', (tester) async {
      final chat = carStep();
      await _pumpChat(tester, chat: chat);

      await tester.ensureVisible(find.text("Simulate: I'm at the restaurant"));
      await tester.tap(find.text("Simulate: I'm at the restaurant"));
      await tester.pumpAndSettle();

      expect(chat.positions.single.simulated, isTrue);
      expect(chat.positions.single.latitude, 25.2048);
    });

    testWidgets('a production build has no way to pretend', (tester) async {
      await _pumpChat(tester, chat: carStep(), production: true);

      expect(find.text('Share my location'), findsOneWidget);
      expect(find.text("Simulate: I'm at the restaurant"), findsNothing);
    });

    testWidgets('is not asked at any other step', (tester) async {
      await _pumpChat(tester);

      expect(find.text('Share your location'), findsNothing);
    });

    testWidgets('a refusal at the system prompt is not an error', (tester) async {
      final location = FakeLocationService(afterRequest: LocationAccess.blocked);
      final chat = carStep();
      await _pumpChat(tester, chat: chat, location: location);

      await tester.tap(find.widgetWithText(FilledButton, 'Share my location'));
      await tester.pumpAndSettle();

      expect(chat.positions, isEmpty);
      expect(find.text('Share your location'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('what the server refuses', () {
    testWidgets('a missing phone number says so, with the way to confirm one', (tester) async {
      final chat =
          FakeChatRepository(
              conversation: demoConversation(step: ChatStep.review),
              messages: [
                botText(1, 'Everything right?', replies: [reply('Yes, send')]),
              ],
            )
            ..onSendAction = (id, action) async {
              throw const PhoneNotVerifiedFailure();
            };
      await _pumpChat(tester, chat: chat);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Yes, send'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Confirm a phone number first'), findsOneWidget);
      expect(
        find.widgetWithText(OutlinedButton, 'Yes, send'),
        findsOneWidget,
        reason: 'the button is there to press again',
      );

      await tester.tap(find.text('Confirm my phone number'));
      await tester.pumpAndSettle();

      expect(find.byType(AddContactPage), findsOneWidget);
    });

    testWidgets('an expired conversation starts a new one and says so', (tester) async {
      final chat = FakeChatRepository();
      await _pumpChat(tester, chat: chat);
      chat
        ..onSendText = (id, text) async {
          throw const ConflictFailure([ApiIssue(code: 'conversation_expired')]);
        }
        ..onOpen = (startNew) async =>
            ChatSnapshot(conversation: demoConversation(), messages: [botText(1, 'Welcome back.')]);

      await _type(tester, 'a latte');

      expect(find.textContaining('This conversation expired'), findsOneWidget);
      expect(find.text('Welcome back.'), findsOneWidget);
    });
  });

  group('after the order was sent', () {
    testWidgets('the composer is replaced by "Start a new order", which opens a fresh conversation', (tester) async {
      final chat = FakeChatRepository(
        conversation: demoConversation(step: ChatStep.placed),
        messages: [botText(1, 'Your order #17 was sent.')],
      );
      await _pumpChat(tester, chat: chat);

      expect(find.byType(TextField), findsNothing);
      chat.onOpen = (startNew) async =>
          ChatSnapshot(conversation: demoConversation(), messages: [botText(1, 'Fresh start')]);

      await tester.tap(find.text('Start a new order'));
      await tester.pumpAndSettle();

      expect(chat.calls.last, 'open(true,en)');
      expect(find.text('Fresh start'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets("the restaurant's answer arrives by polling", (tester) async {
      final chat = FakeChatRepository(
        conversation: demoConversation(step: ChatStep.placed),
        messages: [botText(1, 'Your order #17 was sent.')],
      );
      await _pumpChat(tester, chat: chat);

      chat.append([botResult(2, OrderResultStatus.accepted, 'Your order #17 is confirmed.', eta: 5)]);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();

      expect(find.text('Ready in about 5 minutes'), findsOneWidget);
    });
  });

  group('the chat when the customer has no account on this device', () {
    testWidgets('offers to sign in, and signing in leads back to the restaurant', (tester) async {
      await _pumpChat(tester, signedIn: false, account: FakeAccountRepository());

      expect(find.text('Demo Cafe'), findsOneWidget);
      expect(find.text('Sign in to order'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
      await tester.pumpAndSettle();
      expect(find.byType(SignInPage), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'sara@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'a-demo-password');
      await tester.tap(
        find.descendant(of: find.byType(SignInPage), matching: find.widgetWithText(FilledButton, 'Sign in')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RestaurantPage), findsOneWidget);
      expect(find.text('Welcome to Demo Cafe.'), findsOneWidget);
    });
  });

  group('the chat in Arabic and at a large text size', () {
    testWidgets("the customer's bubble sits on the end side, the server's on the start side, right to left", (
      tester,
    ) async {
      final chat = FakeChatRepository(messages: [botText(1, 'أهلاً بك'), customerText(2, 'لاتيه')]);
      await _pumpChat(tester, chat: chat, locale: _arabic);

      final bot = tester.getTopRight(find.text('أهلاً بك')).dx;
      final customer = tester.getTopLeft(find.text('لاتيه')).dx;
      expect(Directionality.of(tester.element(find.byType(RestaurantPage))), TextDirection.rtl);
      expect(bot, greaterThan(customer), reason: 'the server is on the right, the start side in Arabic');
      expect(find.text('اكتب طلبك'), findsOneWidget);
    });

    testWidgets('the result banner keeps the order number left to right', (tester) async {
      final chat = FakeChatRepository(
        conversation: demoConversation(step: ChatStep.placed, languageCode: 'ar'),
        messages: [botResult(1, OrderResultStatus.ready, 'طلبك جاهز.')],
      );
      await _pumpChat(tester, chat: chat, locale: _arabic);

      expect(find.textContaining('جاهز · طلب رقم 17'), findsOneWidget);
    });

    for (final locale in [null, _arabic]) {
      testWidgets('survives the largest text scale on a small phone without overflow (${locale ?? 'en'})', (
        tester,
      ) async {
        tester.view
          ..physicalSize = const Size(360, 640)
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final chat = FakeChatRepository(
          conversation: demoConversation(step: ChatStep.askCar),
          messages: [
            botText(
              1,
              'Where are you parked, and what car do you drive?',
              replies: [reply('Confirm'), reply('Edit', const EditAction())],
            ),
            botResult(2, OrderResultStatus.accepted, 'Your order #17 is confirmed.', eta: 10),
          ],
        );

        await _pumpChat(tester, chat: chat, locale: locale);

        expect(tester.takeException(), isNull);
      });
    }
  });
}
