import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/core/widgets/labeled_field.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/core/widgets/second_ticker.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/application/resend_code_controller.dart';
import 'package:wasli_customer/features/account/application/verify_code_controller.dart';
import 'package:wasli_customer/features/account/presentation/account_failure_text.dart';
import 'package:wasli_customer/features/account/presentation/code_input_formatter.dart';
import 'package:wasli_customer/features/account/presentation/form_error.dart';
import 'package:wasli_customer/features/account/presentation/resend_code_button.dart';
import 'package:wasli_customer/theme/theme.dart';

/// How many digits the code has.
const int _codeLength = 6;

/// The page where the customer types the 6-digit code that was sent to their email or phone, and asks for a new one.
///
/// When the code is accepted the customer is signed in and the page opens the start page.
class VerifyCodePage extends ConsumerStatefulWidget {
  /// Creates the page. [onSignedIn] opens the start page once the code is accepted.
  const new({required this.onSignedIn, super.key});

  /// Called when the code was accepted and the customer is signed in.
  final VoidCallback onSignedIn;

  @override
  ConsumerState<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends ConsumerState<VerifyCodePage> {
  final _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    if (_code.text.length == _codeLength) {
      unawaited(ref.read(verifyCodeControllerProvider.notifier).submit(_code.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pending = ref.watch(pendingVerificationProvider);
    final verifying = ref.watch(verifyCodeControllerProvider);
    final resending = ref.watch(resendCodeControllerProvider);
    ref.listen(pendingVerificationProvider, (previous, next) {
      if (previous != null && next == null) {
        widget.onSignedIn();
      }
      if (previous != null && next != null && previous.sentAt != next.sentAt) {
        _code.clear();
      }
    });
    final error = verifying.error ?? resending.error;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyTitle)),
      body: SafeArea(
        child: PageFrame(
          child: pending == null
              ? const SizedBox.shrink()
              : SingleChildScrollView(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.verifyBody(identifier: isolateLeftToRight(pending.sent.identifier)),
                        style: context.wasliText.body,
                      ),
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
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                      SecondTicker(
                        builder: (context) {
                          final expired = !ref.read(clockProvider)().isBefore(pending.expiresAt);
                          final message = expired
                              ? l10n.verifyCodeExpired
                              : error == null
                              ? null
                              : codeFailureText(l10n, error);
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
                        onPressed: verifying.isLoading || _code.text.length != _codeLength ? null : _submit,
                        child: verifying.isLoading
                            ? const SizedBox.square(dimension: WasliSpacing.space5, child: CircularProgressIndicator())
                            : Text(l10n.verifySubmit),
                      ),
                      const SizedBox(height: WasliSpacing.space2),
                      ResendCodeButton(pending: pending),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
