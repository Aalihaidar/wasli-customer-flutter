import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/network/run_api.dart';

import '../../support/api_fixtures.dart';
import '../../support/fake_http_adapter.dart';
import '../../support/network_harness.dart';

ResponseBody _config() => jsonResponse(200, readApiFixture('config_200'));
ResponseBody _unavailable({Map<String, String> headers = const {}}) => jsonResponse(503, {
  'type': 'server_error',
  'errors': [
    {'code': 'error', 'detail': 'Temporarily down.', 'attr': null},
  ],
}, headers: headers);

void main() {
  group('a GET that fails', () {
    test('is tried again after a 503 and succeeds, with one pause', () async {
      var calls = 0;
      final harness = NetworkHarness((_) => ++calls == 1 ? _unavailable() : _config());

      final config = await runApi(() => ConfigClient(harness.dio).configRetrieve());

      expect(config.pollIntervalSeconds, 3);
      expect(harness.adapter.requests, hasLength(2));
      expect(harness.pauses, [const Duration(milliseconds: 500)]);
    });

    test('is tried at most three times, with a pause that doubles, and then fails with the status', () async {
      final harness = NetworkHarness((_) => jsonResponse(500, {'type': 'server_error', 'errors': <Object?>[]}));

      await expectLater(
        runApi(() => ConfigClient(harness.dio).configRetrieve()),
        throwsA(isA<UnexpectedFailure>().having((f) => f.statusCode, 'statusCode', 500)),
      );

      expect(harness.adapter.requests, hasLength(3));
      expect(harness.pauses, [const Duration(milliseconds: 500), const Duration(seconds: 1)]);
    });

    test('waits for a Retry-After that is longer than the pause', () async {
      var calls = 0;
      final harness = NetworkHarness((_) => ++calls == 1 ? _unavailable(headers: {'retry-after': '3'}) : _config());

      await runApi(() => ConfigClient(harness.dio).configRetrieve());

      expect(harness.pauses, [const Duration(seconds: 3)]);
    });

    test('is not retried when the Retry-After is longer than the app waits', () async {
      final harness = NetworkHarness((_) => _unavailable(headers: {'retry-after': '60'}));

      await expectLater(runApi(() => ConfigClient(harness.dio).configRetrieve()), throwsA(isA<UnexpectedFailure>()));

      expect(harness.adapter.requests, hasLength(1));
      expect(harness.pauses, isEmpty);
    });

    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ]) {
      test('is tried again after $type', () async {
        var calls = 0;
        final harness = NetworkHarness((options) => ++calls == 1 ? throw connectionFailure(options, type) : _config());

        await runApi(() => ConfigClient(harness.dio).configRetrieve());

        expect(harness.adapter.requests, hasLength(2));
      });
    }

    test('fails as a timeout when every try times out', () async {
      final harness = NetworkHarness((options) => throw connectionFailure(options, DioExceptionType.receiveTimeout));

      await expectLater(
        runApi(() => ConfigClient(harness.dio).configRetrieve()),
        throwsA(isA<NetworkFailure>().having((f) => f.kind, 'kind', NetworkFailureKind.timeout)),
      );

      expect(harness.adapter.requests, hasLength(3));
    });

    test('is never retried at once after a 429, and the failure carries the Retry-After', () async {
      final harness = NetworkHarness(
        (_) => jsonResponse(429, readApiFixture('errors/throttled_429'), headers: {'retry-after': '12'}),
      );

      await expectLater(
        runApi(() => ConfigClient(harness.dio).configRetrieve()),
        throwsA(isA<ThrottledFailure>().having((f) => f.retryAfter, 'retryAfter', const Duration(seconds: 12))),
      );

      expect(harness.adapter.requests, hasLength(1));
      expect(harness.pauses, isEmpty);
    });

    test('is not retried after a 404 or a cancel', () async {
      final notFound = NetworkHarness((_) => jsonResponse(404, readApiFixture('errors/not_found_404')));
      await expectLater(runApi(() => ConfigClient(notFound.dio).configRetrieve()), throwsA(isA<NotFoundFailure>()));
      expect(notFound.adapter.requests, hasLength(1));

      final cancelled = NetworkHarness((options) => throw connectionFailure(options, DioExceptionType.cancel));
      await expectLater(
        runApi(() => ConfigClient(cancelled.dio).configRetrieve()),
        throwsA(isA<NetworkFailure>().having((f) => f.kind, 'kind', NetworkFailureKind.cancelled)),
      );
      expect(cancelled.adapter.requests, hasLength(1));
    });
  });

  group('a POST that fails', () {
    test('is never retried, even after a 503 or a timeout', () async {
      const signup = SignupRequest$Request(
        fullName: 'Sara Test',
        email: 'sara@example.com',
        password: 'a-long-password-1',
        locale: LocaleEnum.en,
      );
      final unavailable = NetworkHarness((_) => _unavailable());
      await expectLater(
        runApi(() => CustomersClient(unavailable.dio).customersSignup(body: signup)),
        throwsA(isA<UnexpectedFailure>()),
      );
      expect(unavailable.adapter.requests, hasLength(1));

      final timeout = NetworkHarness((options) => throw connectionFailure(options, DioExceptionType.receiveTimeout));
      await expectLater(
        runApi(() => CustomersClient(timeout.dio).customersSignup(body: signup)),
        throwsA(isA<NetworkFailure>()),
      );
      expect(timeout.adapter.requests, hasLength(1));
      expect([unavailable.pauses, timeout.pauses], everyElement(isEmpty));
    });
  });
}
