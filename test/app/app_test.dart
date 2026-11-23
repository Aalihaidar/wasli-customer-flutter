import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/app.dart';
import 'package:wasli_customer/app/placeholder_page.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/theme/theme.dart';

Future<void> _pumpApp(WidgetTester tester, {List<Locale> deviceLocales = const [Locale('en', 'US')]}) async {
  await tester.pumpWidget(
    ProviderScope(overrides: [deviceLocalesProvider.overrideWithValue(deviceLocales)], child: const App()),
  );
}

BuildContext _pageContext(WidgetTester tester) => tester.element(find.byType(PlaceholderPage));

void main() {
  group('English device', () {
    testWidgets('shows the name, left to right, in the Wasli theme and the Rubik font', (tester) async {
      await _pumpApp(tester);

      final context = _pageContext(tester);
      expect(find.text('Wasli'), findsOneWidget);
      expect(Directionality.of(context), TextDirection.ltr);
      expect(Theme.of(context).scaffoldBackgroundColor, WasliColors.light.background);
      expect(context.wasliText.body.fontFamily, 'Rubik');
      expect(Localizations.localeOf(context), const Locale('en'));
    });

    testWidgets('names the app in the task switcher from the translation', (tester) async {
      await _pumpApp(tester);

      expect(tester.widget<Title>(find.byType(Title)).title, 'Wasli');
    });
  });

  group('Arabic device', () {
    testWidgets('lays the page out right to left, with Arabic Material strings and no letter spacing', (tester) async {
      await _pumpApp(tester, deviceLocales: const [Locale('ar', 'AE')]);

      final context = _pageContext(tester);
      expect(Directionality.of(context), TextDirection.rtl);
      expect(Localizations.localeOf(context), const Locale('ar'));
      expect(context.wasliText.display.letterSpacing, 0);
      expect(MaterialLocalizations.of(context).backButtonTooltip, isNot('Back'));
      expect(context.l10n.languageSwitchLabel, 'اللغة');
    });
  });

  group('a device in another language', () {
    testWidgets('starts in English', (tester) async {
      await _pumpApp(tester, deviceLocales: const [Locale('fr', 'FR')]);

      expect(Directionality.of(_pageContext(tester)), TextDirection.ltr);
      expect(Localizations.localeOf(_pageContext(tester)), const Locale('en'));
    });
  });

  group('the language switch', () {
    testWidgets('names each language in its own language', (tester) async {
      await _pumpApp(tester);

      expect(find.text('English'), findsOneWidget);
      expect(find.text('العربية'), findsOneWidget);
    });

    testWidgets('switches to Arabic and back, mirroring the layout and relabelling the control', (tester) async {
      await _pumpApp(tester);

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();

      expect(Directionality.of(_pageContext(tester)), TextDirection.rtl);
      expect(_pageContext(tester).l10n.languageSwitchLabel, 'اللغة');
      expect(_pageContext(tester).wasliText.display.letterSpacing, 0);

      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      expect(Directionality.of(_pageContext(tester)), TextDirection.ltr);
      expect(_pageContext(tester).l10n.languageSwitchLabel, 'Language');
      expect(_pageContext(tester).wasliText.display.letterSpacing, isNot(0));
    });

    testWidgets('is a labelled group for screen readers and its segments are at least 48 high', (tester) async {
      final handle = tester.ensureSemantics();
      await _pumpApp(tester);

      expect(find.bySemanticsLabel('Language'), findsOneWidget);
      expect(tester.getSize(find.byType(SegmentedButton<Locale>)).height, greaterThanOrEqualTo(48));
      handle.dispose();
    });

    testWidgets('survives the largest text scale (200 %) without overflow, in both languages', (tester) async {
      tester.view
        ..physicalSize = const Size(360, 640)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _pumpApp(tester);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('العربية'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
