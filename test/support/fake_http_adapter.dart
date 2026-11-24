import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Answers a request with a scripted response or by throwing a [DioException]; it never touches the network.
typedef FakeHandler = FutureOr<ResponseBody> Function(RequestOptions options);

/// An [HttpClientAdapter] for tests: it records every request and lets [handler] decide the answer.
class FakeHttpAdapter implements HttpClientAdapter {
  /// Creates an adapter answering with [handler].
  new(this.handler);

  /// Decides the answer to each request.
  FakeHandler handler;

  /// Every request that reached the adapter, in order.
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) {
    requests.add(options);
    return Future.sync(() => handler(options));
  }

  @override
  void close({bool force = false}) {}
}

/// A JSON answer with the given [status]; [headers] are added to it.
ResponseBody jsonResponse(int status, Object? body, {Map<String, String> headers = const {}}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
      for (final entry in headers.entries) entry.key: [entry.value],
    },
  );
}

/// An answer that is not JSON (for example a proxy's HTML page).
ResponseBody htmlResponse(int status, String body) {
  return ResponseBody.fromString(
    body,
    status,
    headers: {
      Headers.contentTypeHeader: ['text/html'],
    },
  );
}

/// A failure of the connection itself, the way Dio reports it.
DioException connectionFailure(RequestOptions options, DioExceptionType type) {
  return DioException(requestOptions: options, type: type, message: 'simulated');
}
