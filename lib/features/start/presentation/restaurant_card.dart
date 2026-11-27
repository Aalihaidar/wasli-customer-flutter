import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/format/distance.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/start/domain/nearby_restaurant.dart';
import 'package:wasli_customer/features/start/presentation/open_status_pill.dart';
import 'package:wasli_customer/features/start/presentation/restaurant_logo.dart';
import 'package:wasli_customer/theme/theme.dart';

/// One restaurant in the list: its logo, its name, how far it is and whether it can take an order now.
class RestaurantCard extends StatelessWidget {
  /// Creates the card for [restaurant]; [onTap] opens its page.
  const new({required this.restaurant, required this.onTap, super.key});

  /// The restaurant to show.
  final NearbyRestaurant restaurant;

  /// Opens the restaurant's page.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.all(WasliSpacing.space4),
          child: Row(
            children: [
              RestaurantLogo(url: restaurant.logoUrl),
              const SizedBox(width: WasliSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.nameFor(locale.languageCode), style: context.wasliText.heading3),
                    Text(
                      l10n.startRestaurantDistance(distance: formatDistance(restaurant.distanceMetres, locale: locale)),
                      style: context.wasliText.bodySmall.copyWith(color: context.wasli.textMuted),
                    ),
                    const SizedBox(height: WasliSpacing.space2),
                    OpenStatusPill(isOpen: restaurant.isOpen),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
