import 'package:wasli_customer/core/error/api_error_code.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/failure_text.dart';
import 'package:wasli_customer/core/l10n/generated/app_localizations.dart';

/// What to tell the customer when the sign-up call failed. Written from the failure's code, never from server text.
String signUpFailureText(AppLocalizations l10n, Object error) {
  if (error is ConflictFailure && error.has(ApiErrorCode.accountExists)) {
    return l10n.signUpAccountExists;
  }
  if (error is ValidationFailure) {
    return error.issues.any((issue) => issue.isPasswordRule) ? l10n.signUpPasswordRejected : l10n.signUpCheckFields;
  }
  return _generic(l10n, error);
}

/// What to tell the customer when signing in failed. A refused email, phone number or password is one message, so the
/// page never reveals which of them was wrong or whether the account exists.
String signInFailureText(AppLocalizations l10n, Object error) {
  return switch (error) {
    UnauthenticatedFailure() || ValidationFailure() || RequestRejectedFailure() => l10n.signInWrongCredentials,
    PermissionDeniedFailure() => l10n.signInPermissionDenied,
    _ => _generic(l10n, error),
  };
}

/// What to tell the customer when confirming or resending a code failed.
String codeFailureText(AppLocalizations l10n, Object error) {
  if (_has(error, ApiErrorCode.codeInvalid)) {
    return l10n.verifyCodeInvalid;
  }
  if (_has(error, ApiErrorCode.codeExpired)) {
    return l10n.verifyCodeExpired;
  }
  if (error is ThrottledFailure && error.tooManyAttempts) {
    return l10n.verifyTooManyAttempts;
  }
  if (error is ValidationFailure) {
    return l10n.signUpCheckFields;
  }
  return _generic(l10n, error);
}

bool _has(Object error, ApiErrorCode code) => switch (error) {
  ValidationFailure() => error.has(code),
  ConflictFailure() => error.has(code),
  RequestRejectedFailure() => error.has(code),
  _ => false,
};

String _generic(AppLocalizations l10n, Object error) =>
    error is Failure ? failureText(l10n, error) : l10n.failureGeneric;
