import 'package:dio/dio.dart';
import 'package:wasli_customer/core/logging/app_logger.dart';

/// Logs one line per call and per answer, built from names and numbers only.
///
/// A line holds the method, the path, the status or the failure type, the time it took and the server's `X-Request-ID`.
/// It never holds a header (the token is one), a body (a chat message, a code, a password, a position), a query string
/// (`restaurants/nearby` carries the customer's position there) or the server's error text.
class RedactedLogInterceptor extends Interceptor {
  /// Creates the interceptor writing to the logger; `now` is the clock (replaced in tests).
  new(this._logger, {this._now = DateTime.now});

  static const _startedKey = 'wasli.started_us';

  final AppLogger _logger;
  final DateTime Function() _now;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedKey] = _now().microsecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    _logger.debug('${_describe(response.requestOptions)} -> ${response.statusCode}${_tail(response)}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final outcome = response?.statusCode?.toString() ?? err.type.name;
    _logger.warning('${_describe(err.requestOptions)} !! $outcome${_tail(response, options: err.requestOptions)}');
    handler.next(err);
  }

  /// `GET /api/v1/config`: the method and the path, never the query.
  static String _describe(RequestOptions options) {
    final path = options.path.split('?').first;
    return '${options.method} $path';
  }

  String _tail(Response<dynamic>? response, {RequestOptions? options}) {
    final requestOptions = response?.requestOptions ?? options;
    final started = requestOptions?.extra[_startedKey];
    final parts = <String>[
      if (started is int) '${(_now().microsecondsSinceEpoch - started) ~/ 1000} ms',
      if (response?.headers.value('x-request-id') case final id?) 'request $id',
    ];
    return parts.isEmpty ? '' : ' (${parts.join(', ')})';
  }
}
