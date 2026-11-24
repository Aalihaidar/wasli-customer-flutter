import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/error/api_issue.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/failure_text.dart';
import 'package:wasli_customer/core/l10n/generated/app_localizations_ar.dart';
import 'package:wasli_customer/core/l10n/generated/app_localizations_en.dart';

void main() {
  final en = AppLocalizationsEn();
  final ar = AppLocalizationsAr();
  const issue = ApiIssue(code: 'whatever');

  group('failureText', () {
    test('names an offline phone, a timeout, a throttle and an ended session', () {
      expect(failureText(en, const NetworkFailure(NetworkFailureKind.offline)), en.failureOffline);
      expect(failureText(en, const NetworkFailure(NetworkFailureKind.timeout)), en.failureTimeout);
      expect(failureText(en, const ThrottledFailure()), en.failureThrottled);
      expect(failureText(en, const UnauthenticatedFailure()), en.failureSessionEnded);
    });

    test('uses the generic text for everything else', () {
      final others = <Failure>[
        const NetworkFailure(NetworkFailureKind.cancelled),
        const AccountNotVerifiedFailure(),
        const PermissionDeniedFailure(),
        const NotFoundFailure(),
        const ValidationFailure([issue]),
        const ConflictFailure([issue]),
        const RequestRejectedFailure(413, [issue]),
        const UnexpectedFailure(statusCode: 500),
      ];

      for (final failure in others) {
        expect(failureText(en, failure), en.failureGeneric, reason: '$failure');
      }
    });

    test('has an Arabic text for each', () {
      expect(failureText(ar, const NetworkFailure(NetworkFailureKind.offline)), ar.failureOffline);
      expect(failureText(ar, const NotFoundFailure()), ar.failureGeneric);
      expect(ar.failureGeneric, isNot(en.failureGeneric));
    });
  });
}
