import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A message under a form that says why the server refused it: an error icon and the text, so the state is not told by
/// colour alone. Screen readers announce it as soon as it appears.
class FormError extends StatelessWidget {
  /// Creates the message.
  const new({required this.message, super.key});

  /// The text, already in the customer's language.
  final String message;

  @override
  Widget build(BuildContext context) {
    final color = context.wasli.error;

    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: color, size: WasliSpacing.space5),
          const SizedBox(width: WasliSpacing.space2),
          Expanded(
            child: Text(message, style: context.wasliText.bodySmall.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
