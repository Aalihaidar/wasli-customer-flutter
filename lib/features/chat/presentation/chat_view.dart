import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/failure_text.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/chat/application/chat_controller.dart';
import 'package:wasli_customer/features/chat/application/chat_state.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/domain/chat_step.dart';
import 'package:wasli_customer/features/chat/domain/quick_reply.dart';
import 'package:wasli_customer/features/chat/presentation/chat_composer.dart';
import 'package:wasli_customer/features/chat/presentation/chat_notice_banner.dart';
import 'package:wasli_customer/features/chat/presentation/location_prompt.dart';
import 'package:wasli_customer/features/chat/presentation/message_list.dart';
import 'package:wasli_customer/features/chat/presentation/quick_replies_bar.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The chat with one restaurant: the conversation, the buttons of the latest message, the question about the position at
/// the car step, and the composer.
///
/// It tells the controller when the screen is visible so the server is asked for news only then. The phone page and the
/// other pages belong to other features, so the way to them is a callback.
class ChatView extends ConsumerStatefulWidget {
  /// Creates the chat for the restaurant [slug]. [restaurantPosition] is only for the test build's simulate button;
  /// [onConfirmPhone] opens the page that confirms a phone number.
  const new({required this.slug, required this.restaurantPosition, required this.onConfirmPhone, super.key});

  /// The restaurant's address name.
  final String slug;

  /// The restaurant's position.
  final ({double latitude, double longitude}) restaurantPosition;

  /// Opens the page where the customer adds and confirms a phone number.
  final VoidCallback onConfirmPhone;

  @override
  ConsumerState<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<ChatView> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // On the web the lifecycle follows the page's visibility.
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) => ref
          .read(chatControllerProvider(widget.slug).notifier)
          .setVisible(visible: state == AppLifecycleState.resumed),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ref
        .watch(chatControllerProvider(widget.slug))
        .when(
          loading: () => Center(
            child: Semantics(label: l10n.restaurantLoading, liveRegion: true, child: const CircularProgressIndicator()),
          ),
          error: (error, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(
                    error is Failure ? failureText(l10n, error) : l10n.failureGeneric,
                    textAlign: TextAlign.center,
                    style: context.wasliText.body,
                  ),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(chatControllerProvider(widget.slug)),
                  child: Text(l10n.startTryAgain),
                ),
              ],
            ),
          ),
          data: _content,
        );
  }

  Widget _content(ChatState state) {
    final l10n = context.l10n;
    final controller = ref.read(chatControllerProvider(widget.slug).notifier);
    final placed = state.conversation.step == ChatStep.placed;
    final inFlight = state.outgoing.any((message) => !message.failed);
    final askingLocation =
        state.conversation.step == ChatStep.askCar &&
        (state.locationSharing == LocationSharing.notAsked || state.locationSharing == LocationSharing.sharing);
    final replies = placed || state.outgoing.isNotEmpty ? const <QuickReply>[] : _latestReplies(state.messages);
    final notice = state.notice;

    return Column(
      children: [
        Expanded(
          child: MessageList(state: state, onRetry: controller.retry),
        ),
        // The panel under the conversation shares the room that is left with the conversation (2 to 3) and scrolls inside
        // its share, so a large text size on a small phone never pushes the conversation away or overflows.
        Flexible(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (notice != null) ...[
                  ChatNoticeBanner(
                    notice: notice,
                    onDismiss: controller.dismissNotice,
                    onConfirmPhone: widget.onConfirmPhone,
                  ),
                  const SizedBox(height: WasliSpacing.space2),
                ],
                if (askingLocation) ...[
                  LocationPrompt(
                    slug: widget.slug,
                    sharing: state.locationSharing,
                    restaurantPosition: widget.restaurantPosition,
                  ),
                  const SizedBox(height: WasliSpacing.space2),
                ],
                if (replies.isNotEmpty) ...[
                  QuickRepliesBar(replies: replies, onTap: controller.sendReply, enabled: !inFlight),
                  const SizedBox(height: WasliSpacing.space2),
                ],
              ],
            ),
          ),
        ),
        if (placed)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: WasliSpacing.space3),
            child: OutlinedButton(onPressed: controller.orderAgain, child: Text(l10n.chatOrderAgain)),
          )
        else
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: WasliSpacing.space3),
            child: ChatComposer(onSend: controller.sendText, enabled: !inFlight),
          ),
      ],
    );
  }

  // Only the latest message of the server has active buttons, and only while no newer message exists.
  List<QuickReply> _latestReplies(List<ChatMessage> messages) {
    final last = messages.lastOrNull;
    if (last == null || last.fromCustomer) {
      return const [];
    }
    return switch (last) {
      TextMessage(:final quickReplies) => quickReplies,
      OrderSummaryMessage(:final quickReplies) => quickReplies,
      ReviewMessage(:final quickReplies) => quickReplies,
      ImageMessage() || ResultMessage() => const [],
    };
  }
}
