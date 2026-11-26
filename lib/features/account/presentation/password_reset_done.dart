import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The last step of the password reset: the password was changed, and the way to sign in with the new one.
class PasswordResetDone extends StatelessWidget {
  /// Creates the step. [onGoToSignIn] opens the sign-in page.
  const new({required this.onGoToSignIn, super.key});

  /// Opens the sign-in page.
  final VoidCallback onGoToSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline, color: context.wasli.statusOkForeground, size: WasliSpacing.space6),
              const SizedBox(width: WasliSpacing.space3),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(l10n.forgotDoneTitle, style: context.wasliText.heading3),
                ),
              ),
            ],
          ),
          const SizedBox(height: WasliSpacing.space3),
          Text(l10n.forgotDoneBody, style: context.wasliText.body),
          const SizedBox(height: WasliSpacing.space5),
          FilledButton(onPressed: onGoToSignIn, child: Text(l10n.signInSubmit)),
        ],
      ),
    );
  }
}
