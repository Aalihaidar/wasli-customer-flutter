import 'dart:async';
import 'dart:math';

import 'package:wasli_customer/core/error/failure.dart';

/// Calls [onTick] again and again while it is running, one call at a time, with a pause between two calls.
///
/// The owner (a notifier) decides when it runs: it starts the poller when the screen is visible and stops it when the
/// screen is hidden or has been quiet for long enough. A tick that fails does not stop the poller: it waits longer
/// (the server's `Retry-After` for a throttled call, otherwise twice as long each time up to [maxBackoff]) and goes on, and
/// it goes back to the normal pause after the first tick that works. A tick that ends the session (`401`) stops it.
class Poller {
  /// Creates a poller. [interval] is read before each pause, so a changed setting applies at once.
  new({required this.interval, required this.onTick, this.maxBackoff = const Duration(seconds: 60)});

  /// The pause between two ticks.
  final Duration Function() interval;

  /// One poll. It may throw a [Failure].
  final Future<void> Function() onTick;

  /// The longest pause after failures.
  final Duration maxBackoff;

  Timer? _timer;
  bool _running = false;
  int _failures = 0;

  /// Whether the poller is running (waiting for, or doing, a tick).
  bool get isRunning => _running;

  /// Starts the poller. The first tick comes after [interval], or at once with [immediately]. Does nothing when it is
  /// already running.
  void start({bool immediately = false}) {
    if (_running) {
      return;
    }
    _running = true;
    _failures = 0;
    _schedule(immediately ? Duration.zero : interval());
  }

  /// Stops the poller. A tick that is already running finishes, but no other follows.
  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    _timer = Timer(delay, _tick);
  }

  Future<void> _tick() async {
    if (!_running) {
      return;
    }
    Duration next;
    try {
      await onTick();
      _failures = 0;
      next = interval();
    } on UnauthenticatedFailure {
      stop();
      return;
    } on ThrottledFailure catch (failure) {
      _failures++;
      next = failure.retryAfter ?? _backoff();
    } on Failure {
      _failures++;
      next = _backoff();
    }
    if (_running) {
      _schedule(next);
    }
  }

  Duration _backoff() {
    final base = interval();
    final factor = pow(2, min(_failures, 6)).toInt();
    final wanted = base * factor;
    return wanted > maxBackoff ? maxBackoff : wanted;
  }
}
