import 'dart:async';

import 'package:flutter/widgets.dart';

/// Rebuilds [builder] every second, for a countdown that reads the clock each time it builds.
///
/// The text is computed from the clock, not by counting ticks, so a browser tab that slows its timers in the background
/// shows the right time as soon as it wakes up.
class SecondTicker extends StatefulWidget {
  /// Creates a ticker that builds [builder] now and every second.
  const new({required this.builder, super.key});

  /// Builds the content; it reads the current time itself.
  final WidgetBuilder builder;

  @override
  State<SecondTicker> createState() => _SecondTickerState();
}

class _SecondTickerState extends State<SecondTicker> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);
}
