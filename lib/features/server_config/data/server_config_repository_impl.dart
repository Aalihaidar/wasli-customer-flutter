import 'package:dio/dio.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/network/network_timeouts.dart';
import 'package:wasli_customer/core/network/run_api.dart';
import 'package:wasli_customer/features/server_config/data/server_config_mapper.dart';
import 'package:wasli_customer/features/server_config/domain/server_config.dart';
import 'package:wasli_customer/features/server_config/domain/server_config_repository.dart';

/// Reads the server's settings through the generated `ConfigClient`.
///
/// The call is public (no token) and is the first of a visit, so it waits up to [NetworkTimeouts.coldStart] for a
/// server that is waking up.
class ServerConfigRepositoryImpl implements ServerConfigRepository {
  /// Creates the repository over the generated client.
  const new(this._client);

  /// Creates the repository over the app's HTTP client, building the generated client here, because only `data/`
  /// imports `lib/api`.
  factory fromDio(Dio dio) => ServerConfigRepositoryImpl(ConfigClient(dio));

  final ConfigClient _client;

  @override
  Future<ServerConfig> load() async {
    final dto = await runApi(() => _client.configRetrieve(options: Options(receiveTimeout: NetworkTimeouts.coldStart)));
    return serverConfigFromDto(dto);
  }
}
