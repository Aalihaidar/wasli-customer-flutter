import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A form field with its label above it, never inside it as a placeholder (design page, "Inputs").
///
/// The label is also the field's name for screen readers, so the visible text is hidden from them to avoid hearing it
/// twice.
class LabeledField extends StatelessWidget {
  /// Creates a labelled field around [child], usually a `TextFormField`.
  const new({required this.label, required this.child, super.key});

  /// The text above the field.
  final String label;

  /// The field.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Text(label, style: context.wasliText.label)),
        const SizedBox(height: WasliSpacing.space1),
        Semantics(label: label, child: child),
      ],
    );
  }
}
