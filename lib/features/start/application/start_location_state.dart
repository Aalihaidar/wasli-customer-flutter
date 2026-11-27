import 'package:wasli_customer/features/start/domain/coordinates.dart';
import 'package:wasli_customer/features/start/domain/position_source.dart';

/// Where the start screen is in finding the customer's position.
///
/// Sealed, so the screen handles every case with an exhaustive `switch`.
sealed class StartLocationState {
  const new();
}

/// Looking at what the customer already decided, before showing anything.
final class LocationChecking extends StartLocationState {
  /// Creates the state.
  const new();
}

/// The customer has not allowed location yet and the system can still ask: the screen explains why, then asks.
final class LocationNeeded extends StartLocationState {
  /// Creates the state.
  const new();
}

/// The system prompt is showing, or the position is being read.
final class LocationLocating extends StartLocationState {
  /// Creates the state.
  const new();
}

/// A position is known, from the device or simulated in a test build.
final class LocationFound extends StartLocationState {
  /// Creates the state.
  const new({required this.coordinates, required this.source});

  /// The position.
  final Coordinates coordinates;

  /// Where it comes from.
  final PositionSource source;
}

/// The customer refused location.
final class LocationDenied extends StartLocationState {
  /// Creates the state; [blocked] is `true` when asking again would show nothing (only the browser or system settings
  /// can change it).
  const new({required this.blocked});

  /// Whether the system will not ask again.
  final bool blocked;
}

/// Location is allowed but turned off on the device.
final class LocationOff extends StartLocationState {
  /// Creates the state.
  const new();
}

/// Location is allowed but no position could be read (a weak signal, a platform error).
final class LocationFailed extends StartLocationState {
  /// Creates the state.
  const new();
}
