import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/labeled_field.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/features/account/application/add_contact_flow.dart';
import 'package:wasli_customer/features/account/application/contact_input.dart';
import 'package:wasli_customer/features/account/application/send_contact_code_controller.dart';
import 'package:wasli_customer/features/account/application/verify_contact_controller.dart';
import 'package:wasli_customer/features/account/domain/contact_kind.dart';
import 'package:wasli_customer/features/account/presentation/account_failure_text.dart';
import 'package:wasli_customer/features/account/presentation/code_entry_form.dart';
import 'package:wasli_customer/features/account/presentation/form_error.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The page where a signed-in customer adds the contact their account is missing: the email address or the phone number,
/// then the 6-digit code that confirms it.
///
/// The contact is saved on the account only when the code is accepted. A contact that is already set is never changed.
class AddContactPage extends ConsumerStatefulWidget {
  /// Creates the page for the [kind] of contact to add. [onGoToSettings] is the way back when the page was opened from
  /// its address, and [onDone] is called once the contact is confirmed.
  const new({required this.kind, required this.onGoToSettings, required this.onDone, super.key});

  /// Which contact is being added.
  final ContactKind kind;

  /// Opens the settings page.
  final VoidCallback onGoToSettings;

  /// Called when the contact was confirmed and saved.
  final VoidCallback onDone;

  @override
  ConsumerState<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends ConsumerState<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _contact = TextEditingController();

  @override
  void dispose() {
    _contact.dispose();
    super.dispose();
  }

  void _send() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final contact = contactOfKind(widget.kind, _contact.text);
    if (contact != null) {
      unawaited(ref.read(sendContactCodeControllerProvider.notifier).submit(contact));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEmail = widget.kind == ContactKind.email;
    final verification = ref.watch(addContactFlowProvider);
    ref.listen(addContactFlowProvider, (previous, next) {
      if (previous != null && next == null) {
        widget.onDone();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEmail ? l10n.addContactEmailTitle : l10n.addContactPhoneTitle),
        leading: Navigator.canPop(context)
            ? null
            : IconButton(
                icon: const BackButtonIcon(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: widget.onGoToSettings,
              ),
      ),
      body: SafeArea(
        child: PageFrame(child: verification == null ? _contactStep(context) : _codeStep(context, verification)),
      ),
    );
  }

  Widget _contactStep(BuildContext context) {
    final l10n = context.l10n;
    final isEmail = widget.kind == ContactKind.email;
    final sending = ref.watch(sendContactCodeControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space5),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabeledField(
              label: isEmail ? l10n.addContactEmailLabel : l10n.addContactPhoneLabel,
              child: TextFormField(
                controller: _contact,
                autofocus: true,
                textDirection: TextDirection.ltr,
                keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.phone,
                autofillHints: isEmail ? const [AutofillHints.email] : const [AutofillHints.telephoneNumber],
                validator: (value) => contactOfKind(widget.kind, value ?? '') == null ? l10n.fieldRequired : null,
                decoration: InputDecoration(helperText: l10n.signUpContactHelper, helperMaxLines: 2),
                onFieldSubmitted: (_) => _send(),
              ),
            ),
            if (sending.error case final error?) ...[
              const SizedBox(height: WasliSpacing.space4),
              FormError(message: addContactFailureText(l10n, error)),
            ],
            const SizedBox(height: WasliSpacing.space5),
            FilledButton(
              onPressed: sending.isLoading ? null : _send,
              child: sending.isLoading
                  ? const SizedBox.square(dimension: WasliSpacing.space5, child: CircularProgressIndicator())
                  : Text(l10n.addContactSubmit),
            ),
          ],
        ),
      ),
    );
  }

  Widget _codeStep(BuildContext context, ContactVerification verification) {
    final l10n = context.l10n;
    final verifying = ref.watch(verifyContactControllerProvider);
    final sending = ref.watch(sendContactCodeControllerProvider);

    return CodeEntryForm(
      pending: verification.pending,
      body: l10n.verifyBody(identifier: isolateLeftToRight(verification.pending.sent.identifier)),
      onSubmit: (code) => unawaited(ref.read(verifyContactControllerProvider.notifier).submit(code)),
      onResend: () => unawaited(ref.read(sendContactCodeControllerProvider.notifier).resend()),
      submitting: verifying.isLoading,
      resending: sending.isLoading,
      error: verifying.error ?? sending.error,
      errorText: contactCodeFailureText,
    );
  }
}
