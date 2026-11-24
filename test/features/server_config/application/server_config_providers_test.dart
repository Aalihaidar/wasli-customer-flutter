import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/features/server_config/application/server_config_providers.dart';

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
}
