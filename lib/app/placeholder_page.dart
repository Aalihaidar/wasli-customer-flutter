import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/language_switch.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The first page of the app, shown until the router and the screens exist: the name and the language switch.
class PlaceholderPage extends StatelessWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: WasliLayout.contentMaxWidth),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(WasliSpacing.space4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.appTitle, style: context.wasliText.display),
                  const SizedBox(height: WasliSpacing.space5),
                  const LanguageSwitch(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
