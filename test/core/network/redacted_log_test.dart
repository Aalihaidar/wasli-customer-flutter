import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/network/run_api.dart';

import '../../support/api_fixtures.dart';
import '../../support/fake_http_adapter.dart';
import '../../support/network_harness.dart';

const _token = 'tok-SECRET-8f3a91c2';
const _password = 'P4ssw0rd-SECRET-77';
const _email = 'sara.secret@example.com';
const _lat = '25.123456';
const _lng = '55.654321';
const _detail = 'Authentication credentials were not provided.';

void main() {
  group('the log of the network calls', () {
    test('never holds a token, a body, a query string, a position or the server text', () async {
      final harness = NetworkHarness((options) {
        return switch (options.path) {
          '/api/v1/restaurants/nearby' => jsonResponse(
            200,
            readApiFixture('restaurants_nearby_200'),
            headers: {'x-request-id': 'req-nearby'},
          ),
          '/api/v1/customers/signup' => jsonResponse(201, readApiFixture('customers_signup_201')),
          _ => jsonResponse(401, readApiFixture('errors/not_authenticated_401'), headers: {'x-request-id': 'req-me'}),
        };
      }, token: _token);

      await RestaurantsClient(harness.dio).restaurantsNearby(lat: double.parse(_lat), lng: double.parse(_lng));
      await CustomersClient(harness.dio).customersSignup(
        body: const SignupRequest$Request(
          fullName: 'Sara Secret',
          email: _email,
          password: _password,
          locale: LocaleEnum.en,
        ),
      );
      await runApi(() => CustomersClient(harness.dio).customersMe()).then<void>((_) {}, onError: (Object _) {});

      final log = harness.logger.lines.join('\n');
      expect(log, isNotEmpty);
      for (final secret in [
        _token,
        _password,
        _email,
        'Sara Secret',
        _lat,
        _lng,
        'lat=',
        'lng=',
        '?',
        _detail,
        'Authorization',
        'Customer ',
      ]) {
        expect(log, isNot(contains(secret)), reason: 'the log must not contain "$secret"');
      }
    });

    test('says what happened in names and numbers: method, path, status, time and request id', () async {
      final harness = NetworkHarness(
        (options) => options.path.endsWith('/nearby')
            ? jsonResponse(200, readApiFixture('restaurants_nearby_200'), headers: {'x-request-id': 'req-nearby'})
            : jsonResponse(401, readApiFixture('errors/not_authenticated_401'), headers: {'x-request-id': 'req-me'}),
        token: _token,
      );

      await RestaurantsClient(harness.dio).restaurantsNearby(lat: 25.1, lng: 55.2);
      await runApi(() => CustomersClient(harness.dio).customersMe()).then<void>((_) {}, onError: (Object _) {});

      expect(harness.logger.lines, hasLength(2));
      expect(
        harness.logger.lines[0],
        matches(RegExp(r'^debug: GET /api/v1/restaurants/nearby -> 200 \(\d+ ms, request req-nearby\)$')),
      );
      expect(
        harness.logger.lines[1],
        matches(RegExp(r'^warning: GET /api/v1/customers/me !! 401 \(\d+ ms, request req-me\)$')),
      );
    });

    test('names the failure type when no answer arrived', () async {
      final harness = NetworkHarness((options) => throw connectionFailure(options, DioExceptionType.connectionError));

      await runApi(() => ConfigClient(harness.dio).configRetrieve()).then<void>((_) {}, onError: (Object _) {});

      expect(harness.logger.lines, hasLength(3), reason: 'one line for each of the three tries');
      expect(harness.logger.lines.first, startsWith('warning: GET /api/v1/config !! connectionError'));
    });
  });
}
