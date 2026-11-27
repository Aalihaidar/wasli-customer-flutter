import 'package:wasli_customer/features/start/domain/coordinates.dart';
import 'package:wasli_customer/features/start/domain/nearby_restaurants.dart';

/// Where the list of restaurants around a point comes from.
abstract interface class NearbyRepository {
  /// The restaurants that serve [point], nearest first. Needs no account. Throws a `Failure` when the server cannot be
  /// reached or does not answer as expected.
  Future<NearbyRestaurants> nearby(Coordinates point);
}
