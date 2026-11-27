import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/l10n/locale_store.dart';
import 'package:wasli_customer/features/settings/presentation/settings_page.dart';
import 'package:wasli_customer/features/start/presentation/start_page.dart';
import 'package:wasli_customer/theme/theme.dart';

import '../../../support/pump_app.dart';

Locale _selected(WidgetTester tester) => tester.widget<RadioGroup<Locale>>(find.byType(RadioGroup<Locale>)).groupValue!;

BuildContext _settingsContext(WidgetTester tester) => tester.element(find.byType(SettingsPage));

void main() {
  group('the language setting', () {
    testWidgets('offers English and Arabic, each named in its own language, with English chosen first', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.settings);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
      expect(_selected(tester), const Locale('en'));
    });

    testWidgets('switches the whole app to Arabic, right to left, and back again', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.settings);

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      expect(_selected(tester), const Locale('ar'));
      expect(Directionality.of(_settingsContext(tester)), TextDirection.rtl);
      expect(find.text('الإعدادات'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
      expect(_settingsContext(tester).wasliText.display.letterSpacing, 0);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(_selected(tester), const Locale('en'));
      expect(Directionality.of(_settingsContext(tester)), TextDirection.ltr);
      expect(find.text('Settings'), findsOneWidget);
      expect(_settingsContext(tester).wasliText.display.letterSpacing, isNot(0));
    });

    testWidgets('remembers the choice for the next visit', (tester) async {
      final store = MemoryLocaleStore();
      await pumpApp(tester, initialLocation: AppRoutes.settings, store: store);

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      expect(await store.read(), const Locale('ar'));
    });

    testWidgets('starts in the language that was saved and shows it as chosen', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.settings, savedLocale: const Locale('ar'));

      expect(_selected(tester), const Locale('ar'));
      expect(Directionality.of(_settingsContext(tester)), TextDirection.rtl);
      expect(find.text('الإعدادات'), findsOneWidget);
    });

    testWidgets('keeps the language when the customer leaves and comes back', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(StartPage), findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(StartPage))), TextDirection.rtl);
    });

    testWidgets('has radio buttons for screen readers, each at least 48 high, with the chosen one checked', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, initialLocation: AppRoutes.settings);

      for (final name in ['English', 'العربية']) {
        final tile = find.ancestor(of: find.text(name), matching: find.byType(RadioListTile<Locale>));
        expect(tester.getSize(tile).height, greaterThanOrEqualTo(48), reason: name);
        expect(tester.getSemantics(find.text(name)), isSemantics(label: name, hasTapAction: true));
      }

      final radios = find.byType(Radio<Locale>);
      expect(tester.getSemantics(radios.at(0)), isSemantics(hasCheckedState: true, isChecked: true));
      expect(tester.getSemantics(radios.at(1)), isSemantics(hasCheckedState: true, isChecked: false));
      handle.dispose();
    });
  });

  group('leaving the settings', () {
    testWidgets('goes back to the start page when it was opened from there', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.byType(BackButton), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(find.byType(StartPage), findsOneWidget);
    });

    testWidgets('offers a way to the start page when it was opened from its address', (tester) async {
      await pumpApp(tester, initialLocation: AppRoutes.settings);

      expect(find.byType(BackButton), findsNothing);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(StartPage), findsOneWidget);
    });
  });

  group('the layout', () {
    testWidgets('survives the largest text scale (200 %) without overflow, in both languages', (tester) async {
      tester.view
        ..physicalSize = const Size(360, 640)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await pumpApp(tester, initialLocation: AppRoutes.settings);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
