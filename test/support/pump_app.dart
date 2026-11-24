import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/app/app.dart';
import 'package:wasli_customer/app/router/app_router.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/config/app_environment.dart';
import 'package:wasli_customer/core/config/app_environment_provider.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/core/l10n/locale_store.dart';
import 'package:wasli_customer/features/server_config/application/server_config_providers.dart';
import 'package:wasli_customer/features/server_config/domain/server_config_repository.dart';

import 'fake_server_config_repository.dart';

/// The build configuration most tests use: a staging build with invented addresses.
AppEnvironment testEnvironment({String? appEnv}) =>
    AppEnvironment.parse(appEnv: appEnv, apiBaseUrl: 'https://api.example.test/api/v1');

/// Starts the whole app on [initialLocation], in the language [savedLocale] (English when it is null), and lets it
/// settle. [store] receives the language the customer chooses. The build is a staging one ([environment] changes it) and
/// the server's settings come from [serverConfig] (a fake that answers at once by default): no test reaches a network.
Future<void> pumpApp(
  WidgetTester tester, {
  String initialLocation = AppRoutes.home,
  LocaleStore? store,
  Locale? savedLocale,
  AppEnvironment? environment,
  ServerConfigRepository? serverConfig,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(environment ?? testEnvironment()),
        serverConfigRepositoryProvider.overrideWithValue(serverConfig ?? FakeServerConfigRepository.value()),
        routerProvider.overrideWith((ref) {
          final router = createAppRouter(initialLocation: initialLocation);
          ref.onDispose(router.dispose);
          return router;
        }),
        if (store != null) localeStoreProvider.overrideWithValue(store),
        if (savedLocale != null) savedLocaleProvider.overrideWithValue(savedLocale),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}
