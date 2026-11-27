import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A message bubble: the server's on the start side (surface, with a thin border) and the customer's on the end side
/// (primary), with the corner on the sender's side squared off, as the design describes.
class ChatBubble extends StatelessWidget {
  /// Creates a bubble around [child]. [fromCustomer] puts it on the end side.
  const new({required this.child, required this.fromCustomer, super.key});

  /// The content.
  final Widget child;

  /// Whether the customer wrote it.
  final bool fromCustomer;

  @override
  Widget build(BuildContext context) {
    final colors = context.wasli;
    const round = Radius.circular(WasliRadius.lg);
    const square = Radius.circular(WasliSpacing.space1);
    final radius = fromCustomer
        ? const BorderRadiusDirectional.only(topStart: round, topEnd: round, bottomStart: round, bottomEnd: square)
        : const BorderRadiusDirectional.only(topStart: round, topEnd: round, bottomStart: square, bottomEnd: round);

    return Align(
      alignment: fromCustomer ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.widthOf(context) * 0.85),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fromCustomer ? colors.primary : colors.surface,
            borderRadius: radius,
            border: fromCustomer ? null : Border.all(color: colors.borderSubtle),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: WasliSpacing.space3,
              vertical: WasliSpacing.space2,
            ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: fromCustomer ? colors.onPrimary : colors.text),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
