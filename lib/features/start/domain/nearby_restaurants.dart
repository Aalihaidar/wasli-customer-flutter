import 'package:wasli_customer/features/start/domain/nearby_restaurant.dart';

/// The answer to "which restaurants serve this point".
class NearbyRestaurants {
  /// Creates the answer.
  const new({required this.restaurants, this.nearest});

  /// The restaurants that serve the point, nearest first. Empty when none does.
  final List<NearbyRestaurant> restaurants;

  /// The closest restaurant when [restaurants] is empty and at least one restaurant exists; otherwise `null`.
  final NearbyRestaurant? nearest;
}
