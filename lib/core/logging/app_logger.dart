import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where the app writes its diagnostic lines.
///
/// An interface, so that the destination can change (a crash-report service later) without touching the callers, and
/// so that tests can read what was written. **A message never holds personal data**: no token, no code, no position, no
/// chat text, no request or response body and no query string. Callers build their lines from names and numbers only.
abstract interface class AppLogger {
  /// Writes a line that helps while developing.
  void debug(String message);

  /// Writes a line about something that went wrong but did not stop the app.
  void warning(String message);
}

/// An [AppLogger] that writes to the developer console in debug and profile builds and stays silent in release builds.
class ConsoleAppLogger implements AppLogger {
  /// Creates the logger.
  const new();

  @override
  void debug(String message) => _write(message, level: 500);

  @override
  void warning(String message) => _write(message, level: 900);

  void _write(String message, {required int level}) {
    if (kReleaseMode) {
      return;
    }
    developer.log(message, name: 'wasli', level: level);
  }
}

/// The app's logger. Replaced in tests.
final appLoggerProvider = Provider<AppLogger>((ref) => const ConsoleAppLogger());
