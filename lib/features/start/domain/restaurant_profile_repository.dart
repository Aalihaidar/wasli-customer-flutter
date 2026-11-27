import 'package:wasli_customer/features/start/domain/restaurant_profile.dart';

/// Where the public page of a restaurant comes from.
abstract interface class RestaurantProfileRepository {
  /// Reads the restaurant named [slug] (already checked by `isValidRestaurantSlug`). Needs no account. Throws a
  /// `NotFoundFailure` when it does not exist or is not active, and another `Failure` when the server cannot be reached
  /// or does not answer as expected.
  Future<RestaurantProfile> bySlug(String slug);
}
