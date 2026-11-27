import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/not_found_page.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/platform/location/location_access.dart';
import 'package:wasli_customer/features/start/domain/restaurant_profile.dart';
import 'package:wasli_customer/features/start/presentation/restaurant_card.dart';
import 'package:wasli_customer/features/start/presentation/restaurant_page.dart';
import 'package:wasli_customer/features/start/presentation/start_page.dart';

import '../../../support/fake_location_service.dart';
import '../../../support/fake_restaurant_profile_repository.dart';
import '../../../support/pump_app.dart';

const _link = '/r/demo-cafe';

void main() {
  group('the restaurant page opened from a link', () {
    testWidgets('shows the restaurant and asks for its slug without any login', (tester) async {
      final repository = FakeRestaurantProfileRepository.value();
      await pumpApp(tester, initialLocation: _link, restaurants: repository);

      expect(find.byType(RestaurantPage), findsOneWidget);
      expect(find.text('Demo Cafe'), findsOneWidget);
      expect(repository.slugs, ['demo-cafe']);
    });

    testWidgets('shows the Arabic name, right to left', (tester) async {
      await pumpApp(tester, initialLocation: _link, savedLocale: const Locale('ar'));

      expect(find.text('مقهى تجريبي'), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(RestaurantPage))), TextDirection.rtl);
    });

    testWidgets('offers the start page, since there is nothing to go back to', (tester) async {
      await pumpApp(tester, initialLocation: _link);

      await tester.tap(find.byTooltip('Go to the start page'));
      await tester.pumpAndSettle();

      expect(find.byType(StartPage), findsOneWidget);
    });

    testWidgets('shows a spinner while the restaurant loads', (tester) async {
      final semantics = tester.ensureSemantics();
      final pending = Completer<RestaurantProfile>();
      await pumpApp(
        tester,
        initialLocation: _link,
        restaurants: FakeRestaurantProfileRepository((_) => pending.future),
        settle: false,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.bySemanticsLabel('Loading the restaurant'), findsOneWidget);

      pending.complete(demoCafeProfile);
      await tester.pumpAndSettle();

      expect(find.text('Demo Cafe'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a restaurant that does not exist says so and leads to the start page', (tester) async {
      await pumpApp(
        tester,
        initialLocation: _link,
        restaurants: FakeRestaurantProfileRepository.failing(const NotFoundFailure()),
      );

      expect(find.text('This restaurant is not available'), findsOneWidget);
      expect(find.textContaining('The link may be old'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Go to the start page'));
      await tester.pumpAndSettle();

      expect(find.byType(StartPage), findsOneWidget);
    });

    testWidgets('another failure says why and loads the restaurant again on "Try again"', (tester) async {
      final repository = FakeRestaurantProfileRepository.failing(const NetworkFailure(NetworkFailureKind.offline));
      await pumpApp(tester, initialLocation: _link, restaurants: repository);

      expect(find.text('You are offline. Check your connection and try again.'), findsOneWidget);

      repository.onRead = (_) async => demoCafeProfile;
      await tester.tap(find.widgetWithText(FilledButton, 'Try again'));
      await tester.pumpAndSettle();

      expect(find.text('Demo Cafe'), findsOneWidget);
      expect(repository.slugs, hasLength(2));
    });

    testWidgets('survives the largest text scale on a small phone without overflow', (tester) async {
      tester.view
        ..physicalSize = const Size(360, 640)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(
        tester,
        initialLocation: _link,
        restaurants: FakeRestaurantProfileRepository.failing(const NotFoundFailure()),
        savedLocale: const Locale('ar'),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('an address that is not a restaurant', () {
    for (final path in ['/r/nearby', '/r/-demo', '/r/demo.cafe', '/r/${Uri.encodeComponent('a b')}']) {
      testWidgets('$path is "not found" and asks the server nothing', (tester) async {
        final repository = FakeRestaurantProfileRepository.value();
        await pumpApp(tester, initialLocation: path, restaurants: repository);

        expect(find.byType(NotFoundPage), findsOneWidget);
        expect(repository.slugs, isEmpty);
      });
    }

    testWidgets('a dot-segment slug is resolved away by the router and never reaches the server', (tester) async {
      final repository = FakeRestaurantProfileRepository.value();
      await pumpApp(tester, initialLocation: '/r/%2E%2E', restaurants: repository);

      expect(find.byType(RestaurantPage), findsNothing);
      expect(repository.slugs, isEmpty);
    });

    testWidgets('/r with no slug matches no page', (tester) async {
      await pumpApp(tester, initialLocation: '/r');

      expect(find.byType(NotFoundPage), findsOneWidget);
    });
  });

  group('the restaurant page opened from the list', () {
    testWidgets('a tap on a restaurant opens its page, and back returns to the list', (tester) async {
      final repository = FakeRestaurantProfileRepository.value();
      await pumpApp(
        tester,
        location: FakeLocationService(current: LocationAccess.allowed),
        restaurants: repository,
      );

      await tester.tap(find.byType(RestaurantCard).first);
      await tester.pumpAndSettle();

      expect(find.byType(RestaurantPage), findsOneWidget);
      expect(repository.slugs, ['demo-cafe']);
      expect(find.byTooltip('Go to the start page'), findsNothing);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(RestaurantCard), findsNWidgets(2));
    });

    testWidgets('the route path keeps one segment whatever the slug holds', (tester) async {
      expect(AppRoutes.restaurantPath('demo-cafe'), '/r/demo-cafe');
      expect(AppRoutes.restaurantPath('a/b'), '/r/a%2Fb');
    });
  });
}
