import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/generated/app_localizations.dart';

/// The text that tells the customer what went wrong, in the active language.
///
/// It is written from the kind of [failure] only: server text is never shown. A screen that knows more about its own
/// calls (a sign-up that says "this e-mail is already used") writes its own text before falling back to this one.
String failureText(AppLocalizations l10n, Failure failure) {
  return switch (failure) {
    NetworkFailure(kind: NetworkFailureKind.offline) => l10n.failureOffline,
    NetworkFailure(kind: NetworkFailureKind.timeout) => l10n.failureTimeout,
    ThrottledFailure() => l10n.failureThrottled,
    UnauthenticatedFailure() => l10n.failureSessionEnded,
    NetworkFailure() ||
    AccountNotVerifiedFailure() ||
    PermissionDeniedFailure() ||
    NotFoundFailure() ||
    ValidationFailure() ||
    ConflictFailure() ||
    RequestRejectedFailure() ||
    UnexpectedFailure() => l10n.failureGeneric,
  };
}
