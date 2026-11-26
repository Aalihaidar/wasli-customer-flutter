import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';
import 'package:wasli_customer/core/l10n/failure_text.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/core/session/session_state.dart';
import 'package:wasli_customer/features/account/application/customer_profile.dart';
import 'package:wasli_customer/features/account/application/sign_out_controller.dart';
import 'package:wasli_customer/features/account/domain/contact_kind.dart';
import 'package:wasli_customer/features/account/domain/customer.dart';
import 'package:wasli_customer/features/account/presentation/form_error.dart';
import 'package:wasli_customer/features/account/presentation/verified_badge.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The account section of the settings.
///
/// Signed out, it offers to sign in or to create an account. Signed in, it shows the name and the email and phone with
/// whether each was confirmed, offers to add the one that is missing, and signs out. The settings page lives in another
/// feature, so the pages this section opens are callbacks that the router fills in.
class AccountSection extends ConsumerWidget {
  /// Creates the section. [onSignIn] and [onSignUp] open those pages; [onAddContact] opens the page that adds a
  /// contact of the given kind.
  const new({required this.onSignIn, required this.onSignUp, required this.onAddContact, super.key});

  /// Opens the sign-in page.
  final VoidCallback onSignIn;

  /// Opens the sign-up page.
  final VoidCallback onSignUp;

  /// Opens the page where the customer adds a contact of this kind.
  final ValueChanged<ContactKind> onAddContact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(l10n.settingsAccountTitle, style: context.wasliText.heading3)),
        const SizedBox(height: WasliSpacing.space2),
        Card(
          child: Padding(
            padding: const EdgeInsetsDirectional.all(WasliSpacing.space4),
            child: switch (ref.watch(sessionProvider)) {
              SignedOut() => _SignedOutView(onSignIn: onSignIn, onSignUp: onSignUp),
              SignedIn() => _SignedInView(onAddContact: onAddContact),
            },
          ),
        ),
      ],
    );
  }
}

class _SignedOutView extends StatelessWidget {
  const new({required this.onSignIn, required this.onSignUp});

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.settingsSignedOutBody, style: context.wasliText.body),
        const SizedBox(height: WasliSpacing.space4),
        FilledButton(onPressed: onSignIn, child: Text(l10n.signInSubmit)),
        const SizedBox(height: WasliSpacing.space2),
        TextButton(onPressed: onSignUp, child: Text(l10n.signUpSubmit)),
      ],
    );
  }
}

class _SignedInView extends ConsumerWidget {
  const new({required this.onAddContact});

  final ValueChanged<ContactKind> onAddContact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(customerProfileProvider);
    final signingOut = ref.watch(signOutControllerProvider.select((state) => state.isLoading));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        switch (profile) {
          AsyncData(:final value) => _ProfileView(customer: value, onAddContact: onAddContact),
          AsyncError(:final error) => _ProfileError(
            error: error,
            onRetry: () => ref.invalidate(customerProfileProvider),
          ),
          _ => const Padding(
            padding: EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space4),
            child: Center(child: CircularProgressIndicator()),
          ),
        },
        const SizedBox(height: WasliSpacing.space4),
        OutlinedButton(
          onPressed: signingOut ? null : () => unawaited(ref.read(signOutControllerProvider.notifier).submit()),
          child: signingOut
              ? const SizedBox.square(dimension: WasliSpacing.space5, child: CircularProgressIndicator())
              : Text(l10n.settingsSignOut),
        ),
      ],
    );
  }
}

class _ProfileError extends StatelessWidget {
  const new({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final failure = error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormError(message: failureText(l10n, failure is Failure ? failure : const UnexpectedFailure())),
        TextButton(onPressed: onRetry, child: Text(l10n.accountRetry)),
      ],
    );
  }
}

class _ProfileView extends StatelessWidget {
  const new({required this.customer, required this.onAddContact});

  final Customer customer;
  final ValueChanged<ContactKind> onAddContact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final email = customer.email;
    final phone = customer.phone;
    final missing = customer.missingContact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(customer.fullName, style: context.wasliText.heading3),
        if (email != null) _ContactRow(label: l10n.accountEmailLabel, value: email, verified: customer.emailVerified),
        if (phone != null) _ContactRow(label: l10n.accountPhoneLabel, value: phone, verified: customer.phoneVerified),
        if (missing != null) ...[
          const SizedBox(height: WasliSpacing.space4),
          OutlinedButton(
            onPressed: () => onAddContact(missing),
            child: Text(missing == ContactKind.email ? l10n.accountAddEmail : l10n.accountAddPhone),
          ),
          if (missing == ContactKind.phone) ...[
            const SizedBox(height: WasliSpacing.space2),
            Text(l10n.accountAddPhoneHint, style: context.wasliText.bodySmall),
          ],
        ],
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const new({required this.label, required this.value, required this.verified});

  final String label;
  final String value;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: WasliSpacing.space3),
      child: Wrap(
        spacing: WasliSpacing.space3,
        runSpacing: WasliSpacing.space1,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: context.wasliText.label),
              Text(isolateLeftToRight(value), style: context.wasliText.body),
            ],
          ),
          VerifiedBadge(verified: verified),
        ],
      ),
    );
  }
}
