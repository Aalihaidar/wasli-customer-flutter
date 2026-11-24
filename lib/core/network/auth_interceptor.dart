import 'package:dio/dio.dart';
import 'package:wasli_customer/core/storage/token_store.dart';

/// Adds the customer's token to the calls that need it, and ends the session once when the server refuses it.
///
/// **Which calls need the token** is read from the contract itself: the generated client puts each operation's
/// `security` into `extra['openapi.security']`. A call that names `customerAuth` gets `Authorization: Customer <token>`
/// when a token exists. Every other call (a public one with `security: [{}]`, or one the client did not describe) is
/// sent **without** the header, and any `Authorization` header set by hand is removed, so the token cannot leak to a
/// public endpoint.
///
/// **A `401` on a call that carried a token** clears the stored token and calls `onSessionExpired`, once: the token that
/// was sent is compared with the one stored now, so several calls failing together, or a call that fails after the
/// customer signed in again, do not clear or announce twice.
class AuthInterceptor extends Interceptor {
  /// Creates the interceptor over the token store; `onSessionExpired` runs when a `401` ended the session.
  new({required this._tokenStore, required this._onSessionExpired});

  /// The key under which the generated client states an operation's security requirements.
  static const securityExtraKey = 'openapi.security';

  /// The security scheme of the customer token in the contract.
  static const customerScheme = 'customerAuth';

  /// Marks a request that carried a token. It holds a fingerprint of the token (its hash), never the token itself.
  static const _sentTokenKey = 'wasli.sent_token_hash';

  final TokenStore _tokenStore;
  final void Function() _onSessionExpired;

  /// Whether the operation behind [options] asks for the customer token.
  static bool requiresCustomerToken(RequestOptions options) {
    final security = options.extra[securityExtraKey];
    if (security is! List<Object?>) {
      return false;
    }
    return security.any(
      (requirement) => requirement is Map<Object?, Object?> && requirement.containsKey(customerScheme),
    );
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers.removeWhere((name, _) => name.toLowerCase() == 'authorization');
    if (requiresCustomerToken(options)) {
      final token = await _tokenStore.read();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Customer $token';
        options.extra[_sentTokenKey] = token.hashCode;
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final sentHash = err.requestOptions.extra[_sentTokenKey];
    if (err.response?.statusCode == 401 && sentHash is int) {
      final current = await _tokenStore.read();
      if (current != null && current.hashCode == sentHash) {
        await _tokenStore.clear();
        _onSessionExpired();
      }
    }
    handler.next(err);
  }
}
