import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/platform/location/device_position.dart';
import 'package:wasli_customer/core/platform/location/location_access.dart';
import 'package:wasli_customer/core/platform/location/location_unavailable_exception.dart';
import 'package:wasli_customer/features/account/presentation/sign_in_page.dart';
import 'package:wasli_customer/features/settings/presentation/settings_page.dart';
import 'package:wasli_customer/features/start/domain/nearby_restaurant.dart';
import 'package:wasli_customer/features/start/domain/nearby_restaurants.dart';
import 'package:wasli_customer/features/start/presentation/restaurant_card.dart';
import 'package:wasli_customer/features/start/presentation/start_page.dart';

import '../../../support/bidi.dart';
import '../../../support/fake_location_service.dart';
import '../../../support/fake_nearby_repository.dart';
import '../../../support/pump_app.dart';

Finder get _allow => find.widgetWithText(FilledButton, 'Use my location');

const _arabic = Locale('ar');

void main() {
  group('the start page asking for location', () {
    testWidgets('explains first, and shows the system prompt only when the button is pressed', (tester) async {
      final location = FakeLocationService();
      final nearby = FakeNearbyRepository.listing();
      await pumpApp(tester, location: location, nearby: nearby);

      expect(find.text('Find restaurants near you'), findsOneWidget);
      expect(find.textContaining('We use your location'), findsOneWidget);
      expect(find.textContaining('Scan its QR code'), findsOneWidget);
      expect(location.requests, 0);
      expect(location.reads, 0);
      expect(nearby.points, isEmpty);

      await tester.tap(_allow);
      await tester.pumpAndSettle();

      expect(location.requests, 1);
      expect(find.text('Find restaurants near you'), findsNothing);
      expect(find.text('Restaurants near you'), findsOneWidget);
      expect(nearby.points, [(latitude: 25.2048, longitude: 55.2708)]);
    });

    testWidgets('skips the explanation and the prompt when the customer already allowed location', (tester) async {
      final location = FakeLocationService(current: LocationAccess.allowed);
      await pumpApp(tester, location: location);

      expect(find.text('Find restaurants near you'), findsNothing);
      expect(find.byType(RestaurantCard), findsNWidgets(2));
      expect(location.requests, 0);
    });

    testWidgets('shows a spinner while the position is read', (tester) async {
      final gate = Completer<void>();
      await pumpApp(
        tester,
        location: FakeLocationService(current: LocationAccess.allowed, gate: gate),
        settle: false,
      );

      expect(find.text('Finding your location…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      gate.complete();
      await tester.pumpAndSettle();

      expect(find.text('Finding your location…'), findsNothing);
      expect(find.byType(RestaurantCard), findsNWidgets(2));
    });

    testWidgets('a refusal that can be asked again offers the button again', (tester) async {
      final location = FakeLocationService(afterRequest: LocationAccess.askable);
      await pumpApp(tester, location: location);

      await tester.tap(_allow);
      await tester.pumpAndSettle();

      expect(find.text('Location is not allowed'), findsOneWidget);
      expect(find.textContaining('Without your location'), findsOneWidget);
      expect(find.textContaining('Scan its QR code'), findsOneWidget);
      expect(_allow, findsOneWidget);
    });

    testWidgets('a refusal for good says where to change it and offers "Try again" after the customer did', (
      tester,
    ) async {
      final location = FakeLocationService(current: LocationAccess.blocked);
      await pumpApp(tester, location: location);

      expect(find.textContaining('Location is blocked'), findsOneWidget);
      expect(find.text('Open settings'), findsNothing);

      location.current = LocationAccess.allowed;
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.byType(RestaurantCard), findsNWidgets(2));
      expect(location.requests, 0);
    });

    testWidgets('a phone offers to open its settings', (tester) async {
      final location = FakeLocationService(current: LocationAccess.blocked, canOpenSettings: true);
      await pumpApp(tester, location: location);

      await tester.tap(find.widgetWithText(FilledButton, 'Open settings'));
      await tester.pumpAndSettle();

      expect(location.settingsOpened, 1);
      expect(find.widgetWithText(TextButton, 'Try again'), findsOneWidget);
    });

    testWidgets('says when location is off on the device', (tester) async {
      await pumpApp(
        tester,
        location: FakeLocationService(current: LocationAccess.allowed, problem: LocationProblem.serviceOff),
      );

      expect(find.text('Location is turned off'), findsOneWidget);
      expect(find.text('Turn on location on your device, then try again.'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
    });

    testWidgets('says when no position arrived', (tester) async {
      await pumpApp(
        tester,
        location: FakeLocationService(current: LocationAccess.allowed, problem: LocationProblem.timeout),
      );

      expect(find.text('We could not find you'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Try again'), findsOneWidget);
    });
  });

  group('the start page listing restaurants', () {
    testWidgets('shows each restaurant with its distance and whether it is open', (tester) async {
      await pumpApp(tester, location: FakeLocationService(current: LocationAccess.allowed));

      expect(find.text('Demo Cafe'), findsOneWidget);
      expect(find.text('120 m away'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(find.text('Sample Grill'), findsOneWidget);
      expect(find.text('340 m away'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      final first = tester.getTopLeft(find.text('Demo Cafe')).dy;
      expect(tester.getTopLeft(find.text('Sample Grill')).dy, greaterThan(first));
    });

    testWidgets('shows placeholder rows while the list loads', (tester) async {
      final semantics = tester.ensureSemantics();
      final pending = Completer<NearbyRestaurants>();
      await pumpApp(
        tester,
        location: FakeLocationService(current: LocationAccess.allowed),
        nearby: FakeNearbyRepository((_) => pending.future),
      );

      expect(find.bySemanticsLabel('Loading restaurants'), findsOneWidget);
      expect(find.byType(RestaurantCard), findsNothing);

      pending.complete(const NearbyRestaurants(restaurants: [demoCafe]));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Loading restaurants'), findsNothing);
      expect(find.byType(RestaurantCard), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('says why the list failed and loads it again on "Try again"', (tester) async {
      final nearby = FakeNearbyRepository.failing(const NetworkFailure(NetworkFailureKind.offline));
      await pumpApp(
        tester,
        location: FakeLocationService(current: LocationAccess.allowed),
        nearby: nearby,
      );

      expect(find.text('You are offline. Check your connection and try again.'), findsOneWidget);

      nearby.onNearby = (_) async => const NearbyRestaurants(restaurants: [demoCafe]);
      await tester.tap(find.widgetWithText(TextButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.byType(RestaurantCard), findsOneWidget);
      expect(nearby.points, hasLength(2));
    });

    testWidgets('the refresh button reads the position and the list again', (tester) async {
      final location = FakeLocationService(current: LocationAccess.allowed);
      final nearby = FakeNearbyRepository.listing();
      await pumpApp(tester, location: location, nearby: nearby);

      await tester.tap(find.byTooltip('Refresh the list'));
      await tester.pumpAndSettle();

      expect(location.reads, 2);
      expect(nearby.points, hasLength(2));
    });

    testWidgets('names the restaurants in Arabic and keeps the distance left to right', (tester) async {
      await pumpApp(
        tester,
        location: FakeLocationService(current: LocationAccess.allowed),
        savedLocale: _arabic,
      );

      expect(find.text('مقهى تجريبي'), findsOneWidget);
      expect(find.text('على بعد ${ltr('120 م')}'), findsOneWidget);
      expect(find.text('مفتوح'), findsOneWidget);
      expect(find.text('مغلق'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(StartPage))), TextDirection.rtl);
    });
  });

  group('the start page with no restaurant in range', () {
    const farAway = DevicePosition(latitude: 25.3, longitude: 55.4);

    // No restaurant serves the customer's own position, but one serves a customer standing at Demo Cafe.
    FakeNearbyRepository nothingHere({NearbyRestaurant? nearest}) => FakeNearbyRepository(
      (point) async => point == demoCafe.position
          ? const NearbyRestaurants(restaurants: [demoCafe])
          : NearbyRestaurants(restaurants: const [], nearest: nearest),
    );

    testWidgets('names the closest restaurant, how far it is and how far from it cars are served', (tester) async {
      await pumpApp(
        tester,
        location: FakeLocationService(current: LocationAccess.allowed, position: farAway),
        nearby: nothingHere(nearest: demoCafe),
      );

      expect(find.text('No restaurant serves your spot yet. The closest is Demo Cafe, 120 m away.'), findsOneWidget);
      expect(find.text('It serves cars within 500 m.'), findsOneWidget);
      expect(find.textContaining('Scan its QR code'), findsOneWidget);
    });

    testWidgets('leaves out the service distance when the closest restaurant sets none', (tester) async {
      await pumpApp(
        tester,
        location: FakeLocationService(current: LocationAccess.allowed, position: farAway),
        nearby: nothingHere(nearest: sampleGrill),
      );

      expect(find.textContaining('Sample Grill'), findsOneWidget);
      expect(find.textContaining('It serves cars within'), findsNothing);
    });

    testWidgets('says so when no restaurant is known at all', (tester) async {
      await pumpApp(
        tester,
        location: FakeLocationService(current: LocationAccess.allowed, position: farAway),
        nearby: nothingHere(),
      );

      expect(find.text('No restaurants are available near you yet.'), findsOneWidget);
      expect(find.text("Simulate: I'm at the restaurant"), findsNothing);
    });

    testWidgets('a test build can pretend to stand at the closest restaurant, and go back', (tester) async {
      final location = FakeLocationService(current: LocationAccess.allowed, position: farAway);
      final nearby = nothingHere(nearest: demoCafe);
      await pumpApp(tester, location: location, nearby: nearby);

      await tester.tap(find.text("Simulate: I'm at the restaurant"));
      await tester.pumpAndSettle();

      expect(nearby.points.last, demoCafe.position);
      expect(find.byType(RestaurantCard), findsOneWidget);
      expect(find.text('You are using a simulated position.'), findsOneWidget);

      await tester.tap(find.text('Use my real location'));
      await tester.pumpAndSettle();

      expect(find.text('You are using a simulated position.'), findsNothing);
      expect(find.textContaining('No restaurant serves your spot yet'), findsOneWidget);
    });

    testWidgets('a production build has no way to pretend', (tester) async {
      await pumpApp(
        tester,
        environment: testEnvironment(appEnv: 'production'),
        location: FakeLocationService(current: LocationAccess.allowed, position: farAway),
        nearby: nothingHere(nearest: demoCafe),
      );

      expect(find.textContaining('No restaurant serves your spot yet'), findsOneWidget);
      expect(find.text("Simulate: I'm at the restaurant"), findsNothing);
    });
  });

  group('the top bar of the start page', () {
    testWidgets('offers sign-in to a signed-out customer and opens the sign-in page', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Sign in'));
      await tester.pumpAndSettle();

      expect(find.byType(SignInPage), findsOneWidget);
    });

    testWidgets('offers no sign-in to a signed-in customer', (tester) async {
      await pumpApp(tester, signedIn: true);

      expect(find.byTooltip('Sign in'), findsNothing);
    });

    testWidgets('opens the settings', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });

    testWidgets('shows the server status line in a test build', (tester) async {
      await pumpApp(tester);

      expect(find.textContaining('Server connected'), findsOneWidget);
    });

    testWidgets('shows no server status line in production', (tester) async {
      await pumpApp(tester, environment: testEnvironment(appEnv: 'production'));

      expect(find.textContaining('Server connected'), findsNothing);
    });
  });

  group('the start page layout', () {
    for (final locale in [null, _arabic]) {
      for (final allowed in [false, true]) {
        testWidgets('survives the largest text scale on a small phone without overflow '
            '(${locale ?? 'en'}, ${allowed ? 'the list' : 'the explanation'})', (tester) async {
          tester.view
            ..physicalSize = const Size(360, 640)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          tester.platformDispatcher.textScaleFactorTestValue = 2;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

          await pumpApp(
            tester,
            savedLocale: locale,
            location: FakeLocationService(current: allowed ? LocationAccess.allowed : LocationAccess.askable),
          );

          expect(tester.takeException(), isNull);
          expect(find.byType(RestaurantCard), allowed ? findsNWidgets(2) : findsNothing);
        });
      }
    }

    testWidgets('keeps the list in a column no wider than the content width on a wide window', (tester) async {
      tester.view
        ..physicalSize = const Size(1400, 900)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpApp(tester, location: FakeLocationService(current: LocationAccess.allowed));

      expect(tester.getSize(find.byType(RestaurantCard).first).width, lessThanOrEqualTo(560));
    });

    testWidgets('is the page at /', (tester) async {
      await pumpApp(tester);

      expect(find.byType(StartPage), findsOneWidget);
    });
  });
}
