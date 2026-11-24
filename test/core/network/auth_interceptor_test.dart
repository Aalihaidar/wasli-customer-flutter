import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/network/auth_interceptor.dart';
import 'package:wasli_customer/core/network/run_api.dart';

import '../../support/api_fixtures.dart';
import '../../support/fake_http_adapter.dart';
import '../../support/network_harness.dart';

const _orderId = 'd1b90202-0000-4a5b-8c9d-0e1f2a3b4c30';

ResponseBody _notAuthenticated() => jsonResponse(401, readApiFixture('errors/not_authenticated_401'));

void main() {
  group('which calls need the token', () {
    RequestOptions optionsWith(Object? security) => RequestOptions(extra: {'openapi.security': ?security});

    test('only an operation that names customerAuth', () {
      expect(
        AuthInterceptor.requiresCustomerToken(
          optionsWith(const [
            {'customerAuth': <Object?>[]},
          ]),
        ),
        isTrue,
      );
      expect(AuthInterceptor.requiresCustomerToken(optionsWith(const [<String, Object?>{}])), isFalse);
      expect(AuthInterceptor.requiresCustomerToken(optionsWith(const <Object?>[])), isFalse);
    });

    test('an operation that allows both a token and none gets the token when there is one', () {
      expect(
        AuthInterceptor.requiresCustomerToken(
          optionsWith(const [
            <String, Object?>{},
            {'customerAuth': <Object?>[]},
          ]),
        ),
        isTrue,
      );
    });

    test('a call the generated client did not describe is sent without a token', () {
      expect(AuthInterceptor.requiresCustomerToken(optionsWith(null)), isFalse);
      expect(AuthInterceptor.requiresCustomerToken(optionsWith('customerAuth')), isFalse);
    });
  });

  group('the Authorization header', () {
    test('is Customer <token> on a call that needs it', () async {
      final harness = NetworkHarness((_) => jsonResponse(200, readApiFixture('customers_me_200')), token: 'tok-1');

      await CustomersClient(harness.dio).customersMe();
      await OrdersClient(harness.dio).ordersRetrieve(id: _orderId).then<void>((_) {}, onError: (Object _) {});

      expect(harness.adapter.requests.map((r) => r.headers['Authorization']), ['Customer tok-1', 'Customer tok-1']);
    });

    test('is absent on every public call, even when a token is stored', () async {
      final harness = NetworkHarness((options) {
        return switch (options.path) {
          '/api/v1/config' => jsonResponse(200, readApiFixture('config_200')),
          '/api/v1/restaurants/nearby' => jsonResponse(200, readApiFixture('restaurants_nearby_200')),
          _ => jsonResponse(201, readApiFixture('customers_signup_201')),
        };
      }, token: 'tok-1');

      await ConfigClient(harness.dio).configRetrieve();
      await RestaurantsClient(harness.dio).restaurantsNearby(lat: 25.1, lng: 55.2);
      await CustomersClient(harness.dio).customersSignup(
        body: const SignupRequest$Request(
          fullName: 'Sara Test',
          email: 'sara@example.com',
          password: 'a-long-password-1',
          locale: LocaleEnum.en,
        ),
      );

      expect(harness.adapter.requests, hasLength(3));
      for (final request in harness.adapter.requests) {
        expect(
          request.headers.keys.map((k) => k.toLowerCase()),
          isNot(contains('authorization')),
          reason: request.path,
        );
      }
    });

    test('a header set by hand on a public call is removed', () async {
      final harness = NetworkHarness((_) => jsonResponse(200, readApiFixture('config_200')), token: 'tok-1');

      await ConfigClient(harness.dio).configRetrieve(options: Options(headers: {'authorization': 'Customer stolen'}));

      expect(
        harness.adapter.requests.single.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('authorization')),
      );
    });

    test('is absent when nobody is signed in, and the call still goes out', () async {
      final harness = NetworkHarness((_) => _notAuthenticated());

      await expectLater(
        runApi(() => CustomersClient(harness.dio).customersMe()),
        throwsA(isA<UnauthenticatedFailure>()),
      );

      expect(harness.adapter.requests.single.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('a 401 on a call that carried the token', () {
    test('clears the token and ends the session, and is an UnauthenticatedFailure', () async {
      final harness = NetworkHarness((_) => _notAuthenticated(), token: 'tok-1');

      await expectLater(
        runApi(() => CustomersClient(harness.dio).customersMe()),
        throwsA(isA<UnauthenticatedFailure>()),
      );

      expect(await harness.store.read(), isNull);
      expect(harness.sessionExpiredCount, 1);
    });

    test('ends the session once when several calls fail together', () async {
      final harness = NetworkHarness((_) => _notAuthenticated(), token: 'tok-1');
      final client = CustomersClient(harness.dio);

      final results = await Future.wait([
        for (var i = 0; i < 3; i++) runApi(client.customersMe).then<Object?>((_) => null, onError: (Object e) => e),
      ]);

      expect(results, everyElement(isA<UnauthenticatedFailure>()));
      expect(harness.sessionExpiredCount, 1);
      expect(harness.adapter.requests, hasLength(3), reason: 'a 401 is not retried');
    });

    test('does not end a newer session: the token stored now is not the one that was refused', () async {
      late NetworkHarness harness;
      harness = NetworkHarness((_) async {
        await harness.store.write('tok-2');
        return _notAuthenticated();
      }, token: 'tok-1');

      await expectLater(
        runApi(() => CustomersClient(harness.dio).customersMe()),
        throwsA(isA<UnauthenticatedFailure>()),
      );

      expect(await harness.store.read(), 'tok-2');
      expect(harness.sessionExpiredCount, 0);
    });

    test('a 401 on a public call (a wrong password) leaves a stored token alone', () async {
      final harness = NetworkHarness(
        (_) => jsonResponse(401, readApiFixture('errors/authentication_failed_401')),
        token: 'tok-1',
      );

      await expectLater(
        runApi(
          () => CustomersClient(harness.dio).customersLogin(
            body: const LoginRequest$Request(identifier: 'sara@example.com', password: 'a-long-password-1'),
          ),
        ),
        throwsA(isA<UnauthenticatedFailure>()),
      );

      expect(await harness.store.read(), 'tok-1');
      expect(harness.sessionExpiredCount, 0);
    });
  });
}
