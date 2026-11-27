import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/chat/domain/chat_message.dart';
import 'package:wasli_customer/features/chat/presentation/chat_bubble.dart';
import 'package:wasli_customer/features/chat/presentation/order_summary_view.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The order the server repeated back: its text and the priced lines.
class SummaryCard extends StatelessWidget {
  /// Creates the card for [message].
  const new({required this.message, super.key});

  /// The message to show.
  final OrderSummaryMessage message;

  @override
  Widget build(BuildContext context) {
    final summary = message.summary;

    return ChatBubble(
      fromCustomer: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (message.text.isNotEmpty) Text(message.text, style: context.wasliText.body),
          if (summary != null) ...[const SizedBox(height: WasliSpacing.space2), OrderSummaryView(summary: summary)],
        ],
      ),
    );
  }
}

/// The whole order before the final confirmation: the priced lines, the parking place, the car, the note and whether the
/// position was shared.
class ReviewCard extends StatelessWidget {
  /// Creates the card for [message].
  const new({required this.message, super.key});

  /// The message to show.
  final ReviewMessage message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = message.summary;

    return ChatBubble(
      fromCustomer: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (message.text.isNotEmpty) Text(message.text, style: context.wasliText.body),
          if (summary != null) ...[const SizedBox(height: WasliSpacing.space2), OrderSummaryView(summary: summary)],
          const SizedBox(height: WasliSpacing.space3),
          if (message.parkingNote.isNotEmpty) _Field(label: l10n.chatReviewParking, value: message.parkingNote),
          if (message.vehiclePlate.isNotEmpty)
            _Field(label: l10n.chatReviewPlate, value: isolateLeftToRight(message.vehiclePlate)),
          if (message.vehicleModel.isNotEmpty) _Field(label: l10n.chatReviewModel, value: message.vehicleModel),
          if (message.vehicleColour.isNotEmpty) _Field(label: l10n.chatReviewColour, value: message.vehicleColour),
          if (message.orderNote.isNotEmpty) _Field(label: l10n.chatReviewNote, value: message.orderNote),
          _Field(
            label: l10n.chatReviewLocation,
            value: message.locationShared ? l10n.chatReviewLocationShared : l10n.chatReviewLocationNotShared,
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const new({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: WasliSpacing.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: context.wasliText.caption.copyWith(color: context.wasli.textMuted)),
          Text(value, style: context.wasliText.body),
        ],
      ),
    );
  }
}
