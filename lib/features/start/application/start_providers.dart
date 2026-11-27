import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;
import 'package:wasli_customer/core/network/network_providers.dart';
import 'package:wasli_customer/features/start/data/nearby_repository_impl.dart';
import 'package:wasli_customer/features/start/data/restaurant_profile_repository_impl.dart';
import 'package:wasli_customer/features/start/domain/coordinates.dart';
import 'package:wasli_customer/features/start/domain/nearby_repository.dart';
import 'package:wasli_customer/features/start/domain/nearby_restaurants.dart';
import 'package:wasli_customer/features/start/domain/restaurant_profile.dart';
import 'package:wasli_customer/features/start/domain/restaurant_profile_repository.dart';

/// The repository that lists the restaurants around a point. Tests replace it with a fake.
final nearbyRepositoryProvider = Provider<NearbyRepository>(
  (ref) => NearbyRepositoryImpl.fromDio(ref.watch(dioProvider)),
);

/// The restaurants that serve a point, read when a screen first asks for them and dropped when none shows them.
///
/// A failed read is not retried by Riverpod (the network layer retries a failed `GET`, and the screen offers "Try
/// again"). `ref.invalidate(nearbyRestaurantsProvider)` reads them again.
final FutureProviderFamily<NearbyRestaurants, Coordinates> nearbyRestaurantsProvider = FutureProvider.autoDispose
    .family<NearbyRestaurants, Coordinates>(
      (ref, point) => ref.watch(nearbyRepositoryProvider).nearby(point),
      retry: (retryCount, error) => null,
    );

/// The repository that reads a restaurant's public page. Tests replace it with a fake.
final restaurantProfileRepositoryProvider = Provider<RestaurantProfileRepository>(
  (ref) => RestaurantProfileRepositoryImpl.fromDio(ref.watch(dioProvider)),
);

/// The restaurant with this slug, read when its page first asks and dropped when the page closes. A failed read is not
/// retried by Riverpod; the page offers "Try again" and `ref.invalidate` reads it again.
final FutureProviderFamily<RestaurantProfile, String> restaurantProfileProvider = FutureProvider.autoDispose
    .family<RestaurantProfile, String>(
      (ref, slug) => ref.watch(restaurantProfileRepositoryProvider).bySlug(slug),
      retry: (retryCount, error) => null,
    );
