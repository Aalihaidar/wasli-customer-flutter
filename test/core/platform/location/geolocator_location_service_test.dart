import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wasli_customer/core/platform/location/geolocator_location_service.dart';
import 'package:wasli_customer/core/platform/location/location_access.dart';

void main() {
  group('locationAccessFromPermission', () {
    test('allowed while in use or always', () {
      expect(locationAccessFromPermission(LocationPermission.whileInUse), LocationAccess.allowed);
      expect(locationAccessFromPermission(LocationPermission.always), LocationAccess.allowed);
    });

    test('a refusal for good is blocked', () {
      expect(locationAccessFromPermission(LocationPermission.deniedForever), LocationAccess.blocked);
    });

    test('not asked yet, refused once, or unknown can still be asked', () {
      expect(locationAccessFromPermission(LocationPermission.denied), LocationAccess.askable);
      expect(locationAccessFromPermission(LocationPermission.unableToDetermine), LocationAccess.askable);
    });
  });

  test('settings can be opened on a phone, not in a browser', () {
    // The test VM is not a browser, so the service reports what a phone would.
    expect(const GeolocatorLocationService().canOpenSettings, isTrue);
  });
}
