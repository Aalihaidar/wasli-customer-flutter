import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/core/session/session_state.dart';
import 'package:wasli_customer/core/widgets/labeled_field.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/features/account/application/contact_input.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/application/sign_in_controller.dart';
import 'package:wasli_customer/features/account/presentation/account_failure_text.dart';
import 'package:wasli_customer/features/account/presentation/form_error.dart';
import 'package:wasli_customer/features/account/presentation/password_field.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The sign-in page: the email or phone number the customer signed up with, and the password.
///
/// An account that was never confirmed goes to the code page with a new code instead of showing an error.
class SignInPage extends ConsumerStatefulWidget {
  /// Creates the page. [onGoToStart] is the way back when the page was opened from its address, [onSignedIn] opens the
  /// start page once the customer is signed in, [onGoToSignUp] opens the sign-up page and [onCodeSent] opens the code
  /// page.
  const new({
    required this.onGoToStart,
    required this.onSignedIn,
    required this.onGoToSignUp,
    required this.onCodeSent,
    super.key,
  });

  /// Opens the start page.
  final VoidCallback onGoToStart;

  /// Called when the customer is signed in.
  final VoidCallback onSignedIn;

  /// Opens the sign-up page.
  final VoidCallback onGoToSignUp;

  /// Opens the page where the customer types the code.
  final VoidCallback onCodeSent;

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final contact = contactFromInput(_identifier.text);
    if (contact == null) {
      return;
    }
    unawaited(ref.read(signInControllerProvider.notifier).submit(identifier: contact.value, password: _password.text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(signInControllerProvider);
    ref.listen(sessionProvider, (previous, next) {
      if (next is SignedIn) {
        widget.onSignedIn();
      }
    });
    ref.listen(pendingVerificationProvider, (previous, next) {
      if (next != null) {
        widget.onCodeSent();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.signInTitle),
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                icon: const BackButtonIcon(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: widget.onGoToStart,
              ),
      ),
      body: SafeArea(
        child: PageFrame(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space5),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LabeledField(
                    label: l10n.signInIdentifierLabel,
                    child: TextFormField(
                      controller: _identifier,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      validator: (value) => contactFromInput(value ?? '') == null ? l10n.fieldRequired : null,
                    ),
                  ),
                  const SizedBox(height: WasliSpacing.space4),
                  PasswordField(
                    controller: _password,
                    label: l10n.signInPasswordLabel,
                    autofillHint: AutofillHints.password,
                    validator: (value) => (value ?? '').isEmpty ? l10n.fieldRequired : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (state.error case final error?) ...[
                    const SizedBox(height: WasliSpacing.space4),
                    FormError(message: signInFailureText(l10n, error)),
                  ],
                  const SizedBox(height: WasliSpacing.space5),
                  FilledButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const SizedBox.square(dimension: WasliSpacing.space5, child: CircularProgressIndicator())
                        : Text(l10n.signInSubmit),
                  ),
                  const SizedBox(height: WasliSpacing.space2),
                  TextButton(onPressed: widget.onGoToSignUp, child: Text(l10n.signInGoToSignUp)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
