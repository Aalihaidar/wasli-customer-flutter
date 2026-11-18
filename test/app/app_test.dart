import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/app.dart';

void main() {
  testWidgets('App shows the placeholder page', (tester) async {
    await tester.pumpWidget(const App());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Wasli'), findsOneWidget);
  });
}
