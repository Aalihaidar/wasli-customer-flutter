import 'dart:async';

import 'package:wasli_customer/core/platform/location/device_position.dart';
import 'package:wasli_customer/core/platform/location/location_access.dart';
import 'package:wasli_customer/core/platform/location/location_service.dart';
import 'package:wasli_customer/core/platform/location/location_unavailable_exception.dart';

/// A position in Dubai, invented, that the fake service answers with.
const demoPosition = DevicePosition(latitude: 25.2048, longitude: 55.2708, accuracyMetres: 12);

/// A [LocationService] for tests: the customer's decision and the position are set by hand, and every call is counted.
class FakeLocationService implements LocationService {
  /// Creates a service. [current] is what the customer has decided; [afterRequest] is what the system prompt leads to;
  /// [problem] makes reading the position fail.
  new({
    this.current = LocationAccess.askable,
    this.afterRequest = LocationAccess.allowed,
    this.position = demoPosition,
    this.problem,
    this.canOpenSettings = false,
    this.gate,
  });

  /// What the customer has decided now. A test changes it to play the customer allowing location in the settings.
  LocationAccess current;

  /// What the system prompt leads to.
  LocationAccess afterRequest;

  /// The position it reads.
  DevicePosition position;

  /// When set, reading the position throws this.
  LocationProblem? problem;

  /// When set, reading the position waits until it completes, so a test can look at the screen meanwhile.
  Completer<void>? gate;

  @override
  bool canOpenSettings;

  /// How many times each thing was asked.
  int accessChecks = 0;

  /// How many times the system prompt was shown.
  int requests = 0;

  /// How many times the position was read.
  int reads = 0;

  /// How many times the settings were opened.
  int settingsOpened = 0;

  @override
  Future<LocationAccess> access() async {
    accessChecks++;
    return current;
  }

  @override
  Future<LocationAccess> requestAccess() async {
    requests++;
    return current = afterRequest;
  }

  @override
  Future<DevicePosition> currentPosition() async {
    reads++;
    await gate?.future;
    if (problem case final reason?) {
      throw LocationUnavailableException(reason);
    }
    return position;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return canOpenSettings;
  }
}
