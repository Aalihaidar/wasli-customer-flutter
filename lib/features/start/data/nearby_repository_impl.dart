import 'package:dio/dio.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/network/network_timeouts.dart';
import 'package:wasli_customer/core/network/run_api.dart';
import 'package:wasli_customer/features/start/data/nearby_mapper.dart';
import 'package:wasli_customer/features/start/domain/coordinates.dart';
import 'package:wasli_customer/features/start/domain/nearby_repository.dart';
import 'package:wasli_customer/features/start/domain/nearby_restaurants.dart';

/// Reads the restaurants around a point through the generated `RestaurantsClient`.
///
/// The call is public (no token). The point travels in the query string, which the network layer's log never records.
/// It is often the first call a customer waits for, so it allows a sleeping staging server [NetworkTimeouts.coldStart].
class NearbyRepositoryImpl implements NearbyRepository {
  /// Creates the repository over the generated client.
  const new(this._client);

  /// Creates the repository over the app's HTTP client, building the generated client here, because only `data/`
  /// imports `lib/api`.
  factory fromDio(Dio dio) => NearbyRepositoryImpl(RestaurantsClient(dio));

  final RestaurantsClient _client;

  @override
  Future<NearbyRestaurants> nearby(Coordinates point) async {
    final dto = await runApi(
      () => _client.restaurantsNearby(
        lat: point.latitude,
        lng: point.longitude,
        options: Options(receiveTimeout: NetworkTimeouts.coldStart),
      ),
    );
    return nearbyRestaurantsFromDto(dto);
  }
}
