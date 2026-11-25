import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/network/network_providers.dart';
import 'package:wasli_customer/core/session/session_state.dart';
import 'package:wasli_customer/core/storage/token_store.dart';

/// Whether a customer is signed in. Lives as long as the app.
///
/// Read it early (the router does): it follows the server's `401` only from the moment it is first read.
final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

/// Holds the [SessionState] and keeps it in step with the token store.
///
/// The app starts signed out: on the web the token lives in memory only (`security-privacy.md`), so a reload always
/// signs the customer out. When a persistent store arrives with the Android and iOS apps, the start-up code reads it
/// before the first frame and the first state comes from there. A `401` on a call that carried the token clears the
/// token (the network layer does that) and announces it through [sessionExpiredProvider]; this controller then moves
/// to [SignedOut].
class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    ref.listen(sessionExpiredProvider, (previous, next) => state = const SignedOut());
    return const SignedOut();
  }

  /// Keeps [token] (returned by the server only at `verify` and `login`) and moves to [SignedIn].
  ///
  /// The state changes only after the token is saved, so a store that fails leaves the customer signed out.
  Future<void> signIn(String token) async {
    await ref.read(tokenStoreProvider).write(token);
    state = const SignedIn();
  }

  /// Forgets the token and moves to [SignedOut]. Revoking the token on the server (`logout`) is the caller's job and
  /// comes first; a failed call must not leave the customer signed in on this device.
  Future<void> signOut() async {
    await ref.read(tokenStoreProvider).clear();
    state = const SignedOut();
  }
}
