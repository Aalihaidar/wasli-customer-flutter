import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/api/api.dart';

import '../support/api_fixtures.dart';

/// Every success fixture must parse with the generated client and serialise back to the same JSON, so a contract
/// change that the fixtures do not follow fails here.
void main() {
  group('generated models read the contract fixtures', () {
    test('GET /config', () {
      final json = readApiFixture('config_200');
      final config = Config.fromJson(json);

      expect(config.locationCheck, LocationCheckEnum.warn);
      expect(config.requireScreenOnline, isTrue);
      expect(config.aiEnabled, isTrue);
      expect(config.languages, [LanguagesEnum.en, LanguagesEnum.ar]);
      expect(config.pollIntervalSeconds, 3);
      expect(config.toJson(), json);
    });

    test('POST /customers/signup (201)', () {
      final json = readApiFixture('customers_signup_201');
      final sent = SentCode.fromJson(json);

      expect(sent.identifier, 'sara@example.com');
      expect(sent.channel, ChannelEnum.email);
      expect(sent.toJson(), json);
    });

    test('POST /customers/resend-code (202)', () {
      final json = readApiFixture('customers_resend_code_202');

      expect(SentCode.fromJson(json).toJson(), json);
    });

    test('POST /customers/me/contact (202)', () {
      final json = readApiFixture('customers_contact_add_202');
      final sent = SentCode.fromJson(json);

      expect(sent.channel, ChannelEnum.sms);
      expect(sent.toJson(), json);
    });

    test('POST /customers/password-reset (202)', () {
      final json = readApiFixture('customers_password_reset_202');
      final sent = PasswordResetSent.fromJson(json);

      expect(sent.codeExpiresInSeconds, 600);
      expect(sent.toJson(), json);
    });

    test('POST /customers/verify (200)', () {
      final json = readApiFixture('customers_verify_200');
      final session = Session$Response.fromJson(json);

      expect(session.token, isNotEmpty);
      expect(session.customer.emailVerified, isTrue);
      expect(session.customer.phone, isNull);
      expect(session.toJson(), json);
    });

    test('POST /customers/login (200), Arabic customer', () {
      final json = readApiFixture('customers_login_200');
      final session = Session$Response.fromJson(json);

      expect(session.customer.fullName, 'سارة تجريبية');
      expect(session.customer.phoneVerified, isTrue);
      expect(session.toJson(), json);
    });

    test('GET /customers/me (200)', () {
      final json = readApiFixture('customers_me_200');

      expect(CustomerProfile$Response.fromJson(json).toJson(), json);
    });

    test('POST /customers/me/contact/verify (200)', () {
      final json = readApiFixture('customers_contact_verify_200');
      final profile = CustomerProfile$Response.fromJson(json);

      expect(profile.phoneVerified, isTrue);
      expect(profile.toJson(), json);
    });

    test('GET /restaurants/nearby (200) with restaurants: no nearest key', () {
      final json = readApiFixture('restaurants_nearby_200');
      final nearby = NearbyResponse$Response.fromJson(json);

      expect(nearby.restaurants, hasLength(2));
      expect(nearby.restaurants.first.distanceM, 120);
      expect(nearby.restaurants.first.serviceRadiusM, 500);
      expect(nearby.restaurants.last.serviceRadiusM, isNull);
      expect(nearby.restaurants.last.toJson().containsKey('service_radius_m'), isFalse);
      expect(nearby.restaurants.last.logoUrl, isNull);
      expect(nearby.nearest, isNull);
      expect(nearby.toJson(), json);
    });

    test('GET /restaurants/nearby (200) with no restaurants in range: the nearest one', () {
      final json = readApiFixture('restaurants_nearby_200_empty');
      final nearby = NearbyResponse$Response.fromJson(json);

      expect(nearby.restaurants, isEmpty);
      expect(nearby.nearest, isNotNull);
      expect(nearby.nearest!.serviceRadiusM, 500);
      expect(nearby.toJson(), json);
    });

    test('GET /restaurants/nearby (200) with no visible restaurant at all: no nearest key', () {
      final json = readApiFixture('restaurants_nearby_200_none_visible');
      final nearby = NearbyResponse$Response.fromJson(json);

      expect(nearby.restaurants, isEmpty);
      expect(nearby.nearest, isNull);
      expect(nearby.toJson(), json);
    });

    test('GET /restaurants/{slug} (200)', () {
      final json = readApiFixture('restaurants_retrieve_200');
      final restaurant = RestaurantDetail$Response.fromJson(json);

      expect(restaurant.slug, 'demo-cafe');
      expect(restaurant.currency, 'AED');
      expect(restaurant.menu.first.items.first.priceMinor, 1250);
      expect(restaurant.menu.first.items.last.isAvailable, isFalse);
      expect(restaurant.serviceRadiusM, 500);
      expect(restaurant.toJson(), json);
    });

    test('GET /restaurants/{slug} (200) nested menu: a subcategory has parent_id, a top-level one has no key', () {
      final json = readApiFixture('restaurants_retrieve_200');
      final restaurant = RestaurantDetail$Response.fromJson(json);
      final top = restaurant.menu.first;
      final sub = restaurant.menu.last;

      expect(restaurant.menu, hasLength(2));
      expect(top.parentId, isNull);
      expect(top.toJson().containsKey('parent_id'), isFalse);
      expect(sub.parentId, top.id);
      expect(sub.toJson()['parent_id'], top.id);
    });

    test('GET /restaurants/{slug} (200) without a service distance: the key is absent', () {
      final json = Map<String, Object?>.of(readApiFixture('restaurants_retrieve_200'))..remove('service_radius_m');
      final restaurant = RestaurantDetail$Response.fromJson(json);

      expect(restaurant.serviceRadiusM, isNull);
      expect(restaurant.toJson(), json);
    });
  });

  group('chat fixtures', () {
    test('POST /restaurants/{slug}/conversations (201): welcome, a menu image, the first question', () {
      final json = readApiFixture('conversations_open_201');
      final chat = Chat$Response.fromJson(json);

      expect(chat.conversation.restaurantSlug, 'demo-cafe');
      expect(chat.conversation.state.value, 'ordering');
      expect(chat.conversation.orderType.value, 'car');
      expect(chat.conversation.aiAvailable, isTrue);
      expect(chat.conversation.expiresAt, DateTime.utc(2026, 11, 23, 12));
      expect(chat.messages.map((m) => m.seq), [1, 2, 3]);
      expect(chat.messages.map((m) => m.kind.value), ['text', 'image', 'text']);
      expect(chat.messages[1].imageUrl, 'https://media.example.com/menus/demo-cafe-1.jpg');
      expect(chat.messages[0].imageUrl, isNull);
      expect(chat.toJson(), json);
    });

    test('GET /conversations/{id}/messages (200): the conversation can be Arabic with the assistant down', () {
      final json = readApiFixture('conversations_messages_list_200');
      final chat = Chat$Response.fromJson(json);

      expect(chat.conversation.locale.value, 'ar');
      expect(chat.conversation.aiAvailable, isFalse);
      expect(chat.messages.map((m) => m.sender.value), ['customer', 'bot']);
      expect(chat.messages.last.kind.value, 'order_summary');
      expect(chat.toJson(), json);
    });

    test('POST /conversations/{id}/messages (201): the customer message and the bot reply', () {
      final json = readApiFixture('conversations_messages_create_201');
      final chat = Chat$Response.fromJson(json);

      expect(chat.conversation.state.value, 'ask_car');
      expect(chat.messages.first.sender.value, 'customer');
      expect(chat.messages.first.payload, {'action': 'confirm'});
      expect(chat.messages.last.sender.value, 'bot');
      expect(chat.toJson(), json);
    });

    test('POST /conversations/{id}/voice (201): the customer message shows its transcript', () {
      final json = readApiFixture('conversations_voice_create_201');
      final chat = Chat$Response.fromJson(json);

      expect(chat.messages.first.usedVoice, isTrue);
      expect(chat.messages.first.text, isEmpty);
      expect(chat.messages.first.transcript, 'Two lattes please');
      expect(chat.messages.last.usedVoice, isFalse);
      expect(chat.toJson(), json);
    });

    test('POST /conversations/{id}/messages (201) placing the order: the conversation carries the order', () {
      final json = readApiFixture('conversations_messages_create_201_placed');
      final chat = Chat$Response.fromJson(json);
      final order = chat.conversation.order;

      expect(chat.conversation.state.value, 'placed');
      expect(order, isNotNull);
      expect(order!.number, 17);
      expect(order.status.value, 'placed');
      expect(chat.toJson(), json);
    });

    test('a conversation before the order is placed has no order key, never null', () {
      final json = readApiFixture('conversations_open_201');
      final chat = Chat$Response.fromJson(json);

      expect(chat.conversation.order, isNull);
      expect((chat.toJson()['conversation']! as Map<String, Object?>).containsKey('order'), isFalse);
    });

    test('a value the server adds later (kind, state, order type) is read, not rejected', () {
      final json = Map<String, Object?>.of(readApiFixture('conversations_open_201'));
      final conversation = Map<String, Object?>.of(json['conversation']! as Map<String, Object?>)
        ..['state'] = 'archived'
        ..['order_type'] = 'drive_through';
      final messages = (json['messages']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(Map<String, Object?>.of)
          .toList();
      messages.first['kind'] = 'carousel';
      final chat = Chat$Response.fromJson({...json, 'conversation': conversation, 'messages': messages});

      expect(chat.conversation.state.value, 'archived');
      expect(chat.conversation.orderType.value, 'drive_through');
      expect(chat.messages.first.kind.value, 'carousel');
    });

    test('a message that is missing a required key is rejected, not guessed', () {
      final json = Map<String, Object?>.of(readApiFixture('conversations_open_201'));
      final messages = (json['messages']! as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(Map<String, Object?>.of)
          .toList();
      messages.first.remove('seq');

      expect(() => Chat$Response.fromJson({...json, 'messages': messages}), throwsA(anything));
    });
  });

  group('order fixtures', () {
    test('GET /orders/{id} (200) before the restaurant answers: the answer fields are null', () {
      final json = readApiFixture('orders_retrieve_200');
      final order = Order$Response.fromJson(json);

      expect(order.status.value, 'placed');
      expect(order.orderType.value, 'car');
      expect(order.placedAt, DateTime.utc(2026, 11, 23, 9, 10));
      expect(order.etaMinutes, isNull);
      expect(order.rejectionReasonCode, isNull);
      expect(order.rejectionNote, isNull);
      expect(order.totalMinor, 2500);
      expect(order.toJson(), json);
    });

    test('GET /orders/{id} (200) rejected with a note', () {
      final json = readApiFixture('orders_retrieve_200_rejected');
      final order = Order$Response.fromJson(json);

      expect(order.status.value, 'rejected');
      expect(order.rejectionReasonCode, 'other');
      expect(order.rejectionNote, 'The oven is being repaired.');
      expect(order.toJson(), json);
    });

    test('a status the server adds later is read, not rejected', () {
      final json = Map<String, Object?>.of(readApiFixture('orders_retrieve_200'))..['status'] = 'refunded';

      expect(Order$Response.fromJson(json).status.value, 'refunded');
    });
  });

  group('chat requests', () {
    test('opening a conversation sends the car order type and does not start a new one by default', () {
      expect(const OpenConversationRequest().toJson(), {'start_new': false, 'order_type': 'car'});
      expect(const OpenConversationRequest(locale: LocaleEnum.ar, startNew: true).toJson(), {
        'locale': 'ar',
        'start_new': true,
        'order_type': 'car',
      });
    });

    test('a typed message carries the id and the text, and no action key', () {
      const request = SendMessageRequest(clientMessageId: '5f1e2d3c-0000-4a5b-8c9d-0e1f2a3b4c20', text: 'Latte');

      expect(request.toJson(), {'client_message_id': '5f1e2d3c-0000-4a5b-8c9d-0e1f2a3b4c20', 'text': 'Latte'});
    });

    test('a button carries the id and the action, and no text key', () {
      const request = SendMessageRequest(
        clientMessageId: '5f1e2d3c-0000-4a5b-8c9d-0e1f2a3b4c21',
        action: ActionEnum.confirm,
      );

      expect(request.toJson(), {'client_message_id': '5f1e2d3c-0000-4a5b-8c9d-0e1f2a3b4c21', 'action': 'confirm'});
    });

    test('the position carries lat, lng and source, and leaves accuracy out when unknown', () {
      const plain = LocationRequest(lat: 25.2, lng: 55.3, source: SourceEnum.gps);
      const simulated = LocationRequest(lat: 25.2, lng: 55.3, accuracyM: 12, source: SourceEnum.simulated);

      expect(plain.toJson(), {'lat': 25.2, 'lng': 55.3, 'source': 'gps'});
      expect(simulated.toJson()['accuracy_m'], 12);
      expect(simulated.toJson()['source'], 'simulated');
    });

    test('the item picker sends item ids, quantities and option ids, never a price', () {
      const request = SendMessageRequest(
        clientMessageId: '5f1e2d3c-0000-4a5b-8c9d-0e1f2a3b4c22',
        action: ActionEnum.setLines,
        lines: [
          PickedLineRequest(
            itemId: 'a1b2c3d4-0002-4a5b-8c9d-0e1f2a3b4c02',
            quantity: 2,
            optionIds: ['a1b2c3d4-0005-4a5b-8c9d-0e1f2a3b4c05'],
            note: 'no sugar',
          ),
        ],
      );
      final json = request.toJson();
      final line = (json['lines']! as List<Object?>).single! as Map<String, Object?>;

      expect(json['action'], 'set_lines');
      expect(line.keys.toSet(), {'item_id', 'quantity', 'option_ids', 'note'});
      expect(line['quantity'], 2);
    });
  });

  group('error fixtures keep the one error body', () {
    const names = [
      'throttled_429',
      'authentication_failed_401',
      'not_authenticated_401',
      'permission_denied_403',
      'not_found_404',
      'account_exists_409',
      'validation_error_400',
    ];

    for (final name in names) {
      test(name, () {
        final json = readApiFixture('errors/$name');

        expect(json['type'], anyOf('validation_error', 'client_error', 'server_error'));
        final errors = json['errors']! as List<Object?>;
        expect(errors, isNotEmpty);
        for (final error in errors) {
          expect(error, isA<Map<String, Object?>>());
          final map = error! as Map<String, Object?>;
          expect(map.keys, containsAll(['code', 'detail', 'attr']));
        }
      });
    }
  });
}
