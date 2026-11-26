import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/labeled_field.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/features/account/application/contact_input.dart';
import 'package:wasli_customer/features/account/application/password_reset_flow.dart';
import 'package:wasli_customer/features/account/application/request_password_reset_controller.dart';
import 'package:wasli_customer/features/account/presentation/account_failure_text.dart';
import 'package:wasli_customer/features/account/presentation/form_error.dart';
import 'package:wasli_customer/features/account/presentation/password_reset_done.dart';
import 'package:wasli_customer/features/account/presentation/reset_password_form.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The page where a customer who forgot their password resets it: the email or phone number of the account, then the
/// code that was sent to it together with a new password.
///
/// The page never says whether an account exists for the contact: the server answers the same either way.
class ForgotPasswordPage extends ConsumerWidget {
  /// Creates the page. [onGoToSignIn] opens the sign-in page: it is the way back when the page was opened from its
  /// address, and where the customer goes once the password is changed.
  const new({required this.onGoToSignIn, super.key});

  /// Opens the sign-in page.
  final VoidCallback onGoToSignIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forgotTitle),
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                icon: const BackButtonIcon(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onGoToSignIn,
              ),
      ),
      body: SafeArea(
        child: PageFrame(
          child: switch (ref.watch(passwordResetFlowProvider)) {
            ResetEnteringContact() => const _ContactStep(),
            ResetEnteringCode() => const ResetPasswordForm(),
            ResetDone() => PasswordResetDone(onGoToSignIn: onGoToSignIn),
          },
        ),
      ),
    );
  }
}

class _ContactStep extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_ContactStep> createState() => _ContactStepState();
}

class _ContactStepState extends ConsumerState<_ContactStep> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final contact = contactFromInput(_identifier.text);
    if (contact != null) {
      unawaited(ref.read(requestPasswordResetControllerProvider.notifier).submit(contact.value));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(requestPasswordResetControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space5),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.forgotBody, style: context.wasliText.body),
            const SizedBox(height: WasliSpacing.space4),
            LabeledField(
              label: l10n.signInIdentifierLabel,
              child: TextFormField(
                controller: _identifier,
                autofocus: true,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.username],
                validator: (value) => contactFromInput(value ?? '') == null ? l10n.fieldRequired : null,
                onFieldSubmitted: (_) => _submit(),
              ),
            ),
            if (state.error case final error?) ...[
              const SizedBox(height: WasliSpacing.space4),
              FormError(message: requestResetFailureText(l10n, error)),
            ],
            const SizedBox(height: WasliSpacing.space5),
            FilledButton(
              onPressed: state.isLoading ? null : _submit,
              child: state.isLoading
                  ? const SizedBox.square(dimension: WasliSpacing.space5, child: CircularProgressIndicator())
                  : Text(l10n.forgotSendCode),
            ),
          ],
        ),
      ),
    );
  }
}
