import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/theme/theme.dart';

/// Shown instead of the chat to a customer who is not signed in: an order needs an account, so it offers to sign in or to
/// create one, and the sign-in leads back to the restaurant.
class SignInGate extends StatelessWidget {
  /// Creates the gate. [onSignIn] and [onSignUp] open those pages.
  const new({required this.onSignIn, required this.onSignUp, super.key});

  /// Opens the sign-in page.
  final VoidCallback onSignIn;

  /// Opens the sign-up page.
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(WasliSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(header: true, child: Text(l10n.chatSignInTitle, style: context.wasliText.heading2)),
            const SizedBox(height: WasliSpacing.space2),
            Text(l10n.chatSignInBody, style: context.wasliText.body),
            const SizedBox(height: WasliSpacing.space4),
            FilledButton(onPressed: onSignIn, child: Text(l10n.signInSubmit)),
            const SizedBox(height: WasliSpacing.space2),
            TextButton(onPressed: onSignUp, child: Text(l10n.signUpSubmit)),
          ],
        ),
      ),
    );
  }
}
