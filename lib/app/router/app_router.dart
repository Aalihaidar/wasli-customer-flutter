import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wasli_customer/app/not_found_page.dart';
import 'package:wasli_customer/app/placeholder_page.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/features/settings/presentation/settings_page.dart';

/// Builds the router of the app.
///
/// URLs are plain paths on the web (`usePathUrlStrategy` in `bootstrap`). An address that matches no route shows the
/// page-not-found page. [initialLocation] lets a test start on another page.
GoRouter createAppRouter({String initialLocation = AppRoutes.home}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const PlaceholderPage()),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => SettingsPage(onGoToStart: () => context.go(AppRoutes.home)),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}

/// The router of the running app, created once and disposed with the app.
final routerProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});
