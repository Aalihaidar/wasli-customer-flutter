/// Where the device is, as the platform reports it.
///
/// A position is personal data: it is sent only to look for restaurants and with an order, and it is never logged.
class DevicePosition {
  /// Creates a position.
  const new({required this.latitude, required this.longitude, this.accuracyMetres});

  /// Degrees north of the equator, from -90 to 90.
  final double latitude;

  /// Degrees east of the prime meridian, from -180 to 180.
  final double longitude;

  /// How far off the position may be, in metres, when the platform says so.
  final double? accuracyMetres;
}
