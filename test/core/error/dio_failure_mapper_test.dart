import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/error/dio_failure_mapper.dart';
import 'package:wasli_customer/core/error/failure.dart';

import '../../support/api_fixtures.dart';

void main() {
  final options = RequestOptions(path: '/api/v1/config');

  DioException badResponse(int status, Object? data, {Map<String, List<String>> headers = const {}}) {
    return DioException.badResponse(
      statusCode: status,
      requestOptions: options,
      response: Response<Object?>(
        requestOptions: options,
        statusCode: status,
        data: data,
        headers: Headers.fromMap(headers),
      ),
    );
  }

  group('failureFromDioException', () {
    test('a throttled response carries Retry-After and the request id from its headers', () {
      final failure = failureFromDioException(
        badResponse(
          429,
          readApiFixture('errors/throttled_429'),
          headers: {
            'retry-after': ['45'],
            'x-request-id': ['req-42'],
          },
        ),
      ) as ThrottledFailure;

      expect(failure.retryAfter, const Duration(seconds: 45));
      expect(failure.requestId, 'req-42');
    });

    test('a Retry-After that is not a number of seconds reads as not said', () {
      for (final value in ['soon', '-5', 'Wed, 21 Oct 2026 07:28:00 GMT']) {
        final failure = failureFromDioException(
          badResponse(
            429,
            null,
            headers: {
              'retry-after': [value],
            },
          ),
        ) as ThrottledFailure;

        expect(failure.retryAfter, isNull, reason: value);
      }
    });

    test('a validation response keeps its issues', () {
      final failure = failureFromDioException(badResponse(400, readApiFixture('errors/validation_error_400')));

      expect(failure, isA<ValidationFailure>());
    });

    test('a proxy page is a generic failure of its status', () {
      final failure = failureFromDioException(badResponse(502, '<html>Bad Gateway</html>')) as UnexpectedFailure;

      expect(failure.statusCode, 502);
    });

    test('every kind of timeout is a timeout', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
      ]) {
        final failure = failureFromDioException(DioException(requestOptions: options, type: type));

        expect((failure as NetworkFailure).kind, NetworkFailureKind.timeout, reason: '$type');
      }
    });

    test('a connection error is offline', () {
      final failure = failureFromDioException(
        DioException.connectionError(requestOptions: options, reason: 'no route'),
      ) as NetworkFailure;

      expect(failure.kind, NetworkFailureKind.offline);
    });

    test('a cancelled request is reported as cancelled, not as an error of the server', () {
      final failure = failureFromDioException(
        DioException.requestCancelled(requestOptions: options, reason: 'x'),
      ) as NetworkFailure;

      expect(failure.kind, NetworkFailureKind.cancelled);
    });

    test('an unknown error without a response is a generic failure with no status', () {
      final failure = failureFromDioException(DioException(requestOptions: options)) as UnexpectedFailure;

      expect(failure.statusCode, isNull);
    });
  });
}
