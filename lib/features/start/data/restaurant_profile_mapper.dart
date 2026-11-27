import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/features/start/domain/restaurant_profile.dart';

/// Turns the generated `RestaurantDetail` into the app's [RestaurantProfile]. The menu, the position and the other
/// fields are left for the blocks that need them.
RestaurantProfile restaurantProfileFromDto(RestaurantDetail$Response dto) {
  return RestaurantProfile(slug: dto.slug, nameEn: dto.nameEn, nameAr: dto.nameAr, logoUrl: dto.logoUrl);
}
