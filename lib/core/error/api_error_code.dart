/// The error codes of the backend that the app acts on.
///
/// The set the server can send is open: a code that is not listed here is [unknown], never an error. Only codes the
/// pinned contract declares, plus the account-flow codes the screens act on, are listed; the chat codes join with the
/// conversation endpoints.
enum ApiErrorCode {
  /// `authentication_failed` (401): the token is not valid.
  authenticationFailed('authentication_failed'),

  /// `not_authenticated` (401): no token was sent.
  notAuthenticated('not_authenticated'),

  /// `permission_denied` (403): the account may not do this (for example it is blocked).
  permissionDenied('permission_denied'),

  /// `account_not_verified` (403): the sign-up code has not been confirmed yet.
  accountNotVerified('account_not_verified'),

  /// `not_found` (404).
  notFound('not_found'),

  /// `account_exists` (409): the contact belongs to another account.
  accountExists('account_exists'),

  /// `contact_already_set` (409): the account already has this kind of contact.
  contactAlreadySet('contact_already_set'),

  /// `no_pending_contact` (409): there is no added contact waiting for a code.
  noPendingContact('no_pending_contact'),

  /// `order_invalid_transition` (409): the order cannot move to that status.
  orderInvalidTransition('order_invalid_transition'),

  /// `code_invalid`: the six-digit code is wrong.
  codeInvalid('code_invalid'),

  /// `code_expired`: the six-digit code has expired.
  codeExpired('code_expired'),

  /// `throttled` (429): too many requests; honour `Retry-After`.
  throttled('throttled'),

  /// `too_many_attempts` (429): too many wrong attempts at a code.
  tooManyAttempts('too_many_attempts'),

  /// `request_too_large`: the request body is over the limit.
  requestTooLarge('request_too_large'),

  /// Any code this app version does not know. A generic failure of the HTTP status.
  unknown('');

  new(this.wire);

  /// The code as the server writes it.
  final String wire;

  /// The code for [wire], or [unknown] when it is not listed.
  static ApiErrorCode fromWire(String wire) {
    for (final code in values) {
      if (code != unknown && code.wire == wire) {
        return code;
      }
    }
    return unknown;
  }
}
