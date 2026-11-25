import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasli_customer/app/app.dart';
import 'package:wasli_customer/app/config_error_app.dart';
import 'package:wasli_customer/app/error_handlers.dart';
import 'package:wasli_customer/core/config/app_config_exception.dart';
import 'package:wasli_customer/core/config/app_environment.dart';
import 'package:wasli_customer/core/config/app_environment_provider.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/core/l10n/locale_store.dart';
import 'package:wasli_customer/core/logging/app_logger.dart';
import 'package:wasli_customer/core/storage/shared_preferences_locale_store.dart';

/// Prepares the app and starts it.
///
/// Errors that nothing catches are written to the app's logger from the first line on (`installErrorHandlers`). Web URLs use plain paths (`/r/<slug>`) instead of a hash. Off the web the call does nothing. The language the
/// customer saved is read before the first frame, so the app never flashes the wrong language. The build's configuration is read and
/// checked first: when it is wrong the app opens a plain [ConfigErrorApp] instead of failing on every request. The whole
/// app runs inside one [ProviderScope], which holds its state.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  installErrorHandlers(const ConsoleAppLogger());
  usePathUrlStrategy();

  final LocaleStore localeStore = SharedPreferencesLocaleStore(SharedPreferencesAsync());
  final savedLocale = await localeStore.read();

  final AppEnvironment environment;
  try {
    environment = AppEnvironment.fromBuild();
  } on AppConfigException catch (error) {
    runApp(ConfigErrorApp(error: error, locale: savedLocale));
    return;
  }

  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(environment),
        localeStoreProvider.overrideWithValue(localeStore),
        savedLocaleProvider.overrideWithValue(savedLocale),
      ],
      child: const App(),
    ),
  );
}
