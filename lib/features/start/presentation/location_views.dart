import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/platform/location/location_providers.dart';
import 'package:wasli_customer/features/start/application/start_location_controller.dart';
import 'package:wasli_customer/features/start/application/start_location_state.dart';
import 'package:wasli_customer/features/start/presentation/location_notice.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The explanation shown before the app asks for the customer's location. The button shows the system prompt.
class LocationExplanation extends ConsumerWidget {
  /// Creates the explanation.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return LocationNotice(
      title: l10n.startLocationTitle,
      body: l10n.startLocationBody,
      actions: [
        FilledButton(onPressed: ref.read(startLocationProvider.notifier).allow, child: Text(l10n.startLocationAllow)),
      ],
    );
  }
}

/// Why there is no position: refused (and whether asking again is possible), location off, or no fix. Each has the way
/// forward as a button.
class LocationProblemView extends ConsumerWidget {
  /// Creates the view for a problem [state]: [LocationDenied], [LocationOff] or [LocationFailed].
  const new({required this.state, super.key});

  /// The state to describe.
  final StartLocationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(startLocationProvider.notifier);
    final tryAgain = FilledButton(onPressed: controller.retry, child: Text(l10n.startTryAgain));

    return switch (state) {
      LocationDenied(blocked: false) => LocationNotice(
        title: l10n.startProblemDeniedTitle,
        body: l10n.startProblemDeniedBody,
        actions: [FilledButton(onPressed: controller.allow, child: Text(l10n.startLocationAllow))],
      ),
      LocationDenied(blocked: true) => LocationNotice(
        title: l10n.startProblemDeniedTitle,
        body: l10n.startProblemBlockedBody,
        actions: [
          if (ref.read(locationServiceProvider).canOpenSettings) ...[
            FilledButton(onPressed: controller.openSettings, child: Text(l10n.startOpenSettings)),
            TextButton(onPressed: controller.retry, child: Text(l10n.startTryAgain)),
          ] else
            tryAgain,
        ],
      ),
      LocationOff() => LocationNotice(
        title: l10n.startProblemOffTitle,
        body: l10n.startProblemOffBody,
        actions: [tryAgain],
      ),
      _ => LocationNotice(title: l10n.startProblemFailedTitle, body: l10n.startProblemFailedBody, actions: [tryAgain]),
    };
  }
}

/// "Finding your location…" with a spinner, while the app reads the position or what the customer decided.
class LocationFinding extends StatelessWidget {
  /// Creates the message.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space6),
      child: Semantics(
        liveRegion: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox.square(dimension: WasliSpacing.space5, child: CircularProgressIndicator(strokeWidth: 3)),
            const SizedBox(width: WasliSpacing.space3),
            Flexible(child: Text(context.l10n.startLocationFinding, style: context.wasliText.body)),
          ],
        ),
      ),
    );
  }
}
