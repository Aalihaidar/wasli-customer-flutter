import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/config/app_environment_provider.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/failure_text.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/start/application/start_location_controller.dart';
import 'package:wasli_customer/features/start/application/start_location_state.dart';
import 'package:wasli_customer/features/start/application/start_providers.dart';
import 'package:wasli_customer/features/start/domain/position_source.dart';
import 'package:wasli_customer/features/start/presentation/nearby_empty_view.dart';
import 'package:wasli_customer/features/start/presentation/restaurant_card.dart';
import 'package:wasli_customer/features/start/presentation/restaurant_placeholders.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The restaurants around the position in [found], nearest first, with a button that reads the position and the list
/// again. Loading shows placeholder rows; a failure says why and offers "Try again".
class NearbyList extends ConsumerWidget {
  /// Creates the list for the position in [found].
  const new({required this.found, super.key});

  /// The known position.
  final LocationFound found;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isProduction = ref.watch(appEnvironmentProvider.select((environment) => environment.isProduction));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(header: true, child: Text(l10n.startListTitle, style: context.wasliText.heading2)),
            ),
            IconButton(
              icon: Icon(Icons.refresh, semanticLabel: l10n.startRefreshTooltip),
              tooltip: l10n.startRefreshTooltip,
              onPressed: () async {
                await ref.read(startLocationProvider.notifier).refresh();
                ref.invalidate(nearbyRestaurantsProvider);
              },
            ),
          ],
        ),
        if (!isProduction && found.source == PositionSource.simulated) ...[
          Row(
            children: [
              Expanded(child: Text(l10n.startSimulatedNotice, style: context.wasliText.bodySmall)),
              TextButton(
                onPressed: ref.read(startLocationProvider.notifier).retry,
                child: Text(l10n.startUseRealLocation),
              ),
            ],
          ),
        ],
        const SizedBox(height: WasliSpacing.space2),
        ref
            .watch(nearbyRestaurantsProvider(found.coordinates))
            .when(
              loading: RestaurantPlaceholders.new,
              error: (error, _) => _LoadFailed(
                message: error is Failure ? failureText(l10n, error) : l10n.failureGeneric,
                onRetry: () => ref.invalidate(nearbyRestaurantsProvider),
              ),
              data: (result) => result.restaurants.isEmpty
                  ? NearbyEmptyView(nearest: result.nearest)
                  : Column(
                      children: [
                        for (final restaurant in result.restaurants)
                          RestaurantCard(key: ValueKey(restaurant.slug), restaurant: restaurant),
                      ],
                    ),
            ),
      ],
    );
  }
}

class _LoadFailed extends StatelessWidget {
  const new({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          liveRegion: true,
          child: Text(message, textAlign: TextAlign.center, style: context.wasliText.body),
        ),
        TextButton(onPressed: onRetry, child: Text(context.l10n.startTryAgain)),
      ],
    );
  }
}
