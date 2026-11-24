import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/config/app_environment_provider.dart';
import 'package:wasli_customer/core/logging/app_logger.dart';
import 'package:wasli_customer/core/network/dio_factory.dart';
import 'package:wasli_customer/core/storage/token_store.dart';

/// Counts the times a `401` ended the session. It changes only when that happens; the session code listens to it
/// (`ref.listen`) and sends the customer to sign in. The token is already cleared when the count changes.
final sessionExpiredProvider = NotifierProvider<SessionExpiredSignal, int>(SessionExpiredSignal.new);

/// The notifier behind [sessionExpiredProvider].
class SessionExpiredSignal extends Notifier<int> {
  @override
  int build() => 0;

  /// Announces that a `401` ended the session.
  void announce() => state = state + 1;
}

/// The HTTP client of the app, shared by every repository: base URL from the environment, the customer token on the
/// calls that need it, redacted logging, retry of failed `GET`s, timeouts. Closed when the app's scope is disposed.
///
/// Only the data layer of a feature reads it, to build the generated client group it needs (`ConfigClient(dio)`).
final dioProvider = Provider<Dio>((ref) {
  final dio = createDio(
    environment: ref.watch(appEnvironmentProvider),
    tokenStore: ref.watch(tokenStoreProvider),
    onSessionExpired: () => ref.read(sessionExpiredProvider.notifier).announce(),
    logger: ref.watch(appLoggerProvider),
  );
  ref.onDispose(dio.close);
  return dio;
});
