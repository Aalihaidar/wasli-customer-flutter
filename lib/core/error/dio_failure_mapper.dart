import 'package:dio/dio.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/error/failure_mapper.dart';

/// Turns a [DioException] into a [Failure]: the one error pipeline between the HTTP client and the repositories.
Failure failureFromDioException(DioException exception) {
  final response = exception.response;
  if (response != null) {
    final statusCode = response.statusCode;
    final requestId = response.headers.value('x-request-id');
    if (statusCode == null) {
      return UnexpectedFailure(requestId: requestId);
    }
    return failureFromResponse(
      statusCode: statusCode,
      data: response.data,
      retryAfter: _parseRetryAfter(response.headers.value('retry-after')),
      requestId: requestId,
    );
  }

  return switch (exception.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout => const NetworkFailure(NetworkFailureKind.timeout),
    DioExceptionType.connectionError => const NetworkFailure(NetworkFailureKind.offline),
    DioExceptionType.cancel => const NetworkFailure(NetworkFailureKind.cancelled),
    DioExceptionType.badCertificate ||
    DioExceptionType.badResponse ||
    DioExceptionType.unknown => const UnexpectedFailure(),
  };
}

/// `Retry-After` as a number of seconds. The date form is not used by the backend and reads as "not said".
Duration? _parseRetryAfter(String? value) {
  final seconds = int.tryParse(value?.trim() ?? '');
  return seconds == null || seconds < 0 ? null : Duration(seconds: seconds);
}
