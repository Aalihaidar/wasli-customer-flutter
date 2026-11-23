import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

/// Root widget of the customer app.
///
/// A placeholder until the router and the localisation exist: it applies the theme (light or dark by the system
/// setting) and shows the app name. The locale is fixed to English here; the localisation block replaces it with the
/// customer's language and rebuilds the theme when it changes.
class App extends StatelessWidget {
  /// Creates the root widget.
  const new({super.key});

  static const _locale = Locale('en');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wasli',
      theme: WasliTheme.light(_locale),
      darkTheme: WasliTheme.dark(_locale),
      home: const Scaffold(body: Center(child: Text('Wasli'))),
    );
  }
}
