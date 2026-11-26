import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/labeled_field.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/features/account/application/contact_input.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/application/sign_up_controller.dart';
import 'package:wasli_customer/features/account/presentation/account_failure_text.dart';
import 'package:wasli_customer/features/account/presentation/form_error.dart';
import 'package:wasli_customer/features/account/presentation/password_field.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The longest full name the server accepts.
const int _fullNameMaxLength = 150;

/// The sign-up page: full name, one field for an email address or a phone number, and a password. The account's language
/// is the language the app shows, so the page asks nothing about it.
class SignUpPage extends ConsumerStatefulWidget {
  /// Creates the page. [onGoToStart] is the way back when the page was opened from its address; [onCodeSent] opens the
  /// code page once the server has sent the code and [onGoToSignIn] opens the sign-in page.
  const new({required this.onGoToStart, required this.onCodeSent, required this.onGoToSignIn, super.key});

  /// Opens the start page.
  final VoidCallback onGoToStart;

  /// Opens the page where the customer types the code.
  final VoidCallback onCodeSent;

  /// Opens the sign-in page.
  final VoidCallback onGoToSignIn;

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final contact = contactFromInput(_contact.text);
    if (contact == null) {
      return;
    }
    unawaited(
      ref
          .read(signUpControllerProvider.notifier)
          .submit(fullName: _name.text.trim(), contact: contact, password: _password.text),
    );
  }

  String? _required(String? value) => (value ?? '').trim().isEmpty ? context.l10n.fieldRequired : null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(signUpControllerProvider);
    ref.listen(pendingVerificationProvider, (previous, next) {
      if (next != null) {
        widget.onCodeSent();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.signUpTitle),
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
                    label: l10n.signUpNameLabel,
                    child: TextFormField(
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      inputFormatters: [LengthLimitingTextInputFormatter(_fullNameMaxLength)],
                      validator: _required,
                    ),
                  ),
                  const SizedBox(height: WasliSpacing.space4),
                  LabeledField(
                    label: l10n.signUpContactLabel,
                    child: TextFormField(
                      controller: _contact,
                      textDirection: TextDirection.ltr,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email, AutofillHints.telephoneNumber],
                      validator: (value) => contactFromInput(value ?? '') == null ? l10n.fieldRequired : null,
                      decoration: InputDecoration(helperText: l10n.signUpContactHelper, helperMaxLines: 2),
                    ),
                  ),
                  const SizedBox(height: WasliSpacing.space4),
                  PasswordField(
                    controller: _password,
                    label: l10n.signUpPasswordLabel,
                    validator: _required,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (state.error case final error?) ...[
                    const SizedBox(height: WasliSpacing.space4),
                    FormError(message: signUpFailureText(l10n, error)),
                  ],
                  const SizedBox(height: WasliSpacing.space5),
                  FilledButton(
                    onPressed: state.isLoading ? null : _submit,
                    child: state.isLoading
                        ? const SizedBox.square(dimension: WasliSpacing.space5, child: CircularProgressIndicator())
                        : Text(l10n.signUpSubmit),
                  ),
                  const SizedBox(height: WasliSpacing.space2),
                  TextButton(onPressed: widget.onGoToSignIn, child: Text(l10n.signUpGoToSignIn)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
