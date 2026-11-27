import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/network/network_timeouts.dart';
import 'package:wasli_customer/features/start/data/nearby_mapper.dart';
import 'package:wasli_customer/features/start/data/nearby_repository_impl.dart';
import 'package:wasli_customer/features/start/domain/coordinates.dart';

import '../../../support/api_fixtures.dart';
import '../../../support/fake_http_adapter.dart';
import '../../../support/network_harness.dart';

const Coordinates _point = (latitude: 25.2048, longitude: 55.2708);

void main() {
  group('nearbyRestaurantsFromDto', () {
    test('reads the restaurants, nearest first, with and without a service limit and a logo', () {
      final result = nearbyRestaurantsFromDto(
        NearbyResponse$Response.fromJson(readApiFixture('restaurants_nearby_200')),
      );

      expect(result.nearest, isNull);
      final [first, second] = result.restaurants;
      expect(first.slug, 'demo-cafe');
      expect(first.nameEn, 'Demo Cafe');
      expect(first.nameAr, 'مقهى تجريبي');
      expect(first.logoUrl, 'https://media.example.com/logos/demo-cafe.png');
      expect(first.position, (latitude: 25.2048, longitude: 55.2708));
      expect(first.serviceRadiusMetres, 500);
      expect(first.distanceMetres, 120);
      expect(first.isOpen, isTrue);
      expect(second.slug, 'sample-grill');
      expect(second.logoUrl, isNull);
      expect(second.serviceRadiusMetres, isNull);
      expect(second.isOpen, isFalse);
    });

    test('reads the closest restaurant when none serves the point', () {
      final result = nearbyRestaurantsFromDto(
        NearbyResponse$Response.fromJson(readApiFixture('restaurants_nearby_200_empty')),
      );

      expect(result.restaurants, isEmpty);
      expect(result.nearest?.slug, 'demo-cafe');
      expect(result.nearest?.distanceMetres, 2400);
      expect(result.nearest?.serviceRadiusMetres, 500);
    });

    test('reads an answer with no restaurant visible at all', () {
      final result = nearbyRestaurantsFromDto(
        NearbyResponse$Response.fromJson(readApiFixture('restaurants_nearby_200_none_visible')),
      );

      expect(result.restaurants, isEmpty);
      expect(result.nearest, isNull);
    });

    test('picks the name by language and falls back to English for anything but Arabic', () {
      final restaurant = nearbyRestaurantsFromDto(
        NearbyResponse$Response.fromJson(readApiFixture('restaurants_nearby_200')),
      ).restaurants.first;

      expect(restaurant.nameFor('ar'), 'مقهى تجريبي');
      expect(restaurant.nameFor('en'), 'Demo Cafe');
      expect(restaurant.nameFor('fr'), 'Demo Cafe');
    });
  });

  group('NearbyRepositoryImpl', () {
    test('asks with the position, without a token, and waits long enough for a sleeping server', () async {
      final harness = NetworkHarness(
        (_) => jsonResponse(200, readApiFixture('restaurants_nearby_200')),
        token: 'tok-1',
      );

      final result = await NearbyRepositoryImpl(RestaurantsClient(harness.dio)).nearby(_point);

      expect(result.restaurants, hasLength(2));
      final request = harness.adapter.requests.single;
      expect(request.method, 'GET');
      expect(request.path, '/api/v1/restaurants/nearby');
      expect(request.queryParameters, {'lat': 25.2048, 'lng': 55.2708});
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(request.receiveTimeout, NetworkTimeouts.coldStart);
    });

    test('never writes the position to the log', () async {
      final harness = NetworkHarness((_) => jsonResponse(200, readApiFixture('restaurants_nearby_200')));

      await NearbyRepositoryImpl(RestaurantsClient(harness.dio)).nearby(_point);

      expect(harness.logger.lines, isNotEmpty);
      for (final line in harness.logger.lines) {
        expect(line, isNot(contains('25.2')));
        expect(line, isNot(contains('55.2')));
        expect(line, isNot(contains('lat=')));
      }
    });

    test('throws a Failure when the server cannot be reached', () async {
      final harness = NetworkHarness((options) => throw connectionFailure(options, DioExceptionType.connectionError));

      await expectLater(
        NearbyRepositoryImpl(RestaurantsClient(harness.dio)).nearby(_point),
        throwsA(isA<NetworkFailure>().having((f) => f.kind, 'kind', NetworkFailureKind.offline)),
      );
    });

    test('throws a generic Failure when the answer is not what the contract says', () async {
      final harness = NetworkHarness((_) => jsonResponse(200, {'restaurants': 'none'}));

      await expectLater(
        NearbyRepositoryImpl(RestaurantsClient(harness.dio)).nearby(_point),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });
}
