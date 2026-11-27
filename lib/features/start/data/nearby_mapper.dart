import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/features/start/domain/nearby_restaurant.dart';
import 'package:wasli_customer/features/start/domain/nearby_restaurants.dart';

/// Turns the generated `NearbyResponse` into the app's [NearbyRestaurants].
NearbyRestaurants nearbyRestaurantsFromDto(NearbyResponse$Response dto) {
  return NearbyRestaurants(
    restaurants: [
      for (final entry in dto.restaurants)
        _restaurant(
          slug: entry.slug,
          nameEn: entry.nameEn,
          nameAr: entry.nameAr,
          logoUrl: entry.logoUrl,
          latitude: entry.latitude,
          longitude: entry.longitude,
          serviceRadiusM: entry.serviceRadiusM,
          distanceM: entry.distanceM,
          isOpen: entry.isOpen,
        ),
    ],
    nearest: switch (dto.nearest) {
      final nearest? => _restaurant(
        slug: nearest.slug,
        nameEn: nearest.nameEn,
        nameAr: nearest.nameAr,
        logoUrl: nearest.logoUrl,
        latitude: nearest.latitude,
        longitude: nearest.longitude,
        serviceRadiusM: nearest.serviceRadiusM,
        distanceM: nearest.distanceM,
        isOpen: nearest.isOpen,
      ),
      null => null,
    },
  );
}

// An entry and `nearest` have the same fields but are two generated classes, so both go through here.
NearbyRestaurant _restaurant({
  required String slug,
  required String nameEn,
  required String nameAr,
  required String? logoUrl,
  required num latitude,
  required num longitude,
  required int? serviceRadiusM,
  required int distanceM,
  required bool isOpen,
}) {
  return NearbyRestaurant(
    slug: slug,
    nameEn: nameEn,
    nameAr: nameAr,
    logoUrl: logoUrl,
    position: (latitude: latitude.toDouble(), longitude: longitude.toDouble()),
    serviceRadiusMetres: serviceRadiusM,
    distanceMetres: distanceM,
    isOpen: isOpen,
  );
}
