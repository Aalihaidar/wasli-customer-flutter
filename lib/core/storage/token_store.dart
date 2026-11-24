import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the customer's session token is kept.
///
/// An interface with one implementation per platform (`architecture.md`, section 5): the platform's secure store on
/// Android and iOS later, and on the web memory only for now. `shared_preferences` is never used for a token, because
/// any script on the page, or any app with backup access, can read it.
abstract interface class TokenStore {
  /// The saved token, or `null` when nobody is signed in.
  Future<String?> read();

  /// Saves [token] as the signed-in customer's token.
  Future<void> write(String token);

  /// Forgets the token (sign-out, or a `401`).
  Future<void> clear();
}

/// A [TokenStore] that keeps the token in memory only, so it is gone when the page is reloaded or the app closes.
///
/// The web implementation until the backend offers an HttpOnly cookie session (`security-privacy.md`), and the store
/// that tests use. The customer signs in again after a reload.
class MemoryTokenStore implements TokenStore {
  /// Creates a store, optionally holding a token already.
  new([this._token]);

  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}

/// The token store of this app. Lives as long as the app; replaced with the platform's store at start-up and in tests.
final tokenStoreProvider = Provider<TokenStore>((ref) => MemoryTokenStore());
