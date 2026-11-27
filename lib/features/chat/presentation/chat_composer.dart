import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/chat/application/chat_controller.dart';
import 'package:wasli_customer/theme/theme.dart';

/// Keeps the text to [maxChatTextLength] code points (what the server counts), cutting a longer paste.
class CodePointLimitFormatter extends TextInputFormatter {
  /// Creates the formatter.
  const new();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final runes = newValue.text.runes;
    if (runes.length <= maxChatTextLength) {
      return newValue;
    }
    final cut = String.fromCharCodes(runes.take(maxChatTextLength));
    return TextEditingValue(
      text: cut,
      selection: TextSelection.collapsed(offset: cut.length),
    );
  }
}

/// The field where the customer types, and the button that sends. Sending is blocked while a message is on its way.
class ChatComposer extends StatefulWidget {
  /// Creates the composer. [onSend] receives the typed text (not trimmed: the controller trims it).
  const new({required this.onSend, this.enabled = true, super.key});

  /// Called with the text when the customer sends.
  final ValueChanged<String> onSend;

  /// Whether the customer can send.
  final bool enabled;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text;
    if (!widget.enabled || text.trim().isEmpty) {
      return;
    }
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: widget.enabled,
            minLines: 1,
            maxLines: 4,
            // Text, not multiline: the keyboard's action button sends, and a line may still wrap.
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.send,
            inputFormatters: const [CodePointLimitFormatter()],
            decoration: InputDecoration(hintText: l10n.chatComposerHint),
            onSubmitted: (_) => _send(),
          ),
        ),
        const SizedBox(width: WasliSpacing.space2),
        IconButton.filled(
          icon: const Icon(Icons.send),
          tooltip: l10n.chatSend,
          onPressed: widget.enabled ? _send : null,
        ),
      ],
    );
  }
}
