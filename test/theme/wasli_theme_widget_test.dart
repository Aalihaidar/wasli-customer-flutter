import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A page with each styled component, to build under every theme, direction and text scale.
class _Gallery extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wasli')),
      body: ListView(
        padding: const EdgeInsets.all(WasliSpacing.space4),
        children: [
          FilledButton(onPressed: () {}, child: const Text('Send the order')),
          const SizedBox(height: WasliSpacing.space2),
          OutlinedButton(onPressed: () {}, child: const Text('Edit')),
          const SizedBox(height: WasliSpacing.space2),
          TextButton(onPressed: () {}, child: const Text('Cancel')),
          const SizedBox(height: WasliSpacing.space2),
          const FilledButton(onPressed: null, child: Text('Disabled')),
          const SizedBox(height: WasliSpacing.space2),
          const TextField(decoration: InputDecoration(hintText: 'Plate number')),
          const SizedBox(height: WasliSpacing.space2),
          const TextField(decoration: InputDecoration(errorText: 'Required')),
          const SizedBox(height: WasliSpacing.space2),
          const Card(
            child: Padding(padding: EdgeInsets.all(WasliSpacing.space4), child: Text('Demo Cafe')),
          ),
          const LinearProgressIndicator(),
          const Divider(),
          Text('AED 12.50', style: context.wasliText.bodyStrong),
          Text('placed', style: TextStyle(color: context.wasli.statusWarnForeground)),
        ],
      ),
    );
  }
}

void main() {
  Future<void> pumpGallery(
    WidgetTester tester, {
    required ThemeData theme,
    required TextDirection direction,
    double textScale = 1,
  }) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: Directionality(textDirection: direction, child: child!),
        ),
        home: const _Gallery(),
      ),
    );
  }

  final themes = {
    'light English': (WasliTheme.light(const Locale('en')), TextDirection.ltr),
    'dark English': (WasliTheme.dark(const Locale('en')), TextDirection.ltr),
    'light Arabic': (WasliTheme.light(const Locale('ar')), TextDirection.rtl),
    'dark Arabic': (WasliTheme.dark(const Locale('ar')), TextDirection.rtl),
  };

  for (final MapEntry(key: name, value: (theme, direction)) in themes.entries) {
    group(name, () {
      testWidgets('builds every styled component without an error', (tester) async {
        await pumpGallery(tester, theme: theme, direction: direction);

        expect(tester.takeException(), isNull);
        expect(find.byType(FilledButton), findsNWidgets(2));
        expect(find.byType(TextField), findsNWidgets(2));
      });

      testWidgets('survives the largest text scale (200 %) without overflow', (tester) async {
        await pumpGallery(tester, theme: theme, direction: direction, textScale: 2);

        expect(tester.takeException(), isNull);
      });

      testWidgets('every button is at least 48 logical pixels high', (tester) async {
        await pumpGallery(tester, theme: theme, direction: direction);

        for (final type in [FilledButton, OutlinedButton, TextButton]) {
          expect(tester.getSize(find.byType(type).first).height, greaterThanOrEqualTo(48));
        }
      });

      testWidgets('every text input is at least 52 logical pixels high', (tester) async {
        await pumpGallery(tester, theme: theme, direction: direction);

        expect(tester.getSize(find.byType(TextField).first).height, greaterThanOrEqualTo(52));
      });
    });
  }

  testWidgets('a button is announced as a button with its label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpGallery(tester, theme: WasliTheme.light(const Locale('en')), direction: TextDirection.ltr);

    expect(
      tester.getSemantics(find.widgetWithText(FilledButton, 'Send the order')),
      matchesSemantics(
        label: 'Send the order',
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('context.wasli returns the tokens of the active brightness', (tester) async {
    late WasliColors read;
    await tester.pumpWidget(
      MaterialApp(
        theme: WasliTheme.dark(const Locale('en')),
        home: Builder(
          builder: (context) {
            read = context.wasli;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(read, WasliColors.dark);
  });

  testWidgets('WasliMotion.adapt returns zero when the system asks to reduce motion', (tester) async {
    late Duration normal;
    late Duration reduced;
    await tester.pumpWidget(
      Column(
        children: [
          MediaQuery(
            data: const MediaQueryData(),
            child: Builder(
              builder: (context) {
                normal = WasliMotion.adapt(context, WasliMotion.standard);
                return const SizedBox();
              },
            ),
          ),
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Builder(
              builder: (context) {
                reduced = WasliMotion.adapt(context, WasliMotion.standard);
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );

    expect(normal, WasliMotion.standard);
    expect(reduced, Duration.zero);
  });
}
