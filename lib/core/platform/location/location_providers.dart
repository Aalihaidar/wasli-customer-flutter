import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/platform/location/geolocator_location_service.dart';
import 'package:wasli_customer/core/platform/location/location_service.dart';

/// The device's location. The running app uses the plugin implementation; tests replace it with a fake, so no test
/// reaches a platform.
final locationServiceProvider = Provider<LocationService>((ref) => const GeolocatorLocationService());
