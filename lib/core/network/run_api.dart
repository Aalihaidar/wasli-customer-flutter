import 'package:dio/dio.dart';
import 'package:wasli_customer/core/error/dio_failure_mapper.dart';
import 'package:wasli_customer/core/error/failure.dart';

/// Runs one call of the generated client and turns whatever goes wrong into a [Failure].
///
/// This is the one place a repository wraps a call, so the layers above see domain types or a [Failure], never a
/// `DioException` or a generated type's parsing error:
///
/// ```dart
/// final config = await runApi(() => client.configRetrieve());
/// ```
///
/// A `DioException` goes through the error pipeline (`failureFromDioException`: the error body, the status, `Retry-After`
/// and the request id). An answer that arrives but does not read as the contract (a missing key, a wrong type) is an
/// [UnexpectedFailure]: it is generic for the app, and the details are for the developer.
Future<T> runApi<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on Failure {
    rethrow;
  } on DioException catch (error, stack) {
    Error.throwWithStackTrace(failureFromDioException(error), stack);
  } on Exception catch (_, stack) {
    Error.throwWithStackTrace(const UnexpectedFailure(), stack);
    // ignore: avoid_catching_errors, the generated parser reports a body of the wrong shape as a TypeError.
  } on TypeError catch (_, stack) {
    Error.throwWithStackTrace(const UnexpectedFailure(), stack);
  }
}
