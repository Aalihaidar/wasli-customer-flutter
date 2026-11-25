import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/app/error_handlers.dart';

import '../support/network_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterExceptionHandler? savedFlutterHandler;
  late ErrorCallback? savedDispatcherHandler;
  late RecordingLogger logger;

  setUp(() {
    savedFlutterHandler = FlutterError.onError;
    savedDispatcherHandler = PlatformDispatcher.instance.onError;
    logger = RecordingLogger();
  });

  tearDown(() {
    FlutterError.onError = savedFlutterHandler;
    PlatformDispatcher.instance.onError = savedDispatcherHandler;
  });

  test('a framework error is logged with its type and library, never its message', () {
    installErrorHandlers(logger, present: false);

    FlutterError.onError!(FlutterErrorDetails(exception: StateError('typed by the customer'), library: 'widgets'));

    expect(logger.lines, ['warning: Flutter error: StateError in widgets']);
  });

  test('a framework error without a library is attributed to the framework', () {
    installErrorHandlers(logger, present: false);

    FlutterError.onError!(const FlutterErrorDetails(exception: FormatException('1.23456,2.34567')));

    expect(logger.lines, ['warning: Flutter error: FormatException in Flutter framework']);
  });

  test('an error that escapes an async call is logged by type and counted as handled', () {
    installErrorHandlers(logger, present: false);

    final handled = PlatformDispatcher.instance.onError!(ArgumentError('+971 50 000 0000'), StackTrace.empty);

    expect(handled, isTrue);
    expect(logger.lines, ['warning: Uncaught error: ArgumentError']);
    expect(logger.lines.single, isNot(contains('971')));
  });
}
