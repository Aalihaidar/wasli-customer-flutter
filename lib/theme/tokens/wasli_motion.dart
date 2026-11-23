import 'package:material_ui/material_ui.dart';

/// The durations and the curve of the design's motion.
///
/// Motion respects the system's reduce-motion setting: [adapt] returns a zero duration when the user asked for less
/// motion, so a transition becomes an instant change.
abstract final class WasliMotion {
  /// 120 ms: small state changes such as a pressed button.
  static const Duration fast = Duration(milliseconds: 120);

  /// 200 ms: the standard transition.
  static const Duration standard = Duration(milliseconds: 200);

  /// 300 ms: sheets entering and leaving.
  static const Duration sheet = Duration(milliseconds: 300);

  /// The standard easing, `cubic-bezier(.2, 0, 0, 1)`.
  static const Curve curve = Cubic(0.2, 0, 0, 1);

  /// [duration], or [Duration.zero] when the system asks to reduce motion.
  static Duration adapt(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}
