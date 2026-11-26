import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/error/failure_mapper.dart';

Map<String, Object?> _body(String code) => {
  'type': 'client_error',
  'errors': [
    {'code': code, 'detail': 'Detail text.', 'attr': null},
  ],
};

void main() {
  group('account_not_verified', () {
    test('is its own failure at 403, as the contract says for sign-in', () {
      final failure = failureFromResponse(statusCode: 403, data: _body('account_not_verified'));

      expect(failure, isA<AccountNotVerifiedFailure>());
    });

    test('is the same failure whatever 4xx status the server chose for it', () {
      for (final status in [400, 409, 422]) {
        expect(
          failureFromResponse(statusCode: status, data: _body('account_not_verified')),
          isA<AccountNotVerifiedFailure>(),
          reason: '$status',
        );
      }
    });

    test('a 403 with another code is still permission denied', () {
      expect(failureFromResponse(statusCode: 403, data: _body('permission_denied')), isA<PermissionDeniedFailure>());
      expect(failureFromResponse(statusCode: 403, data: 'not json'), isA<PermissionDeniedFailure>());
    });

    test('a 5xx is never read as this failure', () {
      expect(failureFromResponse(statusCode: 500, data: _body('account_not_verified')), isA<UnexpectedFailure>());
    });
  });
}
