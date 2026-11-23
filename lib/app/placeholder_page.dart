import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The start page, a placeholder until the map and the restaurant screens exist: the name and the way to the settings.
class PlaceholderPage extends StatelessWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, semanticLabel: l10n.settingsOpenTooltip),
            tooltip: l10n.settingsOpenTooltip,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: PageFrame(
          child: Center(child: Text(l10n.appTitle, style: context.wasliText.display)),
        ),
      ),
    );
  }
}
