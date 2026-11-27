import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/features/start/presentation/start_page.dart';
import 'package:wasli_customer/theme/theme.dart';

import '../support/pump_app.dart';

BuildContext _pageContext(WidgetTester tester) => tester.element(find.byType(StartPage));

void main() {
  group('the start page', () {
    testWidgets('is in English, left to right, in the Wasli theme and the Rubik font', (tester) async {
      await pumpApp(tester);

      final context = _pageContext(tester);
      expect(find.text('Wasli'), findsOneWidget); // the top bar
      expect(Directionality.of(context), TextDirection.ltr);
      expect(Localizations.localeOf(context), const Locale('en'));
      expect(Theme.of(context).scaffoldBackgroundColor, WasliColors.light.background);
      expect(context.wasliText.body.fontFamily, 'Rubik');
    });

    testWidgets('stays in English whatever language the device uses', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('ar', 'AE'), Locale('fr', 'FR')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await pumpApp(tester);

      expect(Localizations.localeOf(_pageContext(tester)), const Locale('en'));
      expect(Directionality.of(_pageContext(tester)), TextDirection.ltr);
    });

    testWidgets('names the app in the task switcher from the translation', (tester) async {
      await pumpApp(tester);

      expect(tester.widget<Title>(find.byType(Title)).title, 'Wasli');
    });

    testWidgets('has a labelled button that opens the settings', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester);

      expect(find.bySemanticsLabel('Settings'), findsOneWidget);
      expect(find.bySemanticsLabel('Sign in'), findsOneWidget);
      for (final button in tester.widgetList(find.byType(IconButton)).indexed) {
        expect(tester.getSize(find.byType(IconButton).at(button.$1)).shortestSide, greaterThanOrEqualTo(48));
      }

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('in Arabic is right to left with Arabic Material strings and no letter spacing', (tester) async {
      await pumpApp(tester, savedLocale: const Locale('ar'));

      final context = _pageContext(tester);
      expect(Directionality.of(context), TextDirection.rtl);
      expect(Localizations.localeOf(context), const Locale('ar'));
      expect(context.wasliText.display.letterSpacing, 0);
      expect(MaterialLocalizations.of(context).backButtonTooltip, isNot('Back'));
      expect(find.byTooltip('الإعدادات'), findsOneWidget);
    });
  });
}
