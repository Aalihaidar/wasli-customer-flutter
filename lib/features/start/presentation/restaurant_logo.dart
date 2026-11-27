import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

/// A restaurant's logo at 48 by 48, or a plain restaurant icon when it has none or the image does not load.
///
/// Decorative: the name next to it is what a screen reader reads.
class RestaurantLogo extends StatelessWidget {
  /// Creates the logo of the image at [url] (`null` when the restaurant has none).
  const new({required this.url, super.key});

  /// The absolute address of the logo.
  final String? url;

  @override
  Widget build(BuildContext context) {
    final colors = context.wasli;
    final fallback = ColoredBox(
      color: colors.background,
      child: Icon(Icons.restaurant_outlined, color: colors.textMuted),
    );
    final address = url;

    return ExcludeSemantics(
      child: ClipRRect(
        borderRadius: WasliRadius.smAll,
        child: SizedBox.square(
          dimension: WasliSpacing.space7,
          child: address == null
              ? fallback
              : Image.network(address, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => fallback),
        ),
      ),
    );
  }
}
