import 'package:wasli_customer/features/start/domain/restaurant_profile.dart';
import 'package:wasli_customer/features/start/domain/restaurant_profile_repository.dart';

/// An invented restaurant shaped like the `restaurants_retrieve_200` fixture.
const demoCafeProfile = RestaurantProfile(
  slug: 'demo-cafe',
  nameEn: 'Demo Cafe',
  nameAr: 'مقهى تجريبي',
  logoUrl: null,
  position: (latitude: 25.2048, longitude: 55.2708),
);

/// A [RestaurantProfileRepository] for tests: [onRead] decides what each call does, and [slugs] records what was asked.
class FakeRestaurantProfileRepository implements RestaurantProfileRepository {
  /// Creates a repository whose calls run [onRead].
  new(this.onRead);

  /// A repository that always answers with [profile].
  factory value([RestaurantProfile profile = demoCafeProfile]) => FakeRestaurantProfileRepository((_) async => profile);

  /// A repository that always fails with [error].
  factory failing(Exception error) => FakeRestaurantProfileRepository((_) async => throw error);

  /// What a call does.
  Future<RestaurantProfile> Function(String slug) onRead;

  /// The slugs that were asked about, in order.
  final List<String> slugs = [];

  @override
  Future<RestaurantProfile> bySlug(String slug) {
    slugs.add(slug);
    return onRead(slug);
  }
}
