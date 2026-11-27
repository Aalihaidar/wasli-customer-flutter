import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/config/app_environment_provider.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/core/session/session_state.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/features/start/application/start_location_controller.dart';
import 'package:wasli_customer/features/start/application/start_location_state.dart';
import 'package:wasli_customer/features/start/presentation/location_views.dart';
import 'package:wasli_customer/features/start/presentation/nearby_list.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The start page: the restaurants around the customer.
///
/// It first explains why it needs the location and asks only when the customer presses the button (or finds the position
/// at once when the customer already allowed it). The settings and sign-in pages and the server status line belong to
/// other features, so the router hands them in.
class StartPage extends ConsumerWidget {
  /// Creates the page. [onOpenSettings] and [onSignIn] open those pages; [serverStatus] is the line that shows whether
  /// the server answered, shown outside production only.
  const new({required this.onOpenSettings, required this.onSignIn, this.serverStatus, super.key});

  /// Opens the settings page.
  final VoidCallback onOpenSettings;

  /// Opens the sign-in page.
  final VoidCallback onSignIn;

  /// A diagnostic line for test builds, or `null`.
  final Widget? serverStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isProduction = ref.watch(appEnvironmentProvider.select((environment) => environment.isProduction));
    final status = serverStatus;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (ref.watch(sessionProvider) is SignedOut)
            IconButton(
              icon: Icon(Icons.account_circle_outlined, semanticLabel: l10n.signInSubmit),
              tooltip: l10n.signInSubmit,
              onPressed: onSignIn,
            ),
          IconButton(
            icon: Icon(Icons.settings_outlined, semanticLabel: l10n.settingsOpenTooltip),
            tooltip: l10n.settingsOpenTooltip,
            onPressed: onOpenSettings,
          ),
        ],
      ),
      body: SafeArea(
        child: PageFrame(
          child: ListView(
            padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space4),
            children: [
              switch (ref.watch(startLocationProvider)) {
                LocationChecking() || LocationLocating() => const LocationFinding(),
                LocationNeeded() => const LocationExplanation(),
                final LocationFound found => NearbyList(found: found),
                final problem => LocationProblemView(state: problem),
              },
              if (!isProduction && status != null) ...[
                const SizedBox(height: WasliSpacing.space5),
                Center(child: status),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
