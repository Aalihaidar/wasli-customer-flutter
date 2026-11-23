import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

void main() {
  group('WindowSizeClass.fromWidth', () {
    test('below 600 is compact', () {
      expect(WindowSizeClass.fromWidth(0), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(320), WindowSizeClass.compact);
      expect(WindowSizeClass.fromWidth(599.9), WindowSizeClass.compact);
    });

    test('600 to 839 is medium', () {
      expect(WindowSizeClass.fromWidth(600), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(768), WindowSizeClass.medium);
      expect(WindowSizeClass.fromWidth(839.9), WindowSizeClass.medium);
    });

    test('840 and up is expanded', () {
      expect(WindowSizeClass.fromWidth(840), WindowSizeClass.expanded);
      expect(WindowSizeClass.fromWidth(1440), WindowSizeClass.expanded);
    });
  });

  group('the page gutter', () {
    test('is 16 on a phone and 24 above', () {
      expect(WindowSizeClass.compact.pageGutter, 16);
      expect(WindowSizeClass.medium.pageGutter, 24);
      expect(WindowSizeClass.expanded.pageGutter, 24);
    });
  });

  group('WindowSizeClass.of', () {
    Future<WindowSizeClass> classAt(WidgetTester tester, Size size) async {
      late WindowSizeClass result;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: size),
          child: Builder(
            builder: (context) {
              result = WindowSizeClass.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      return result;
    }

    testWidgets('reads the width of the window', (tester) async {
      expect(await classAt(tester, const Size(390, 844)), WindowSizeClass.compact);
      expect(await classAt(tester, const Size(700, 900)), WindowSizeClass.medium);
      expect(await classAt(tester, const Size(1280, 800)), WindowSizeClass.expanded);
    });
  });
}
