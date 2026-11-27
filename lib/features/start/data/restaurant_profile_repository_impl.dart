import 'package:dio/dio.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/network/network_timeouts.dart';
import 'package:wasli_customer/core/network/run_api.dart';
import 'package:wasli_customer/features/start/data/restaurant_profile_mapper.dart';
import 'package:wasli_customer/features/start/domain/restaurant_profile.dart';
import 'package:wasli_customer/features/start/domain/restaurant_profile_repository.dart';

/// Reads a restaurant through the generated `RestaurantsClient`.
///
/// The call is public (no token). A customer who scanned a QR code makes it as the first call of the visit, so it allows
/// a sleeping staging server [NetworkTimeouts.coldStart].
class RestaurantProfileRepositoryImpl implements RestaurantProfileRepository {
  /// Creates the repository over the generated client.
  const new(this._client);

  /// Creates the repository over the app's HTTP client, building the generated client here, because only `data/`
  /// imports `lib/api`.
  factory fromDio(Dio dio) => RestaurantProfileRepositoryImpl(RestaurantsClient(dio));

  final RestaurantsClient _client;

  @override
  Future<RestaurantProfile> bySlug(String slug) async {
    final dto = await runApi(
      () => _client.restaurantsRetrieve(
        slug: slug,
        options: Options(receiveTimeout: NetworkTimeouts.coldStart),
      ),
    );
    return restaurantProfileFromDto(dto);
  }
}
