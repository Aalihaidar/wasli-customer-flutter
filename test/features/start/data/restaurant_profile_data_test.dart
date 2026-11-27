import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/network/network_timeouts.dart';
import 'package:wasli_customer/features/start/data/restaurant_profile_mapper.dart';
import 'package:wasli_customer/features/start/data/restaurant_profile_repository_impl.dart';

import '../../../support/api_fixtures.dart';
import '../../../support/fake_http_adapter.dart';
import '../../../support/network_harness.dart';

void main() {
  group('restaurantProfileFromDto', () {
    test('reads the names and the logo', () {
      final profile = restaurantProfileFromDto(
        RestaurantDetail$Response.fromJson(readApiFixture('restaurants_retrieve_200')),
      );

      expect(profile.slug, 'demo-cafe');
      expect(profile.nameEn, 'Demo Cafe');
      expect(profile.nameAr, 'مقهى تجريبي');
      expect(profile.logoUrl, 'https://media.example.com/logos/demo-cafe.png');
      expect(profile.nameFor('ar'), 'مقهى تجريبي');
      expect(profile.nameFor('en'), 'Demo Cafe');
    });

    test('reads a restaurant with no logo', () {
      final json = {...readApiFixture('restaurants_retrieve_200'), 'logo_url': null};

      expect(restaurantProfileFromDto(RestaurantDetail$Response.fromJson(json)).logoUrl, isNull);
    });
  });

  group('RestaurantProfileRepositoryImpl', () {
    test('asks for the slug without a token and waits long enough for a sleeping server', () async {
      final harness = NetworkHarness(
        (_) => jsonResponse(200, readApiFixture('restaurants_retrieve_200')),
        token: 'tok-1',
      );

      final profile = await RestaurantProfileRepositoryImpl(RestaurantsClient(harness.dio)).bySlug('demo-cafe');

      expect(profile.nameEn, 'Demo Cafe');
      final request = harness.adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/api/v1/restaurants/demo-cafe');
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(request.receiveTimeout, NetworkTimeouts.coldStart);
    });

    test('a restaurant that is not active is a NotFoundFailure', () async {
      final harness = NetworkHarness((_) => jsonResponse(404, readApiFixture('errors/not_found_404')));

      await expectLater(
        RestaurantProfileRepositoryImpl(RestaurantsClient(harness.dio)).bySlug('gone-cafe'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('throws a Failure when the server cannot be reached', () async {
      final harness = NetworkHarness((options) => throw connectionFailure(options, DioExceptionType.connectionError));

      await expectLater(
        RestaurantProfileRepositoryImpl(RestaurantsClient(harness.dio)).bySlug('demo-cafe'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
