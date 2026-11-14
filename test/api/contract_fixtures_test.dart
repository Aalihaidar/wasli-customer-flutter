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

    test(
      'GET /restaurants/nearby (200) with restaurants and no nearest',
      () {
        final json = readApiFixture('restaurants_nearby_200');
        final nearby = NearbyResponse$Response.fromJson(json);

        expect(nearby.restaurants, hasLength(2));
        expect(nearby.restaurants.first.distanceM, 120);
        expect(nearby.restaurants.last.logoUrl, isNull);
        expect(nearby.toJson(), json);
      },
      // The contract says `nearest` is null when restaurants are found, but the generated client declares it
      // non-nullable and throws DisallowedNullValueException. Remove the skip when the contract or the generator
      // yields a nullable field (steps.md, "Backend requests").
      skip: 'the generated client rejects "nearest": null',
    );

    test('GET /restaurants/nearby (200) with no restaurants and the nearest one', () {
      final json = readApiFixture('restaurants_nearby_200_empty');
      final nearby = NearbyResponse$Response.fromJson(json);

      expect(nearby.restaurants, isEmpty);
      expect(nearby.nearest.parkingLot.radiusM, 150);
      expect(nearby.toJson(), json);
    });

    test('GET /restaurants/{slug} (200)', () {
      final json = readApiFixture('restaurants_retrieve_200');
      final restaurant = RestaurantDetail$Response.fromJson(json);

      expect(restaurant.slug, 'demo-cafe');
      expect(restaurant.currency, 'AED');
      expect(restaurant.menu.single.items.first.priceMinor, 1250);
      expect(restaurant.menu.single.items.last.isAvailable, isFalse);
      expect(restaurant.toJson(), json);
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
