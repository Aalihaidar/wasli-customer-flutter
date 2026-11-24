import 'package:wasli_customer/features/server_config/domain/server_config.dart';

/// Where the server's settings come from.
abstract interface class ServerConfigRepository {
  /// Reads the settings. Throws a `Failure` when the server cannot be reached or does not answer as expected.
  Future<ServerConfig> load();
}
