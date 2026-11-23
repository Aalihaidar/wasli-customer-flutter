import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:wasli_customer/app/app.dart';

/// Prepares the app and starts it.
///
/// Web URLs use plain paths (`/r/<slug>`) instead of a hash. Off the web the call does nothing. The whole app runs
/// inside one [ProviderScope], which holds its state.
void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const ProviderScope(child: App()));
}
