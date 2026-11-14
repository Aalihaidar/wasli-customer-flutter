import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/error/api_error_code.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/error/failure_mapper.dart';

import '../../support/api_fixtures.dart';

void main() {
  group('failureFromResponse', () {
    test('401 is unauthenticated, for both contract examples', () {
      for (final name in ['authentication_failed_401', 'not_authenticated_401']) {
        final failure = failureFromResponse(statusCode: 401, data: readApiFixture('errors/$name'));

        expect(failure, isA<UnauthenticatedFailure>());
      }
    });

    test('401 and 404 do not need a readable body', () {
      expect(failureFromResponse(statusCode: 401, data: null), isA<UnauthenticatedFailure>());
      expect(failureFromResponse(statusCode: 404, data: '<html>Not Found</html>'), isA<NotFoundFailure>());
    });

    test('403 permission_denied is a permission failure', () {
      final failure = failureFromResponse(statusCode: 403, data: readApiFixture('errors/permission_denied_403'));

      expect(failure, isA<PermissionDeniedFailure>());
    });

    test('403 account_not_verified opens the code screen', () {
      final failure = failureFromResponse(
        statusCode: 403,
        data: {
          'type': 'client_error',
          'errors': [
            {'code': 'account_not_verified', 'detail': 'x', 'attr': null},
          ],
        },
      );

      expect(failure, isA<AccountNotVerifiedFailure>());
    });

    test('403 with an unknown code is still a permission failure', () {
      final failure = failureFromResponse(
        statusCode: 403,
        data: {
          'type': 'client_error',
          'errors': [
            {'code': 'new_reason', 'detail': 'x', 'attr': null},
          ],
        },
      );

      expect(failure, isA<PermissionDeniedFailure>());
    });

    test('404 is not found', () {
      final failure = failureFromResponse(statusCode: 404, data: readApiFixture('errors/not_found_404'));

      expect(failure, isA<NotFoundFailure>());
    });

    test('400 keeps the issues of the validation error', () {
      final failure = failureFromResponse(statusCode: 400, data: readApiFixture('errors/validation_error_400'));

      expect(failure, isA<ValidationFailure>());
      final validation = failure as ValidationFailure;
      expect(validation.issues, hasLength(2));
      expect(validation.issueFor('password')?.isPasswordRule, isTrue);
      expect(validation.issueFor('email'), isNull);
    });

    test('400 reports a wrong or expired code through its issues', () {
      final failure = failureFromResponse(
        statusCode: 400,
        data: {
          'type': 'validation_error',
          'errors': [
            {'code': 'code_expired', 'detail': 'x', 'attr': 'code'},
          ],
        },
      ) as ValidationFailure;

      expect(failure.has(ApiErrorCode.codeExpired), isTrue);
      expect(failure.has(ApiErrorCode.codeInvalid), isFalse);
    });

    test('409 account_exists is a conflict', () {
      final failure = failureFromResponse(statusCode: 409, data: readApiFixture('errors/account_exists_409'));

      expect(failure, isA<ConflictFailure>());
      expect((failure as ConflictFailure).has(ApiErrorCode.accountExists), isTrue);
    });

    test('429 throttled carries Retry-After', () {
      final failure = failureFromResponse(
        statusCode: 429,
        data: readApiFixture('errors/throttled_429'),
        retryAfter: const Duration(seconds: 30),
      ) as ThrottledFailure;

      expect(failure.retryAfter, const Duration(seconds: 30));
      expect(failure.tooManyAttempts, isFalse);
    });

    test('429 too_many_attempts says so, with or without Retry-After', () {
      final failure = failureFromResponse(
        statusCode: 429,
        data: {
          'type': 'client_error',
          'errors': [
            {'code': 'too_many_attempts', 'detail': 'x', 'attr': null},
          ],
        },
      ) as ThrottledFailure;

      expect(failure.tooManyAttempts, isTrue);
      expect(failure.retryAfter, isNull);
    });

    test('another 4xx with a readable body is a rejected request', () {
      final failure = failureFromResponse(
        statusCode: 413,
        data: {
          'type': 'client_error',
          'errors': [
            {'code': 'request_too_large', 'detail': 'x', 'attr': null},
          ],
        },
      ) as RequestRejectedFailure;

      expect(failure.statusCode, 413);
      expect(failure.has(ApiErrorCode.requestTooLarge), isTrue);
    });

    test('a 4xx with an unreadable body is a generic failure of its status', () {
      final failure = failureFromResponse(statusCode: 418, data: 'teapot') as UnexpectedFailure;

      expect(failure.statusCode, 418);
    });

    test('a 400 or 409 with an unreadable body is a generic failure too', () {
      expect(failureFromResponse(statusCode: 400, data: '<html></html>'), isA<UnexpectedFailure>());
      expect(failureFromResponse(statusCode: 409, data: null), isA<UnexpectedFailure>());
    });

    test('5xx is a generic failure, even with a well-formed error body', () {
      final failure = failureFromResponse(
        statusCode: 503,
        data: {
          'type': 'server_error',
          'errors': [
            {'code': 'maintenance', 'detail': 'x', 'attr': null},
          ],
        },
        requestId: 'req-1',
      ) as UnexpectedFailure;

      expect(failure.statusCode, 503);
      expect(failure.requestId, 'req-1');
    });

    test('an unknown code on a 400 is kept for the screen to ignore', () {
      final failure = failureFromResponse(
        statusCode: 400,
        data: {
          'type': 'validation_error',
          'errors': [
            {'code': 'a_code_from_the_future', 'detail': 'x', 'attr': 'name'},
          ],
        },
      ) as ValidationFailure;

      expect(failure.issues.single.known, ApiErrorCode.unknown);
      expect(failure.has(ApiErrorCode.codeInvalid), isFalse);
    });

    test('the request id travels on every family', () {
      expect(failureFromResponse(statusCode: 401, data: null, requestId: 'r').requestId, 'r');
      expect(failureFromResponse(statusCode: 404, data: null, requestId: 'r').requestId, 'r');
      expect(failureFromResponse(statusCode: 429, data: null, requestId: 'r').requestId, 'r');
      expect(failureFromResponse(statusCode: 403, data: null, requestId: 'r').requestId, 'r');
    });
  });
}
