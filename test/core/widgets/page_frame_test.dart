import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';

const _childKey = Key('child');

Future<Rect> _childRect(
  WidgetTester tester, {
  required Size window,
  TextDirection direction = TextDirection.ltr,
}) async {
  tester.view
    ..physicalSize = window
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    Directionality(
      textDirection: direction,
      child: MediaQuery.fromView(
        view: tester.view,
        child: const PageFrame(child: SizedBox.expand(key: _childKey)),
      ),
    ),
  );
  return tester.getRect(find.byKey(_childKey));
}

void main() {
  group('PageFrame', () {
    testWidgets('on a phone the content fills the width except for a 16 gutter on each side', (tester) async {
      final rect = await _childRect(tester, window: const Size(390, 800));

      expect(rect.left, 16);
      expect(rect.right, 390 - 16);
    });

    testWidgets('on a tablet the gutter is 24 and the column is 560 wide', (tester) async {
      final rect = await _childRect(tester, window: const Size(700, 900));

      expect(rect.left, (700 - 560) / 2 + 24);
      expect(rect.width, 560 - 2 * 24);
    });

    testWidgets('on a wide window the column stays 560 wide and centred', (tester) async {
      final rect = await _childRect(tester, window: const Size(1440, 900));

      expect(rect.left, (1440 - 560) / 2 + 24);
      expect(rect.width, 560 - 2 * 24);
      expect((rect.left + rect.right) / 2, 1440 / 2);
    });

    testWidgets('lays out the same in a right-to-left language', (tester) async {
      final ltr = await _childRect(tester, window: const Size(390, 800));
      final rtl = await _childRect(tester, window: const Size(390, 800), direction: TextDirection.rtl);

      expect(rtl, ltr);
    });

    testWidgets('keeps the content at the top, not in the middle of a tall window', (tester) async {
      final rect = await _childRect(tester, window: const Size(390, 800));

      expect(rect.top, 0);
      expect(rect.height, 800);
    });
  });
}
