import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/platform/location/device_position.dart';
import 'package:wasli_customer/core/platform/location/location_access.dart';
import 'package:wasli_customer/core/platform/location/location_providers.dart';
import 'package:wasli_customer/core/platform/location/location_unavailable_exception.dart';
import 'package:wasli_customer/features/start/application/start_location_controller.dart';
import 'package:wasli_customer/features/start/application/start_location_state.dart';
import 'package:wasli_customer/features/start/domain/position_source.dart';

import '../../../support/fake_location_service.dart';

ProviderContainer _containerWith(FakeLocationService service) {
  final container = ProviderContainer(overrides: [locationServiceProvider.overrideWithValue(service)]);
  addTearDown(container.dispose);
  return container;
}

/// Starts the controller, lets every pending answer arrive, and returns the state it settled in.
Future<StartLocationState> _settled(ProviderContainer container) {
  container.read(startLocationProvider);
  return pumpEventQueue().then((_) => container.read(startLocationProvider));
}

void main() {
  group('the start location', () {
    test('starts by checking, and shows nothing to the system before the screen has explained', () async {
      final service = FakeLocationService();
      final container = _containerWith(service);

      expect(container.read(startLocationProvider), isA<LocationChecking>());
      expect(await _settled(container), isA<LocationNeeded>());
      expect(service.requests, 0);
      expect(service.reads, 0);
    });

    test('reads the position at once when the customer already allowed it, without any prompt', () async {
      final service = FakeLocationService(current: LocationAccess.allowed);

      final state = await _settled(_containerWith(service));

      expect(state, isA<LocationFound>());
      final found = state as LocationFound;
      expect(found.coordinates, (latitude: 25.2048, longitude: 55.2708));
      expect(found.source, PositionSource.gps);
      expect(service.requests, 0);
    });

    test('says blocked, without a prompt, when the customer refused for good', () async {
      final service = FakeLocationService(current: LocationAccess.blocked);

      final state = await _settled(_containerWith(service));

      expect(state, isA<LocationDenied>().having((s) => s.blocked, 'blocked', isTrue));
      expect(service.requests, 0);
      expect(service.reads, 0);
    });

    test('shows the system prompt once per press and reads the position when it is allowed', () async {
      final service = FakeLocationService();
      final container = _containerWith(service);
      await _settled(container);

      await container.read(startLocationProvider.notifier).allow();

      expect(service.requests, 1);
      expect(container.read(startLocationProvider), isA<LocationFound>());
    });

    test('a refusal that can be asked again leads back to the button, and each press asks once', () async {
      final service = FakeLocationService(afterRequest: LocationAccess.askable);
      final container = _containerWith(service);
      await _settled(container);

      await container.read(startLocationProvider.notifier).allow();
      expect(container.read(startLocationProvider), isA<LocationDenied>().having((s) => s.blocked, 'blocked', isFalse));
      expect(service.requests, 1);

      await container.read(startLocationProvider.notifier).allow();
      expect(service.requests, 2);
    });

    test('a refusal for good is blocked', () async {
      final service = FakeLocationService(afterRequest: LocationAccess.blocked);
      final container = _containerWith(service);
      await _settled(container);

      await container.read(startLocationProvider.notifier).allow();

      expect(container.read(startLocationProvider), isA<LocationDenied>().having((s) => s.blocked, 'blocked', isTrue));
    });

    test('tells location off from a position that did not arrive', () async {
      for (final (problem, matcher) in [
        (LocationProblem.serviceOff, isA<LocationOff>()),
        (LocationProblem.timeout, isA<LocationFailed>()),
        (LocationProblem.unavailable, isA<LocationFailed>()),
      ]) {
        final service = FakeLocationService(current: LocationAccess.allowed, problem: problem);

        expect(await _settled(_containerWith(service)), matcher, reason: problem.name);
      }
    });

    test('"try again" looks at the decision again, after the customer changed it in the settings', () async {
      final service = FakeLocationService(current: LocationAccess.blocked);
      final container = _containerWith(service);
      await _settled(container);

      service.current = LocationAccess.allowed;
      await container.read(startLocationProvider.notifier).retry();

      expect(container.read(startLocationProvider), isA<LocationFound>());
      expect(service.requests, 0);
    });

    test('refreshing reads the position again and keeps the old one when it cannot', () async {
      final service = FakeLocationService(current: LocationAccess.allowed);
      final container = _containerWith(service);
      await _settled(container);

      service.position = const DevicePosition(latitude: 25.3, longitude: 55.4);
      await container.read(startLocationProvider.notifier).refresh();
      expect((container.read(startLocationProvider) as LocationFound).coordinates, (latitude: 25.3, longitude: 55.4));

      service.problem = LocationProblem.timeout;
      await container.read(startLocationProvider.notifier).refresh();
      expect((container.read(startLocationProvider) as LocationFound).coordinates, (latitude: 25.3, longitude: 55.4));
    });

    test('a simulated position is used as it is and refreshing leaves it alone', () async {
      final service = FakeLocationService(current: LocationAccess.allowed);
      final container = _containerWith(service);
      await _settled(container);
      final notifier = container.read(startLocationProvider.notifier)..simulateAt((latitude: 24.0, longitude: 54.0));
      final reads = service.reads;

      await notifier.refresh();

      final found = container.read(startLocationProvider) as LocationFound;
      expect(found.coordinates, (latitude: 24.0, longitude: 54.0));
      expect(found.source, PositionSource.simulated);
      expect(service.reads, reads);
    });

    test('opens the system settings through the service', () async {
      final service = FakeLocationService(current: LocationAccess.blocked, canOpenSettings: true);
      final container = _containerWith(service);
      await _settled(container);

      await container.read(startLocationProvider.notifier).openSettings();

      expect(service.settingsOpened, 1);
    });

    test('does nothing when the container is disposed before the answer arrives', () async {
      final service = FakeLocationService(current: LocationAccess.allowed);
      ProviderContainer(overrides: [locationServiceProvider.overrideWithValue(service)])
        ..read(startLocationProvider)
        ..dispose();
      await pumpEventQueue();

      // Reaching this line without an error from a late state write is the check.
      expect(service.reads, lessThanOrEqualTo(1));
    });
  });
}
