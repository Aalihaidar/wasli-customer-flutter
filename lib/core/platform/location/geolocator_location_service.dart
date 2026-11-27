import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wasli_customer/core/platform/location/device_position.dart';
import 'package:wasli_customer/core/platform/location/location_access.dart';
import 'package:wasli_customer/core/platform/location/location_service.dart';
import 'package:wasli_customer/core/platform/location/location_unavailable_exception.dart';

/// How long a position may take before the app gives up on it.
const Duration locationTimeout = Duration(seconds: 10);

/// What the customer decided, as the app understands it, from the plugin's permission.
///
/// On the web the plugin reports the browser's `prompt` as `denied` (it can still ask) and the browser's `denied` as
/// `deniedForever` (a browser never asks again). An answer the plugin cannot determine counts as "can still ask".
LocationAccess locationAccessFromPermission(LocationPermission permission) {
  return switch (permission) {
    LocationPermission.whileInUse || LocationPermission.always => LocationAccess.allowed,
    LocationPermission.deniedForever => LocationAccess.blocked,
    LocationPermission.denied || LocationPermission.unableToDetermine => LocationAccess.askable,
  };
}

/// The device's position through the `geolocator` plugin (browser geolocation on the web).
///
/// No position and no plugin message is ever logged or kept in an exception.
class GeolocatorLocationService implements LocationService {
  /// Creates the service.
  const new();

  @override
  Future<LocationAccess> access() async {
    try {
      return locationAccessFromPermission(await Geolocator.checkPermission());
    } on Exception {
      // A browser without the permissions API cannot say: the prompt will tell.
      return LocationAccess.askable;
    }
  }

  @override
  Future<LocationAccess> requestAccess() async {
    try {
      return locationAccessFromPermission(await Geolocator.requestPermission());
    } on Exception {
      return LocationAccess.askable;
    }
  }

  @override
  Future<DevicePosition> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationUnavailableException(LocationProblem.serviceOff);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: locationTimeout),
      );
      return DevicePosition(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMetres: position.accuracy,
      );
    } on LocationUnavailableException {
      rethrow;
    } on TimeoutException {
      throw const LocationUnavailableException(LocationProblem.timeout);
    } on LocationServiceDisabledException {
      throw const LocationUnavailableException(LocationProblem.serviceOff);
    } on Exception {
      throw const LocationUnavailableException(LocationProblem.unavailable);
    }
  }

  @override
  bool get canOpenSettings => !kIsWeb;

  @override
  Future<bool> openSettings() async {
    if (!canOpenSettings) {
      return false;
    }
    try {
      return await Geolocator.openAppSettings();
    } on Exception {
      return false;
    }
  }
}
