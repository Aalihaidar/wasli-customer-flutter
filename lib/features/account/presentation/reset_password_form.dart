import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/core/widgets/labeled_field.dart';
import 'package:wasli_customer/core/widgets/second_ticker.dart';
import 'package:wasli_customer/features/account/application/confirm_password_reset_controller.dart';
import 'package:wasli_customer/features/account/application/password_reset_flow.dart';
import 'package:wasli_customer/features/account/application/request_password_reset_controller.dart';
import 'package:wasli_customer/features/account/presentation/account_failure_text.dart';
import 'package:wasli_customer/features/account/presentation/code_input_formatter.dart';
import 'package:wasli_customer/features/account/presentation/form_error.dart';
import 'package:wasli_customer/features/account/presentation/password_field.dart';
import 'package:wasli_customer/theme/theme.dart';

/// How many digits the code has.
const int _codeLength = 6;

/// The second step of the password reset: the 6-digit code and the new password, and a button for a new code.
class ResetPasswordForm extends ConsumerStatefulWidget {
  /// Creates the form. It reads the step from [passwordResetFlowProvider].
  const new({super.key});

  @override
  ConsumerState<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_code.text.length == _codeLength && _formKey.currentState!.validate()) {
      unawaited(
        ref.read(confirmPasswordResetControllerProvider.notifier).submit(code: _code.text, newPassword: _password.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final step = ref.watch(passwordResetFlowProvider);
    final confirming = ref.watch(confirmPasswordResetControllerProvider);
    final requesting = ref.watch(requestPasswordResetControllerProvider);
    ref.listen(passwordResetFlowProvider, (previous, next) {
      if (previous is ResetEnteringCode && next is ResetEnteringCode && previous.expiresAt != next.expiresAt) {
        _code.clear();
      }
    });
    if (step is! ResetEnteringCode) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space5),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.forgotCodeBody(identifier: isolateLeftToRight(step.identifier)), style: context.wasliText.body),
            const SizedBox(height: WasliSpacing.space4),
            LabeledField(
              label: l10n.verifyCodeLabel,
              child: TextField(
                controller: _code,
                autofocus: true,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: const [CodeInputFormatter()],
                style: context.wasliText.heading2,
              ),
            ),
            const SizedBox(height: WasliSpacing.space4),
            PasswordField(
              controller: _password,
              label: l10n.forgotNewPasswordLabel,
              validator: (value) => (value ?? '').isEmpty ? l10n.fieldRequired : null,
              onFieldSubmitted: (_) => _submit(),
            ),
            SecondTicker(
              builder: (context) {
                final expired = !ref.read(clockProvider)().isBefore(step.expiresAt);
                final error = confirming.error ?? requesting.error;
                final message = expired
                    ? l10n.verifyCodeExpired
                    : error == null
                    ? null
                    : (confirming.hasError
                          ? resetPasswordFailureText(l10n, error)
                          : requestResetFailureText(l10n, error));
                return message == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsetsDirectional.only(top: WasliSpacing.space4),
                        child: FormError(message: message),
                      );
              },
            ),
            const SizedBox(height: WasliSpacing.space5),
            FilledButton(
              onPressed: confirming.isLoading || _code.text.length != _codeLength ? null : _submit,
              child: confirming.isLoading
                  ? const SizedBox.square(dimension: WasliSpacing.space5, child: CircularProgressIndicator())
                  : Text(l10n.forgotSubmit),
            ),
            const SizedBox(height: WasliSpacing.space2),
            TextButton(
              onPressed: requesting.isLoading
                  ? null
                  : () => unawaited(ref.read(requestPasswordResetControllerProvider.notifier).resend()),
              child: Text(l10n.verifyResend),
            ),
          ],
        ),
      ),
    );
  }
}
