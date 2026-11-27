import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/platform/location/location_access.dart';
import 'package:wasli_customer/core/platform/location/location_providers.dart';
import 'package:wasli_customer/core/platform/location/location_service.dart';
import 'package:wasli_customer/core/platform/location/location_unavailable_exception.dart';
import 'package:wasli_customer/features/start/application/start_location_state.dart';
import 'package:wasli_customer/features/start/domain/coordinates.dart';
import 'package:wasli_customer/features/start/domain/position_source.dart';

/// The customer's position for the start screen. Lives as long as the app, so coming back from a restaurant does not ask
/// again.
final startLocationProvider = NotifierProvider<StartLocationController, StartLocationState>(
  StartLocationController.new,
);

/// Finds the customer's position without asking before the screen has explained why.
///
/// On first use it only reads what the customer already decided: when location is allowed it reads the position, when it
/// can still be asked it waits for [allow] (the button under the explanation), and when it is refused it says so. It never
/// shows the system prompt by itself, never logs a position, and does not ask again in a loop.
class StartLocationController extends Notifier<StartLocationState> {
  LocationService get _service => ref.read(locationServiceProvider);

  @override
  StartLocationState build() {
    unawaited(_checkAccess());
    return const LocationChecking();
  }

  /// Shows the system prompt (the customer pressed the button that explained why) and reads the position.
  Future<void> allow() async {
    state = const LocationLocating();
    await _resolve(await _service.requestAccess());
  }

  /// Looks again at what the customer decided, for the "Try again" button, after they changed it elsewhere.
  Future<void> retry() async {
    state = const LocationChecking();
    await _checkAccess();
  }

  /// Reads the position again. A device position is read afresh; a simulated one stays. When the position cannot be read
  /// this time, the previous one stays on screen.
  Future<void> refresh() async {
    final current = state;
    if (current is! LocationFound || current.source == PositionSource.simulated) {
      return;
    }
    try {
      final position = await _service.currentPosition();
      if (ref.mounted) {
        state = LocationFound(
          coordinates: (latitude: position.latitude, longitude: position.longitude),
          source: PositionSource.gps,
        );
      }
    } on LocationUnavailableException {
      // Keep showing the list for the last known position.
    }
  }

  /// Pretends the customer is at [point] (a test build's "I'm at the restaurant").
  void simulateAt(Coordinates point) {
    state = LocationFound(coordinates: point, source: PositionSource.simulated);
  }

  /// Opens the system settings of the app, where location can be allowed.
  Future<void> openSettings() => _service.openSettings();

  Future<void> _checkAccess() async {
    final access = await _service.access();
    if (ref.mounted) {
      await _resolve(access, askedNow: false);
    }
  }

  Future<void> _resolve(LocationAccess access, {bool askedNow = true}) async {
    if (!ref.mounted) {
      return;
    }
    switch (access) {
      case LocationAccess.allowed:
        await _locate();
      case LocationAccess.askable:
        state = askedNow ? const LocationDenied(blocked: false) : const LocationNeeded();
      case LocationAccess.blocked:
        state = const LocationDenied(blocked: true);
    }
  }

  Future<void> _locate() async {
    state = const LocationLocating();
    try {
      final position = await _service.currentPosition();
      if (ref.mounted) {
        state = LocationFound(
          coordinates: (latitude: position.latitude, longitude: position.longitude),
          source: PositionSource.gps,
        );
      }
    } on LocationUnavailableException catch (error) {
      if (ref.mounted) {
        state = error.problem == LocationProblem.serviceOff ? const LocationOff() : const LocationFailed();
      }
    }
  }
}
