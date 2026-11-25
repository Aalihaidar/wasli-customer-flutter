import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/network/network_providers.dart';
import 'package:wasli_customer/features/server_config/data/server_config_repository_impl.dart';
import 'package:wasli_customer/features/server_config/domain/server_config.dart';
import 'package:wasli_customer/features/server_config/domain/server_config_repository.dart';

/// The repository that reads the server's settings. Tests replace it with a fake.
final serverConfigRepositoryProvider = Provider<ServerConfigRepository>(
  (ref) => ServerConfigRepositoryImpl.fromDio(ref.watch(dioProvider)),
);

/// The server's settings, read on first use and kept for the session. `ref.invalidate` reads them again.
///
/// A failed read is not retried by Riverpod (its default is ten tries with a growing pause, which would keep the screen
/// "loading" for minutes): the network layer already retries a failed `GET`, and the screen offers "Try again".
final serverConfigProvider = FutureProvider<ServerConfig>(
  (ref) => ref.watch(serverConfigRepositoryProvider).load(),
  retry: (retryCount, error) => null,
);

/// The pause between two polls of the chat and the order until the server has said otherwise (3 seconds, its value today).
const Duration defaultPollInterval = Duration(seconds: 3);

/// How often the chat and the order are polled: the server's `poll_interval_seconds` once it is known, and
/// [defaultPollInterval] while the settings are still loading or could not be read. A poller reads it fresh on each tick.
final pollIntervalProvider = Provider<Duration>(
  (ref) => ref.watch(serverConfigProvider.select((config) => config.value?.pollInterval)) ?? defaultPollInterval,
);
