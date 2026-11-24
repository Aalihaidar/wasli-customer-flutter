import 'package:dio/dio.dart';
import 'package:wasli_customer/core/config/app_environment.dart';
import 'package:wasli_customer/core/logging/app_logger.dart';
import 'package:wasli_customer/core/network/auth_interceptor.dart';
import 'package:wasli_customer/core/network/network_timeouts.dart';
import 'package:wasli_customer/core/network/redacted_log_interceptor.dart';
import 'package:wasli_customer/core/network/retry_interceptor.dart';
import 'package:wasli_customer/core/storage/token_store.dart';

/// Builds the HTTP client every call of the app goes through.
///
/// The base URL is the API origin, not the base URL with `/api/v1`: the paths of the generated client already start with
/// `/api/v1` (`AppEnvironment.apiOrigin`). Interceptors, in this order: the token, the redacted log, the retry. Only
/// `GET`s are retried, and every call has timeouts.
///
/// [adapter] and [sleep] let tests answer without a network and without waiting.
Dio createDio({
  required AppEnvironment environment,
  required TokenStore tokenStore,
  required void Function() onSessionExpired,
  required AppLogger logger,
  HttpClientAdapter? adapter,
  RetrySleep sleep = Future.delayed,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: environment.apiOrigin.toString(),
      connectTimeout: NetworkTimeouts.connect,
      sendTimeout: NetworkTimeouts.send,
      receiveTimeout: NetworkTimeouts.receive,
      headers: {'Accept': 'application/json'},
    ),
  );
  if (adapter != null) {
    dio.httpClientAdapter = adapter;
  }
  dio.interceptors.addAll([
    AuthInterceptor(tokenStore: tokenStore, onSessionExpired: onSessionExpired),
    RedactedLogInterceptor(logger),
    RetryInterceptor(dio: dio, sleep: sleep),
  ]);
  return dio;
}
