import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/app.dart';
import 'package:wasli_customer/theme/theme.dart';

void main() {
  testWidgets('App shows the placeholder page', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Wasli'), findsOneWidget);
  });

  testWidgets('App applies the Wasli theme, in the Rubik font', (tester) async {
    await tester.pumpWidget(const App());

    final context = tester.element(find.text('Wasli'));
    expect(Theme.of(context).scaffoldBackgroundColor, WasliColors.light.background);
    expect(context.wasliText.body.fontFamily, 'Rubik');
  });
}
