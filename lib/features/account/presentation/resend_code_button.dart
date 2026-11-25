import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/format/countdown.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/core/widgets/second_ticker.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/application/resend_code_controller.dart';

/// The "send a new code" button: disabled with the time left until the server allows another code, then enabled.
class ResendCodeButton extends ConsumerWidget {
  /// Creates the button for [pending].
  const new({required this.pending, super.key});

  /// The code that was sent, which says when the next one may be asked for.
  final PendingVerification pending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final busy = ref.watch(resendCodeControllerProvider.select((state) => state.isLoading));

    return SecondTicker(
      builder: (context) {
        final left = pending.resendAvailableAt.difference(ref.read(clockProvider)());
        final waiting = left > Duration.zero;
        return TextButton(
          onPressed: waiting || busy ? null : () => unawaited(ref.read(resendCodeControllerProvider.notifier).submit()),
          child: Text(
            waiting ? l10n.verifyResendIn(time: isolateLeftToRight(formatCountdown(left))) : l10n.verifyResend,
          ),
        );
      },
    );
  }
}
