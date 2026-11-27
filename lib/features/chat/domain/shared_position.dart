/// The position the customer shares with the restaurant for the order. Personal data: never logged.
class SharedPosition {
  /// Creates a position. [simulated] marks a test build's pretend position.
  const new({required this.latitude, required this.longitude, this.accuracyMetres, this.simulated = false});

  /// Degrees north of the equator.
  final double latitude;

  /// Degrees east of the prime meridian.
  final double longitude;

  /// How far off it may be, in metres, when known.
  final double? accuracyMetres;

  /// Whether it is a simulated position of a test build.
  final bool simulated;
}
