import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/presentation/chat_bubble.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A picture the restaurant sends (a menu page) with its caption. A tap opens it full screen, where it can be zoomed.
class ImageBubble extends StatelessWidget {
  /// Creates the bubble for [message].
  const new({required this.message, super.key});

  /// The message to show.
  final ImageMessage message;

  @override
  Widget build(BuildContext context) {
    final url = message.imageUrl;
    final caption = message.text;

    return ChatBubble(
      fromCustomer: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (url != null)
            Semantics(
              button: true,
              label: caption,
              child: InkWell(
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => _Viewer(url: url, caption: caption),
                ),
                child: ClipRRect(
                  borderRadius: WasliRadius.smAll,
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.broken_image_outlined, color: context.wasli.textMuted),
                  ),
                ),
              ),
            ),
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(top: WasliSpacing.space1),
              child: Text(caption, style: context.wasliText.bodySmall),
            ),
        ],
      ),
    );
  }
}

class _Viewer extends StatelessWidget {
  const new({required this.url, required this.caption});

  final String url;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 5,
              child: Center(
                child: Image.network(
                  url,
                  semanticLabel: caption,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: WasliSpacing.space2,
            end: WasliSpacing.space2,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.close),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
