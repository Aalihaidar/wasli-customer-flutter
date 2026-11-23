import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/app/app.dart';
import 'package:wasli_customer/app/router/app_router.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/core/l10n/locale_store.dart';

/// Starts the whole app on [initialLocation], in the language [savedLocale] (English when it is null), and lets it
/// settle. [store] receives the language the customer chooses.
Future<void> pumpApp(
  WidgetTester tester, {
  String initialLocation = AppRoutes.home,
  LocaleStore? store,
  Locale? savedLocale,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
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
