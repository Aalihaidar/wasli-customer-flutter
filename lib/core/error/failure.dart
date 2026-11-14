import 'package:wasli_customer/core/error/api_error_code.dart';
import 'package:wasli_customer/core/error/api_issue.dart';

/// Why a call failed, in the terms the app acts on.
///
/// Repositories return or throw a [Failure]; the UI switches over it exhaustively and writes its own localized text.
/// Nothing here carries server text.
sealed class Failure {
  /// Creates a failure; [requestId] is the `X-Request-ID` of the response, when there was one.
  const new({this.requestId});

  /// The request id the server answered with, to quote when asking for help. `null` when no response arrived.
  final String? requestId;
}

/// Why the server could not be reached.
enum NetworkFailureKind {
  /// No connection to the server.
  offline,

  /// The server did not answer in time.
  timeout,

  /// The request was cancelled by the app (for example the screen closed).
  cancelled,
}

/// The server could not be reached (or the call was cancelled).
final class NetworkFailure extends Failure {
  /// Creates a network failure of the given [kind].
  const new(this.kind);

  /// What happened.
  final NetworkFailureKind kind;
}

/// `401`: the token is missing or no longer valid. The session is cleared once and the sign-in screen opens.
final class UnauthenticatedFailure extends Failure {
  /// Creates an unauthenticated failure.
  const new({super.requestId});
}

/// `403 account_not_verified`: the sign-up code has not been confirmed; the app opens the code screen.
final class AccountNotVerifiedFailure extends Failure {
  /// Creates an account-not-verified failure.
  const new({super.requestId});
}

/// `403` for any other reason: not allowed (for example a blocked or deactivated account).
final class PermissionDeniedFailure extends Failure {
  /// Creates a permission-denied failure.
  const new({super.requestId});
}

/// `404`: the thing does not exist (for example a restaurant slug nobody has).
final class NotFoundFailure extends Failure {
  /// Creates a not-found failure.
  const new({super.requestId});
}

/// `400`: the input was refused. Each [issues] entry names the field and the code.
final class ValidationFailure extends Failure {
  /// Creates a validation failure with its [issues].
  const new(this.issues, {super.requestId});

  /// What was wrong, in the server's order.
  final List<ApiIssue> issues;

  /// The first issue about [attr], or `null`.
  ApiIssue? issueFor(String attr) {
    for (final issue in issues) {
      if (issue.attr == attr) {
        return issue;
      }
    }
    return null;
  }

  /// Whether any issue carries [code].
  bool has(ApiErrorCode code) => issues.any((issue) => issue.known == code);
}

/// `409`: the request is valid but conflicts with the current state (`account_exists`, `contact_already_set`, ...).
final class ConflictFailure extends Failure {
  /// Creates a conflict failure with its [issues].
  const new(this.issues, {super.requestId});

  /// What conflicts, in the server's order.
  final List<ApiIssue> issues;

  /// Whether any issue carries [code].
  bool has(ApiErrorCode code) => issues.any((issue) => issue.known == code);
}

/// `429`: too many requests, or too many wrong attempts at a code. Never retry immediately.
final class ThrottledFailure extends Failure {
  /// Creates a throttled failure.
  const new({this.retryAfter, this.tooManyAttempts = false, super.requestId});

  /// How long the server asked to wait (`Retry-After`), or `null` when it did not say.
  final Duration? retryAfter;

  /// `true` for `too_many_attempts` (wrong codes), `false` for plain `throttled`.
  final bool tooManyAttempts;
}

/// Any other `4xx` with a readable error body (for example `request_too_large`).
final class RequestRejectedFailure extends Failure {
  /// Creates a rejected-request failure.
  const new(this.statusCode, this.issues, {super.requestId});

  /// The HTTP status.
  final int statusCode;

  /// What the server said, in its order.
  final List<ApiIssue> issues;

  /// Whether any issue carries [code].
  bool has(ApiErrorCode code) => issues.any((issue) => issue.known == code);
}

/// Everything else: a `5xx`, an unreadable body, an unexpected status, an unknown failure. Generic for its status.
final class UnexpectedFailure extends Failure {
  /// Creates an unexpected failure; [statusCode] is `null` when no response arrived.
  const new({this.statusCode, super.requestId});

  /// The HTTP status, or `null`.
  final int? statusCode;
}
