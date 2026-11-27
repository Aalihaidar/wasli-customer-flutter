import 'package:wasli_customer/features/start/domain/coordinates.dart';
import 'package:wasli_customer/features/start/domain/nearby_repository.dart';
import 'package:wasli_customer/features/start/domain/nearby_restaurant.dart';
import 'package:wasli_customer/features/start/domain/nearby_restaurants.dart';

/// Two invented restaurants shaped like the `restaurants_nearby_200` fixture.
const demoCafe = NearbyRestaurant(
  slug: 'demo-cafe',
  nameEn: 'Demo Cafe',
  nameAr: 'مقهى تجريبي',
  logoUrl: null,
  position: (latitude: 25.2048, longitude: 55.2708),
  serviceRadiusMetres: 500,
  distanceMetres: 120,
  isOpen: true,
);

/// A second invented restaurant, closed, with no service limit.
const sampleGrill = NearbyRestaurant(
  slug: 'sample-grill',
  nameEn: 'Sample Grill',
  nameAr: 'مشويات تجريبية',
  logoUrl: null,
  position: (latitude: 25.2051, longitude: 55.2712),
  serviceRadiusMetres: null,
  distanceMetres: 340,
  isOpen: false,
);

/// A [NearbyRepository] for tests: [onNearby] decides what each call does, and [points] records what was asked.
class FakeNearbyRepository implements NearbyRepository {
  /// Creates a repository whose calls run [onNearby].
  new(this.onNearby);

  /// A repository that always lists [restaurants], and [nearest] when the list is empty.
  factory listing({List<NearbyRestaurant> restaurants = const [demoCafe, sampleGrill], NearbyRestaurant? nearest}) =>
      FakeNearbyRepository((_) async => NearbyRestaurants(restaurants: restaurants, nearest: nearest));

  /// A repository that always fails with [error].
  factory failing(Exception error) => FakeNearbyRepository((_) async => throw error);

  /// What a call does.
  Future<NearbyRestaurants> Function(Coordinates point) onNearby;

  /// The points that were asked about, in order.
  final List<Coordinates> points = [];

  @override
  Future<NearbyRestaurants> nearby(Coordinates point) {
    points.add(point);
    return onNearby(point);
  }
}
