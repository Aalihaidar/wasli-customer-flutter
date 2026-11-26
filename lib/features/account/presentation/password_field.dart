import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/labeled_field.dart';

/// A password field with a button that shows or hides what was typed.
///
/// The text is left to right in both languages, like an email address or a code, and is never kept by the keyboard's
/// suggestions.
class PasswordField extends StatefulWidget {
  /// Creates the field. [validator] and [onFieldSubmitted] behave as in `TextFormField`.
  const new({
    required this.controller,
    required this.label,
    this.validator,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.done,
    this.autofillHint = AutofillHints.newPassword,
    super.key,
  });

  /// Holds the typed text.
  final TextEditingController controller;

  /// The label above the field.
  final String label;

  /// Checks the text on submit; returns the message to show or `null`.
  final FormFieldValidator<String>? validator;

  /// Called when the keyboard's action key is pressed.
  final ValueChanged<String>? onFieldSubmitted;

  /// The keyboard's action key.
  final TextInputAction textInputAction;

  /// What a password manager should fill in: the saved password when signing in, a new one when signing up.
  final String autofillHint;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tooltip = _visible ? l10n.passwordHide : l10n.passwordShow;

    return LabeledField(
      label: widget.label,
      child: TextFormField(
        controller: widget.controller,
        obscureText: !_visible,
        enableSuggestions: false,
        autocorrect: false,
        textDirection: TextDirection.ltr,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: widget.textInputAction,
        autofillHints: [widget.autofillHint],
        validator: widget.validator,
        onFieldSubmitted: widget.onFieldSubmitted,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: Icon(_visible ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            tooltip: tooltip,
            onPressed: () => setState(() => _visible = !_visible),
          ),
        ),
      ),
    );
  }
}
