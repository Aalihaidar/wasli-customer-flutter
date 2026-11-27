import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/format/money.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/chat/domain/order_summary.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The lines of an order and its total, as the server priced them. Nothing here is computed: every number is the server's.
class OrderSummaryView extends StatelessWidget {
  /// Creates the view of [summary].
  const new({required this.summary, super.key});

  /// The priced order.
  final OrderSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final muted = context.wasliText.bodySmall.copyWith(color: context.wasli.textMuted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final line in summary.lines)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: WasliSpacing.space2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chatSummaryLine(quantity: line.quantity.toString(), name: line.name),
                        style: context.wasliText.body,
                      ),
                      if (line.optionNames.isNotEmpty) Text(line.optionNames.join(', '), style: muted),
                      if (line.note case final note?) Text(note, style: muted),
                    ],
                  ),
                ),
                const SizedBox(width: WasliSpacing.space2),
                Text(
                  formatMoney(line.lineTotalMinor, currency: summary.currency, locale: locale),
                  style: context.wasliText.bodyStrong,
                ),
              ],
            ),
          ),
        Divider(color: context.wasli.borderSubtle),
        Row(
          children: [
            Expanded(child: Text(l10n.chatSummaryTotal, style: context.wasliText.heading3)),
            Text(
              formatMoney(summary.totalMinor, currency: summary.currency, locale: locale),
              style: context.wasliText.heading3,
            ),
          ],
        ),
      ],
    );
  }
}
