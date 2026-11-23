import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The frame every page's content sits in: centred, no wider than the content column, with the page gutter on both
/// sides.
///
/// The column is [WasliLayout.contentMaxWidth] wide at most (560 for the customer app), so a phone fills the screen and a
/// wide window keeps a readable column in the middle. The gutter is 16 on a phone and 24 on a tablet and wider, and it
/// uses directional padding, so nothing changes for right-to-left languages.
class PageFrame extends StatelessWidget {
  /// Creates a frame around [child].
  const new({required this.child, this.maxWidth = WasliLayout.contentMaxWidth, super.key});

  /// The page content.
  final Widget child;

  /// The widest the content may grow, 560 by default.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final gutter = WindowSizeClass.of(context).pageGutter;

    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: gutter),
          child: child,
        ),
      ),
    );
  }
}
