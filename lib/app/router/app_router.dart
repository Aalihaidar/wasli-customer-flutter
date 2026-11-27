import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/not_found_page.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/core/session/session_state.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/domain/contact_kind.dart';
import 'package:wasli_customer/features/account/presentation/account_section.dart';
import 'package:wasli_customer/features/account/presentation/add_contact_page.dart';
import 'package:wasli_customer/features/account/presentation/forgot_password_page.dart';
import 'package:wasli_customer/features/account/presentation/sign_in_page.dart';
import 'package:wasli_customer/features/account/presentation/sign_up_page.dart';
import 'package:wasli_customer/features/account/presentation/verify_code_page.dart';
import 'package:wasli_customer/features/server_config/presentation/server_status_line.dart';
import 'package:wasli_customer/features/settings/presentation/settings_page.dart';
import 'package:wasli_customer/features/start/presentation/start_page.dart';

/// Builds the router of the app.
///
/// URLs are plain paths on the web (`usePathUrlStrategy` in `bootstrap`). An address that matches no route shows the
/// page-not-found page. [initialLocation] lets a test start on another page. The code page has nothing to show without a
/// code that was sent, so [hasPendingVerification] tells it when to send the customer back to the sign-up
/// page, and [isSignedIn] sends a signed-in customer away from the sign-in, sign-up and password-reset pages and a signed-out one away
/// from the pages that add a contact (they need an account).
GoRouter createAppRouter({
  String initialLocation = AppRoutes.home,
  bool Function()? hasPendingVerification,
  bool Function()? isSignedIn,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    // A signed-in customer has nothing to do on the sign-in, sign-up and password-reset pages; a signed-out one cannot add a contact.
    redirect: (context, state) {
      final path = state.uri.path;
      final signedIn = isSignedIn?.call() ?? false;
      final onAccountEntry = path == AppRoutes.signIn || path == AppRoutes.signUp || path == AppRoutes.forgotPassword;
      final onContactPage = path == AppRoutes.addEmail || path == AppRoutes.addPhone;
      if (onAccountEntry && signedIn) {
        return AppRoutes.home;
      }
      return onContactPage && !signedIn ? AppRoutes.signIn : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => StartPage(
          onOpenSettings: () => context.push(AppRoutes.settings),
          onSignIn: () => context.push(AppRoutes.signIn),
          serverStatus: const ServerStatusLine(),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => SettingsPage(
          onGoToStart: () => context.go(AppRoutes.home),
          accountSection: AccountSection(
            onSignIn: () => context.push(AppRoutes.signIn),
            onSignUp: () => context.push(AppRoutes.signUp),
            onAddContact: (kind) => context.push(switch (kind) {
              ContactKind.email => AppRoutes.addEmail,
              ContactKind.phone => AppRoutes.addPhone,
            }),
          ),
        ),
      ),
      GoRoute(path: AppRoutes.addEmail, builder: (context, state) => _addContactPage(context, ContactKind.email)),
      GoRoute(path: AppRoutes.addPhone, builder: (context, state) => _addContactPage(context, ContactKind.phone)),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => SignInPage(
          onGoToStart: () => context.go(AppRoutes.home),
          onSignedIn: () => context.go(AppRoutes.home),
          onGoToSignUp: () => context.pushReplacement(AppRoutes.signUp),
          onForgotPassword: () => context.push(AppRoutes.forgotPassword),
          onCodeSent: () => context.push(AppRoutes.verify),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => ForgotPasswordPage(onGoToSignIn: () => context.go(AppRoutes.signIn)),
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

Widget _addContactPage(BuildContext context, ContactKind kind) => AddContactPage(
  kind: kind,
  onGoToSettings: () => context.go(AppRoutes.settings),
  onDone: () => context.canPop() ? context.pop() : context.go(AppRoutes.settings),
);

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
