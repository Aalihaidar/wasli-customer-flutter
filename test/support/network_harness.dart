import 'package:dio/dio.dart';
import 'package:wasli_customer/core/config/app_environment.dart';
import 'package:wasli_customer/core/logging/app_logger.dart';
import 'package:wasli_customer/core/network/dio_factory.dart';
import 'package:wasli_customer/core/storage/token_store.dart';

import 'fake_http_adapter.dart';

/// An [AppLogger] that keeps what was written, so a test can read it.
class RecordingLogger implements AppLogger {
  /// Every line written, with its level in front.
  final List<String> lines = [];

  @override
  void debug(String message) => lines.add('debug: $message');

  @override
  void warning(String message) => lines.add('warning: $message');
}

/// The real [createDio] over a [FakeHttpAdapter], with everything a network test reads: the token store, the log, the
/// pauses the retry asked for and how many times a `401` ended the session.
class NetworkHarness {
  /// Builds the client; [handler] answers the requests, [token] is the token already stored (none by default).
  new(FakeHandler handler, {String? token}) : adapter = FakeHttpAdapter(handler), store = MemoryTokenStore(token) {
    dio = createDio(
      environment: AppEnvironment.parse(apiBaseUrl: 'https://api.example.test/api/v1'),
      tokenStore: store,
      onSessionExpired: () => sessionExpiredCount++,
      logger: logger,
      adapter: adapter,
      sleep: (duration) async => pauses.add(duration),
    );
  }

  /// The fake network.
  final FakeHttpAdapter adapter;

  /// The token store the interceptor reads and clears.
  final MemoryTokenStore store;

  /// What the interceptors logged.
  final RecordingLogger logger = RecordingLogger();

  /// The pauses the retry interceptor asked for, in order.
  final List<Duration> pauses = [];

  /// How many times a `401` ended the session.
  int sessionExpiredCount = 0;

  /// The client under test.
  late final Dio dio;
}
