import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/config/app_environment_provider.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/chat/application/chat_controller.dart';
import 'package:wasli_customer/features/chat/application/chat_state.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The question at the car step: may the restaurant have the customer's position to find the car? It explains why first,
/// and the system prompt shows only when the customer presses "Share my location". A test build also offers to pretend
/// to be at the restaurant ([restaurantPosition]).
class LocationPrompt extends ConsumerWidget {
  /// Creates the prompt for the restaurant [slug]. [restaurantPosition] is its latitude and longitude, used only by the
  /// test build's simulate button.
  const new({required this.slug, required this.sharing, required this.restaurantPosition, super.key});

  /// The restaurant's address name.
  final String slug;

  /// Where sharing stands; the prompt shows only for [LocationSharing.notAsked] and [LocationSharing.sharing].
  final LocationSharing sharing;

  /// The restaurant's position.
  final ({double latitude, double longitude}) restaurantPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(chatControllerProvider(slug).notifier);
    final isTestBuild = !ref.watch(appEnvironmentProvider.select((environment) => environment.isProduction));

    if (sharing == LocationSharing.sharing) {
      return Semantics(liveRegion: true, child: Text(l10n.chatLocationSharing, style: context.wasliText.bodySmall));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(WasliSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(header: true, child: Text(l10n.chatLocationTitle, style: context.wasliText.heading3)),
            const SizedBox(height: WasliSpacing.space1),
            Text(l10n.chatLocationBody, style: context.wasliText.bodySmall),
            const SizedBox(height: WasliSpacing.space3),
            FilledButton(onPressed: controller.shareMyLocation, child: Text(l10n.chatLocationShare)),
            const SizedBox(height: WasliSpacing.space2),
            TextButton(onPressed: controller.skipLocation, child: Text(l10n.chatLocationNotNow)),
            if (isTestBuild)
              OutlinedButton(
                onPressed: () => controller.shareSimulatedLocation(
                  latitude: restaurantPosition.latitude,
                  longitude: restaurantPosition.longitude,
                ),
                child: Text(l10n.startSimulateAtRestaurant),
              ),
          ],
        ),
      ),
    );
  }
}
