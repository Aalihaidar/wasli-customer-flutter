import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/time/clock.dart';
import 'package:wasli_customer/core/widgets/labeled_field.dart';
import 'package:wasli_customer/core/widgets/second_ticker.dart';
import 'package:wasli_customer/features/account/application/pending_verification.dart';
import 'package:wasli_customer/features/account/presentation/code_input_formatter.dart';
import 'package:wasli_customer/features/account/presentation/form_error.dart';
import 'package:wasli_customer/features/account/presentation/resend_code_button.dart';
import 'package:wasli_customer/theme/theme.dart';

/// How many digits the code has.
const int _codeLength = 6;

/// Where the customer types the 6-digit code that was sent to them: the explanation, the code field, the error, the
/// confirm button and the button for a new code.
///
/// Used by the sign-up code page and by the page that adds a contact, which differ only in what they do with the code.
/// The field empties itself when a new code is sent.
class CodeEntryForm extends ConsumerStatefulWidget {
  /// Creates the form for the code [pending]. [body] explains where the code went. [onSubmit] receives the six digits,
  /// [onResend] asks for a new code. [submitting] and [resending] say that those calls are running, and [error] is the
  /// failure of the last one, written for the customer by [errorText].
  const new({
    required this.pending,
    required this.body,
    required this.onSubmit,
    required this.onResend,
    required this.submitting,
    required this.resending,
    required this.error,
    required this.errorText,
    super.key,
  });

  /// The code that was sent.
  final PendingVerification pending;

  /// The text above the field, already in the customer's language.
  final String body;

  /// Called with the six digits when the customer confirms.
  final ValueChanged<String> onSubmit;

  /// Called when the customer asks for a new code.
  final VoidCallback onResend;

  /// Whether the code is being checked.
  final bool submitting;

  /// Whether a new code is being asked for.
  final bool resending;

  /// The failure of the last call, or `null`.
  final Object? error;

  /// Writes the message for a failure.
  final String Function(AppLocalizations l10n, Object error) errorText;

  @override
  ConsumerState<CodeEntryForm> createState() => _CodeEntryFormState();
}

class _CodeEntryFormState extends ConsumerState<CodeEntryForm> {
  final _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(CodeEntryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pending.sentAt != widget.pending.sentAt) {
      _code.clear();
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    if (_code.text.length == _codeLength) {
      widget.onSubmit(_code.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pending = widget.pending;

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.body, style: context.wasliText.body),
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
              final error = widget.error;
              final message = expired
                  ? l10n.verifyCodeExpired
                  : error == null
                  ? null
                  : widget.errorText(l10n, error);
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
            onPressed: widget.submitting || _code.text.length != _codeLength ? null : _submit,
            child: widget.submitting
                ? const SizedBox.square(dimension: WasliSpacing.space5, child: CircularProgressIndicator())
                : Text(l10n.verifySubmit),
          ),
          const SizedBox(height: WasliSpacing.space2),
          ResendCodeButton(pending: pending, onResend: widget.onResend, busy: widget.resending),
        ],
      ),
    );
  }
}
