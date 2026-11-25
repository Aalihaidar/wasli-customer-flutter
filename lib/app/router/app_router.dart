import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wasli_customer/app/not_found_page.dart';
import 'package:wasli_customer/app/placeholder_page.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/presentation/sign_up_page.dart';
import 'package:wasli_customer/features/account/presentation/verify_code_page.dart';
import 'package:wasli_customer/features/settings/presentation/settings_page.dart';

/// Builds the router of the app.
///
/// URLs are plain paths on the web (`usePathUrlStrategy` in `bootstrap`). An address that matches no route shows the
/// page-not-found page. [initialLocation] lets a test start on another page. The code page has nothing to show without a
/// code that was sent, so [hasPendingVerification] tells it when to send the customer back to the sign-up page.
GoRouter createAppRouter({String initialLocation = AppRoutes.home, bool Function()? hasPendingVerification}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const PlaceholderPage()),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => SettingsPage(onGoToStart: () => context.go(AppRoutes.home)),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) =>
            SignUpPage(onGoToStart: () => context.go(AppRoutes.home), onCodeSent: () => context.push(AppRoutes.verify)),
      ),
      GoRoute(
        path: AppRoutes.verify,
        redirect: (context, state) => (hasPendingVerification?.call() ?? false) ? null : AppRoutes.signUp,
        builder: (context, state) => VerifyCodePage(onSignedIn: () => context.go(AppRoutes.home)),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
}

/// The router of the running app, created once and disposed with the app.
final routerProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter(hasPendingVerification: () => ref.read(pendingVerificationProvider) != null);
  ref.onDispose(router.dispose);
  return router;
});
