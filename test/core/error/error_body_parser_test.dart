import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/error/api_error_code.dart';
import 'package:wasli_customer/core/error/error_body_parser.dart';

import '../../support/api_fixtures.dart';

void main() {
  group('parseErrorBody', () {
    test('reads the contract example of a throttled call', () {
      final issues = parseErrorBody(readApiFixture('errors/throttled_429'));

      expect(issues, hasLength(1));
      expect(issues!.single.code, 'throttled');
      expect(issues.single.attr, isNull);
      expect(issues.single.known, ApiErrorCode.throttled);
    });

    test('keeps every issue in order with its field', () {
      final issues = parseErrorBody(readApiFixture('errors/validation_error_400'))!;

      expect(issues.map((issue) => issue.code), ['password_too_common', 'required']);
      expect(issues.map((issue) => issue.attr), ['password', 'full_name']);
      expect(issues.first.isPasswordRule, isTrue);
      expect(issues.last.isPasswordRule, isFalse);
    });

    test('an unknown code is kept as written and reads as unknown', () {
      final issues = parseErrorBody({
        'type': 'client_error',
        'errors': [
          {'code': 'a_code_from_the_future', 'detail': 'x', 'attr': null},
        ],
      })!;

      expect(issues.single.code, 'a_code_from_the_future');
      expect(issues.single.known, ApiErrorCode.unknown);
    });

    test('skips entries without a usable code and keeps the rest', () {
      final issues = parseErrorBody({
        'type': 'validation_error',
        'errors': [
          'not a map',
          {'detail': 'no code'},
          {'code': '', 'detail': 'empty code'},
          {'code': 7, 'detail': 'number code'},
          {'code': 'code_invalid', 'detail': 'ok', 'attr': 5},
        ],
      })!;

      expect(issues.single.code, 'code_invalid');
      expect(issues.single.attr, isNull);
    });

    test('anything that is not the error body is null', () {
      expect(parseErrorBody(null), isNull);
      expect(parseErrorBody('<html>502 Bad Gateway</html>'), isNull);
      expect(parseErrorBody(<Object?>[]), isNull);
      expect(parseErrorBody(<String, Object?>{}), isNull);
      expect(parseErrorBody({'errors': 'nope'}), isNull);
      expect(parseErrorBody({'errors': <Object?>[]}), isNull);
    });
  });

  group('ApiErrorCode.fromWire', () {
    test('finds every listed code by its wire name', () {
      for (final code in ApiErrorCode.values.where((code) => code != ApiErrorCode.unknown)) {
        expect(ApiErrorCode.fromWire(code.wire), code);
      }
    });

    test('an empty or unlisted name is unknown', () {
      expect(ApiErrorCode.fromWire(''), ApiErrorCode.unknown);
      expect(ApiErrorCode.fromWire('nope'), ApiErrorCode.unknown);
    });
  });
}
