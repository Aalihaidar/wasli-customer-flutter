import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/config/app_environment_provider.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/features/server_config/presentation/server_status_line.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The start page, a placeholder until the map and the restaurant screens exist: the name, the way to the settings and,
/// outside production, one line that shows whether the server answered.
class PlaceholderPage extends ConsumerWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final showServerStatus = !ref.watch(appEnvironmentProvider.select((environment) => environment.isProduction));

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
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.appTitle, style: context.wasliText.display),
                if (showServerStatus) ...[const SizedBox(height: WasliSpacing.space5), const ServerStatusLine()],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
