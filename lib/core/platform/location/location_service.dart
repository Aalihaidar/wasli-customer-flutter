import 'package:wasli_customer/core/platform/location/device_position.dart';
import 'package:wasli_customer/core/platform/location/location_access.dart';
import 'package:wasli_customer/core/platform/location/location_unavailable_exception.dart';

/// The device's position, behind one interface so shared code never touches a platform plugin.
///
/// Location is requested only when a screen needs it, after the app has explained why (`architecture.md`, 7b). A
/// position and the question whether it was allowed are never logged.
abstract interface class LocationService {
  /// What the customer has already decided, without showing any prompt.
  Future<LocationAccess> access();

  /// Shows the system prompt when the system can still ask, and returns what the customer decided.
  Future<LocationAccess> requestAccess();

  /// Reads the position once, with high accuracy and a time limit.
  ///
  /// Throws [LocationUnavailableException] when the position cannot be read. Call it only after [access] or
  /// [requestAccess] answered [LocationAccess.allowed].
  Future<DevicePosition> currentPosition();

  /// Whether [openSettings] can take the customer to the place where the permission is changed (phones only).
  bool get canOpenSettings;

  /// Opens the system settings of this app. Does nothing, and returns `false`, where [canOpenSettings] is `false`.
  Future<bool> openSettings();
}
