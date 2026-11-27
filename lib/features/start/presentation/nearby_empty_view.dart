import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/config/app_environment_provider.dart';
import 'package:wasli_customer/core/format/distance.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/start/application/start_location_controller.dart';
import 'package:wasli_customer/features/start/domain/nearby_restaurant.dart';
import 'package:wasli_customer/theme/theme.dart';

/// What the list shows when no restaurant serves the customer's position: the closest one and how far it is (with how far
/// from it cars are served, when it says so), or that none is known, always with the QR hint. A test build also offers
/// "Simulate: I'm at the restaurant", which looks again from the closest restaurant's own position.
class NearbyEmptyView extends ConsumerWidget {
  /// Creates the view; [nearest] is the closest restaurant, or `null` when the server knows none.
  const new({required this.nearest, super.key});

  /// The closest restaurant, or `null`.
  final NearbyRestaurant? nearest;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final closest = nearest;
    final canSimulate = !ref.watch(appEnvironmentProvider.select((environment) => environment.isProduction));
    final muted = context.wasliText.bodySmall.copyWith(color: context.wasli.textMuted);

    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(WasliSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              closest == null
                  ? l10n.startEmptyNone
                  : l10n.startEmptyNearest(
                      name: closest.nameFor(locale.languageCode),
                      distance: formatDistance(closest.distanceMetres, locale: locale),
                    ),
              style: context.wasliText.body,
            ),
            if (closest?.serviceRadiusMetres case final radius?) ...[
              const SizedBox(height: WasliSpacing.space2),
              Text(
                l10n.startEmptyNearestRadius(distance: formatDistance(radius, locale: locale)),
                style: context.wasliText.body,
              ),
            ],
            const SizedBox(height: WasliSpacing.space4),
            Text(l10n.startLocationQrHint, style: muted),
            if (closest != null && canSimulate) ...[
              const SizedBox(height: WasliSpacing.space4),
              OutlinedButton(
                onPressed: () => ref.read(startLocationProvider.notifier).simulateAt(closest.position),
                child: Text(l10n.startSimulateAtRestaurant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
