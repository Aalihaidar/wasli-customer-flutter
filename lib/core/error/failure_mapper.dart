import 'package:wasli_customer/core/error/api_error_code.dart';
import 'package:wasli_customer/core/error/api_issue.dart';
import 'package:wasli_customer/core/error/error_body_parser.dart';
import 'package:wasli_customer/core/error/failure.dart';

/// Turns an error response into a [Failure].
///
/// The HTTP status picks the family and the codes of the body refine it. A code the app does not know is a generic
/// failure of its status, and a body that is not the backend's error body (a proxy or Django's own page) is an
/// [UnexpectedFailure]; neither is ever an exception. [retryAfter] is the parsed `Retry-After` and [requestId] the
/// `X-Request-ID`, both taken from the response headers by the caller.
Failure failureFromResponse({required int statusCode, required Object? data, Duration? retryAfter, String? requestId}) {
  final issues = parseErrorBody(data);

  // 401 and 404 mean the same whatever the body says, so they do not need a readable body.
  if (statusCode == 401) {
    return UnauthenticatedFailure(requestId: requestId);
  }
  if (statusCode == 404) {
    return NotFoundFailure(requestId: requestId);
  }
  if (statusCode == 429) {
    return ThrottledFailure(
      retryAfter: retryAfter,
      tooManyAttempts: _hasCode(issues, ApiErrorCode.tooManyAttempts),
      requestId: requestId,
    );
  }
  // The code names this failure whatever the status the server chose for it (the contract says 403 for sign-in).
  if (statusCode < 500 && _hasCode(issues, ApiErrorCode.accountNotVerified)) {
    return AccountNotVerifiedFailure(requestId: requestId);
  }
  if (statusCode == 403) {
    return PermissionDeniedFailure(requestId: requestId);
  }

  if (issues != null) {
    if (statusCode == 400) {
      return ValidationFailure(issues, requestId: requestId);
    }
    if (statusCode == 409) {
      return ConflictFailure(issues, requestId: requestId);
    }
    if (statusCode >= 400 && statusCode < 500) {
      return RequestRejectedFailure(statusCode, issues, requestId: requestId);
    }
  }
  return UnexpectedFailure(statusCode: statusCode, requestId: requestId);
}

bool _hasCode(List<ApiIssue>? issues, ApiErrorCode code) =>
    issues != null && issues.any((issue) => issue.known == code);
