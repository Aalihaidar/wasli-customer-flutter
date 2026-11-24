import 'package:wasli_customer/features/server_config/domain/server_config.dart';
import 'package:wasli_customer/features/server_config/domain/server_config_repository.dart';

/// The settings most tests use: the values the staging server answers with (invented but shaped like `GET /config`).
const defaultServerConfig = ServerConfig(
  locationCheck: LocationCheck.warn,
  requireScreenOnline: true,
  aiEnabled: true,
  languages: ['en', 'ar'],
  pollInterval: Duration(seconds: 3),
);

/// A [ServerConfigRepository] for tests: [onLoad] decides what each call does, and [loads] counts the calls.
class FakeServerConfigRepository implements ServerConfigRepository {
  /// Creates a repository whose calls run [onLoad].
  new(this.onLoad);

  /// A repository that always answers with [config].
  factory value([ServerConfig config = defaultServerConfig]) => FakeServerConfigRepository(() async => config);

  /// A repository that always fails with [error].
  factory failing(Exception error) => FakeServerConfigRepository(() async => throw error);

  /// What a call does.
  Future<ServerConfig> Function() onLoad;

  /// How many times the settings were asked for.
  int loads = 0;

  @override
  Future<ServerConfig> load() {
    loads++;
    return onLoad();
  }
}
