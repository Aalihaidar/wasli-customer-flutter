import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:wasli_customer/app/app.dart';

/// Prepares the app and starts it.
///
/// Web URLs use plain paths (`/r/<slug>`) instead of a hash. Off the web the call does nothing.
void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const App());
}
