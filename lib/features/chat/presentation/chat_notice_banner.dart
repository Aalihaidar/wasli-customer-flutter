import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/chat/application/chat_state.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A one-time notice above the composer, with an icon and words (not colour alone) and a way to act or dismiss it.
class ChatNoticeBanner extends StatelessWidget {
  /// Creates the banner for [notice]. [onDismiss] removes it; [onConfirmPhone] opens the page that confirms a phone.
  const new({required this.notice, required this.onDismiss, required this.onConfirmPhone, super.key});

  /// What to tell the customer.
  final ChatNotice notice;

  /// Removes the notice.
  final VoidCallback onDismiss;

  /// Opens the page where the customer adds and confirms a phone number.
  final VoidCallback onConfirmPhone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.wasli;
    final (text, action) = switch (notice) {
      ChatNotice.phoneNotVerified => (
        l10n.chatNoticePhone,
        TextButton(onPressed: onConfirmPhone, child: Text(l10n.chatNoticePhoneAction)),
      ),
      ChatNotice.conversationRestarted => (l10n.chatNoticeRestarted, null),
    };

    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.statusWarnBackground, borderRadius: WasliRadius.mdAll),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(WasliSpacing.space3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: colors.statusWarnForeground),
              const SizedBox(width: WasliSpacing.space2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: context.wasliText.bodySmall.copyWith(color: colors.statusWarnForeground)),
                    ?action,
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: l10n.chatNoticeDismiss,
                color: colors.statusWarnForeground,
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
