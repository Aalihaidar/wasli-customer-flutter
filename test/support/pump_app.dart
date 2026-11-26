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
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/core/session/session_state.dart';
import 'package:wasli_customer/core/storage/token_store.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/features/account/application/account_providers.dart';
import 'package:wasli_customer/features/account/domain/account_repository.dart';
import 'package:wasli_customer/features/server_config/application/server_config_providers.dart';
import 'package:wasli_customer/features/server_config/domain/server_config_repository.dart';

import 'fake_server_config_repository.dart';

/// The build configuration most tests use: a staging build with invented addresses.
AppEnvironment testEnvironment({String? appEnv}) =>
    AppEnvironment.parse(appEnv: appEnv, apiBaseUrl: 'https://api.example.test/api/v1');

/// A session that starts signed in, for the pages only a signed-in customer reaches. Everything else is the real
/// controller, so signing out and a `401` behave as in the app.
class _SignedInSession extends SessionController {
  @override
  SessionState build() {
    super.build();
    return const SignedIn();
  }
}

/// Starts the whole app on [initialLocation], in the language [savedLocale] (English when it is null), and lets it
/// settle. [account] and [clock] replace the account calls and the time. [store] receives the language the customer
/// chooses. The build is a staging one ([environment] changes it) and the server's settings come from [serverConfig]
/// (a fake that answers at once by default): no test reaches a network. With [signedIn] a customer is signed in from the
/// first frame (the web keeps no token across a reload, so the real app never starts that way). With [settle] false it
/// pumps one frame only, for a test that looks at something that keeps animating (a progress indicator).
Future<void> pumpApp(
  WidgetTester tester, {
  String initialLocation = AppRoutes.home,
  LocaleStore? store,
  Locale? savedLocale,
  AppEnvironment? environment,
  ServerConfigRepository? serverConfig,
  AccountRepository? account,
  Clock? clock,
  bool signedIn = false,
  bool settle = true,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvironmentProvider.overrideWithValue(environment ?? testEnvironment()),
        serverConfigRepositoryProvider.overrideWithValue(serverConfig ?? FakeServerConfigRepository.value()),
        if (account != null) accountRepositoryProvider.overrideWithValue(account),
        if (clock != null) clockProvider.overrideWithValue(clock),
        tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
        if (signedIn) sessionProvider.overrideWith(_SignedInSession.new),
        initialLocationProvider.overrideWithValue(initialLocation),
        if (store != null) localeStoreProvider.overrideWithValue(store),
        if (savedLocale != null) savedLocaleProvider.overrideWithValue(savedLocale),
      ],
      child: const App(),
    ),
  );
  await (settle ? tester.pumpAndSettle() : tester.pump());
}
