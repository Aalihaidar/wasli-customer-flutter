import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current instant, as a function so that code which counts down (a code that expires, a resend that unlocks) can be
/// tested with a clock the test moves by hand. Always UTC.
typedef Clock = DateTime Function();

/// The clock of the app: the device's, in UTC. Tests replace it.
final clockProvider = Provider<Clock>(
  (ref) =>
      () => DateTime.now().toUtc(),
);
