import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wasli_customer/app/not_found_page.dart';
import 'package:wasli_customer/app/placeholder_page.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/core/session/session_state.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/presentation/sign_in_page.dart';
import 'package:wasli_customer/features/account/presentation/sign_up_page.dart';
import 'package:wasli_customer/features/account/presentation/verify_code_page.dart';
import 'package:wasli_customer/features/settings/presentation/settings_page.dart';

/// Builds the router of the app.
///
/// URLs are plain paths on the web (`usePathUrlStrategy` in `bootstrap`). An address that matches no route shows the
/// page-not-found page. [initialLocation] lets a test start on another page. The code page has nothing to show without a
/// code that was sent, so [hasPendingVerification] tells it when to send the customer back to the sign-up
/// page, and [isSignedIn] sends a signed-in customer away from the sign-in and sign-up pages.
GoRouter createAppRouter({
  String initialLocation = AppRoutes.home,
  bool Function()? hasPendingVerification,
  bool Function()? isSignedIn,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    // A signed-in customer has nothing to do on the sign-in and sign-up pages.
    redirect: (context, state) {
      final path = state.uri.path;
      final onAccountEntry = path == AppRoutes.signIn || path == AppRoutes.signUp;
      return onAccountEntry && (isSignedIn?.call() ?? false) ? AppRoutes.home : null;
    },
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const PlaceholderPage()),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => SettingsPage(onGoToStart: () => context.go(AppRoutes.home)),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => SignInPage(
          onGoToStart: () => context.go(AppRoutes.home),
          onSignedIn: () => context.go(AppRoutes.home),
          onGoToSignUp: () => context.pushReplacement(AppRoutes.signUp),
          onCodeSent: () => context.push(AppRoutes.verify),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => SignUpPage(
          onGoToStart: () => context.go(AppRoutes.home),
          onCodeSent: () => context.push(AppRoutes.verify),
          onGoToSignIn: () => context.pushReplacement(AppRoutes.signIn),
        ),
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

/// Where the router starts. Tests replace it to open another page.
final initialLocationProvider = Provider<String>((ref) => AppRoutes.home);

/// The router of the running app, created once and disposed with the app.
///
/// When the server refuses the token (a `401`; the network layer has already cleared it) the session ends as expired and
/// the customer is sent to sign in. Listening here also makes the session follow `401`s from the first frame.
final routerProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter(
    initialLocation: ref.read(initialLocationProvider),
    hasPendingVerification: () => ref.read(pendingVerificationProvider) != null,
    isSignedIn: () => ref.read(sessionProvider) is SignedIn,
  );
  ref
    ..listen(sessionProvider, (previous, next) {
      if (next case SignedOut(expired: true)) {
        router.go(AppRoutes.signIn);
      }
    })
    ..onDispose(router.dispose);
  return router;
});
