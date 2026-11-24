import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/network/network_timeouts.dart';
import 'package:wasli_customer/core/network/run_api.dart';

import '../../support/api_fixtures.dart';
import '../../support/fake_http_adapter.dart';
import '../../support/network_harness.dart';

void main() {
  group('the base URL and the generated paths', () {
    test('join into one /api/v1, not two', () async {
      final harness = NetworkHarness((_) => jsonResponse(200, readApiFixture('config_200')));

      await ConfigClient(harness.dio).configRetrieve();
      await OrdersClient(harness.dio)
          .ordersRetrieve(id: 'd1b90202-0000-4a5b-8c9d-0e1f2a3b4c30')
          .then<void>((_) {}, onError: (Object _) {});

      expect(harness.adapter.requests.map((r) => r.uri.toString()), [
        'https://api.example.test/api/v1/config',
        'https://api.example.test/api/v1/orders/d1b90202-0000-4a5b-8c9d-0e1f2a3b4c30',
      ]);
    });

    test('every call asks for JSON and has timeouts', () async {
      final harness = NetworkHarness((_) => jsonResponse(200, readApiFixture('config_200')));

      await ConfigClient(harness.dio).configRetrieve();

      final request = harness.adapter.requests.single;
      expect(request.headers['Accept'], 'application/json');
      expect(request.connectTimeout, NetworkTimeouts.connect);
      expect(request.receiveTimeout, NetworkTimeouts.receive);
      expect(request.sendTimeout, NetworkTimeouts.send);
    });

    test('a call can ask for the longer limit of a cold start', () async {
      final harness = NetworkHarness((_) => jsonResponse(200, readApiFixture('config_200')));

      await ConfigClient(harness.dio).configRetrieve(options: Options(receiveTimeout: NetworkTimeouts.coldStart));

      expect(harness.adapter.requests.single.receiveTimeout, NetworkTimeouts.coldStart);
      expect(NetworkTimeouts.coldStart, greaterThan(const Duration(seconds: 60)));
    });
  });

  group('runApi', () {
    test('returns the parsed answer', () async {
      final harness = NetworkHarness((_) => jsonResponse(200, readApiFixture('config_200')));

      final config = await runApi(() => ConfigClient(harness.dio).configRetrieve());

      expect(config.aiEnabled, isTrue);
    });

    test('turns an error body into the failure of its status and keeps the request id', () async {
      final harness = NetworkHarness(
        (_) => jsonResponse(404, readApiFixture('errors/not_found_404'), headers: {'x-request-id': 'req-123'}),
      );

      await expectLater(
        runApi(() => RestaurantsClient(harness.dio).restaurantsRetrieve(slug: 'nobody')),
        throwsA(isA<NotFoundFailure>().having((f) => f.requestId, 'requestId', 'req-123')),
      );
    });

    test('turns a 429 into a throttled failure with the wait', () async {
      final harness = NetworkHarness(
        (_) => jsonResponse(429, readApiFixture('errors/throttled_429'), headers: {'retry-after': '7'}),
      );

      await expectLater(
        runApi(() => CustomersClient(harness.dio).customersMe()),
        throwsA(isA<ThrottledFailure>().having((f) => f.retryAfter, 'retryAfter', const Duration(seconds: 7))),
      );
    });

    test('turns a page that is not JSON (a proxy, an error page) into a generic failure of its status', () async {
      final harness = NetworkHarness((_) => htmlResponse(502, '<html>Bad gateway</html>'));

      await expectLater(
        runApi(() => RestaurantsClient(harness.dio).restaurantsRetrieve(slug: 'demo-cafe')),
        throwsA(isA<UnexpectedFailure>().having((f) => f.statusCode, 'statusCode', 502)),
      );
    });

    test('turns a 200 answer that does not read as the contract into a generic failure', () async {
      final wrongShape = NetworkHarness((_) => htmlResponse(200, '<html>not the API</html>'));
      final missingKey = NetworkHarness((_) => jsonResponse(200, {'ai_enabled': true}));

      await expectLater(runApi(() => ConfigClient(wrongShape.dio).configRetrieve()), throwsA(isA<UnexpectedFailure>()));
      await expectLater(runApi(() => ConfigClient(missingKey.dio).configRetrieve()), throwsA(isA<UnexpectedFailure>()));
    });

    test('lets a failure through unchanged', () async {
      const failure = NotFoundFailure(requestId: 'abc');

      await expectLater(runApi<void>(() async => throw failure), throwsA(same(failure)));
    });
  });
}
