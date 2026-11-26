import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/application/resend_code_controller.dart';
import 'package:wasli_customer/features/account/application/verify_code_controller.dart';
import 'package:wasli_customer/features/account/presentation/account_failure_text.dart';
import 'package:wasli_customer/features/account/presentation/code_entry_form.dart';

/// The page where the customer types the 6-digit code that was sent to their email or phone, and asks for a new one.
///
/// When the code is accepted the customer is signed in and the page opens the start page.
class VerifyCodePage extends ConsumerWidget {
  /// Creates the page. [onSignedIn] opens the start page once the code is accepted.
  const new({required this.onSignedIn, super.key});

  /// Called when the code was accepted and the customer is signed in.
  final VoidCallback onSignedIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pending = ref.watch(pendingVerificationProvider);
    final verifying = ref.watch(verifyCodeControllerProvider);
    final resending = ref.watch(resendCodeControllerProvider);
    ref.listen(pendingVerificationProvider, (previous, next) {
      if (previous != null && next == null) {
        onSignedIn();
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyTitle)),
      body: SafeArea(
        child: PageFrame(
          child: pending == null
              ? const SizedBox.shrink()
              : CodeEntryForm(
                  pending: pending,
                  body: l10n.verifyBody(identifier: isolateLeftToRight(pending.sent.identifier)),
                  onSubmit: (code) => unawaited(ref.read(verifyCodeControllerProvider.notifier).submit(code)),
                  onResend: () => unawaited(ref.read(resendCodeControllerProvider.notifier).submit()),
                  submitting: verifying.isLoading,
                  resending: resending.isLoading,
                  error: verifying.error ?? resending.error,
                  errorText: codeFailureText,
                ),
        ),
      ),
    );
  }
}
