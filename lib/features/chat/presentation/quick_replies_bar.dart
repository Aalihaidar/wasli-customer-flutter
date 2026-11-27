import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/features/chat/domain/quick_reply.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The buttons under the latest message of the server. A tap sends the button as it is.
class QuickRepliesBar extends StatelessWidget {
  /// Creates the bar. [onTap] receives the tapped reply; [enabled] is `false` while a message is being sent.
  const new({required this.replies, required this.onTap, this.enabled = true, super.key});

  /// The buttons, in the server's order.
  final List<QuickReply> replies;

  /// Called with the tapped button.
  final ValueChanged<QuickReply> onTap;

  /// Whether the buttons can be pressed.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: WasliSpacing.space2,
      runSpacing: WasliSpacing.space2,
      children: [
        for (final reply in replies)
          OutlinedButton(onPressed: enabled ? () => onTap(reply) : null, child: Text(reply.label)),
      ],
    );
  }
}
