import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:wasli_customer/core/error/dio_failure_mapper.dart';

/// Waits for [duration]; replaced in tests so a retry does not slow them down.
typedef RetrySleep = Future<void> Function(Duration duration);

/// Tries a failed `GET` again, a few times, with a growing pause.
///
/// What is retried: a `GET` that timed out, lost the connection or got a `500`, `502`, `503` or `504`. What never is:
/// a `POST` or any other method (a retry could do the same thing twice; a chat message is retried by the chat with the
/// **same** `client_message_id`), a `429` (the server asked to wait: the caller backs off using `Retry-After`), any other
/// `4xx`, a cancelled call and an answer that failed to read. A `503` with a `Retry-After` longer than [maxRetryAfter]
/// is not retried either, so the screen shows the failure instead of waiting.
class RetryInterceptor extends Interceptor {
  /// Creates the interceptor for `dio`, the client whose calls it repeats.
  new({
    required this._dio,
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxRetryAfter = const Duration(seconds: 10),
    this._sleep = Future.delayed,
  });

  static const _attemptKey = 'wasli.retry_attempt';

  /// The statuses worth another try.
  static const retriedStatuses = {500, 502, 503, 504};

  final Dio _dio;
  final RetrySleep _sleep;

  /// How many times a call is repeated after the first failure.
  final int maxRetries;

  /// The pause before the first repeat; each next pause is twice as long.
  final Duration baseDelay;

  /// The longest `Retry-After` the app waits for.
  final Duration maxRetryAfter;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 0;
    final delay = _delayBefore(err, attempt);
    if (delay == null) {
      handler.next(err);
      return;
    }

    await _sleep(delay);
    try {
      final response = await _dio.fetch<dynamic>(options.copyWith(extra: {...options.extra, _attemptKey: attempt + 1}));
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// The pause before the next try, or `null` when the call is not retried.
  Duration? _delayBefore(DioException err, int attempt) {
    if (err.requestOptions.method != 'GET' || attempt >= maxRetries) {
      return null;
    }
    final backoff = baseDelay * math.pow(2, attempt).toInt();
    final response = err.response;
    if (response != null) {
      if (!retriedStatuses.contains(response.statusCode)) {
        return null;
      }
      final retryAfter = parseRetryAfter(response.headers.value('retry-after'));
      if (retryAfter == null) {
        return backoff;
      }
      return retryAfter > maxRetryAfter ? null : (retryAfter > backoff ? retryAfter : backoff);
    }
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => backoff,
      DioExceptionType.cancel ||
      DioExceptionType.badCertificate ||
      DioExceptionType.badResponse ||
      DioExceptionType.transformTimeout ||
      DioExceptionType.unknown => null,
    };
  }
}
