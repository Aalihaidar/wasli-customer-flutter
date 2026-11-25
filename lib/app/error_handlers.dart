import 'package:flutter/foundation.dart';
import 'package:wasli_customer/core/logging/app_logger.dart';

/// Sends every error that nothing caught to [logger], in one place.
///
/// Covers errors the framework reports (`FlutterError.onError`: build, layout, painting) and errors that escape an
/// async call (`PlatformDispatcher.onError`), so none ends silently. The line holds the **type** of the error and the
/// library it came from, never its message or stack: an exception message can carry what the customer typed or a
/// position (`security-privacy.md`). With [present] true (debug and profile builds by default) the framework also prints
/// the full report to the console for the developer, never in a release build.
///
/// A crash-report service, once chosen, replaces [logger]; the app does not change.
void installErrorHandlers(AppLogger logger, {bool present = !kReleaseMode}) {
  FlutterError.onError = (details) {
    logger.warning('Flutter error: ${details.exception.runtimeType} in ${details.library ?? 'unknown'}');
    if (present) {
      FlutterError.presentError(details);
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.warning('Uncaught error: ${error.runtimeType}');
    return true;
  };
}
