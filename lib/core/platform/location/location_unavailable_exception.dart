/// Why the position could not be read although the customer allowed it.
enum LocationProblem {
  /// Location is turned off on the device.
  serviceOff,

  /// No position arrived in time (a weak signal, indoors).
  timeout,

  /// Any other reason.
  unavailable,
}

/// The position could not be read. Carries no position and no platform text, so it is safe to log by type.
class LocationUnavailableException implements Exception {
  /// Creates the exception for [problem].
  const new(this.problem);

  /// What went wrong.
  final LocationProblem problem;
}
