import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/features/server_config/application/server_config_providers.dart';
import 'package:wasli_customer/features/server_config/domain/server_config.dart';

import '../../../support/fake_server_config_repository.dart';

void main() {
  group('serverConfigProvider', () {
    test('reads the settings once and keeps them', () async {
      final repository = FakeServerConfigRepository.value();
      final container = ProviderContainer(overrides: [serverConfigRepositoryProvider.overrideWithValue(repository)]);
      addTearDown(container.dispose);

      final first = await container.read(serverConfigProvider.future);
      final second = await container.read(serverConfigProvider.future);

      expect(first, same(second));
      expect(repository.loads, 1);
    });

    test('reads them again after an invalidate, for example after a failure', () async {
      final repository = FakeServerConfigRepository.failing(const NetworkFailure(NetworkFailureKind.offline));
      final container = ProviderContainer(overrides: [serverConfigRepositoryProvider.overrideWithValue(repository)]);
      addTearDown(container.dispose);

      await expectLater(container.read(serverConfigProvider.future), throwsA(isA<NetworkFailure>()));
      repository.onLoad = () async => defaultServerConfig;
      container.invalidate(serverConfigProvider);

      expect(await container.read(serverConfigProvider.future), defaultServerConfig);
      expect(repository.loads, 2);
    });
  });

  group('pollIntervalProvider', () {
    test('is the default while the settings are loading', () {
      final repository = FakeServerConfigRepository(() => Completer<ServerConfig>().future);
      final container = ProviderContainer(overrides: [serverConfigRepositoryProvider.overrideWithValue(repository)]);
      addTearDown(container.dispose);

      expect(container.read(pollIntervalProvider), defaultPollInterval);
    });

    test('is the default when the settings could not be read', () async {
      final repository = FakeServerConfigRepository.failing(const NetworkFailure(NetworkFailureKind.offline));
      final container = ProviderContainer(overrides: [serverConfigRepositoryProvider.overrideWithValue(repository)]);
      addTearDown(container.dispose);
      await expectLater(container.read(serverConfigProvider.future), throwsA(isA<NetworkFailure>()));

      expect(container.read(pollIntervalProvider), defaultPollInterval);
    });

    test('follows the server once it has answered', () async {
      final repository = FakeServerConfigRepository(
        () async => const ServerConfig(
          locationCheck: LocationCheck.warn,
          requireScreenOnline: true,
          aiEnabled: true,
          languages: ['en', 'ar'],
          pollInterval: Duration(seconds: 7),
        ),
      );
      final container = ProviderContainer(overrides: [serverConfigRepositoryProvider.overrideWithValue(repository)]);
      addTearDown(container.dispose);
      await container.read(serverConfigProvider.future);

      expect(container.read(pollIntervalProvider), const Duration(seconds: 7));
    });
  });
}
