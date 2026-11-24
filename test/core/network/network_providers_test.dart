import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/config/app_environment_provider.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/logging/app_logger.dart';
import 'package:wasli_customer/core/network/network_providers.dart';
import 'package:wasli_customer/core/network/run_api.dart';
import 'package:wasli_customer/core/storage/token_store.dart';

import '../../support/api_fixtures.dart';
import '../../support/fake_http_adapter.dart';
import '../../support/network_harness.dart';
import '../../support/pump_app.dart';

void main() {
  group('dioProvider', () {
    test('uses the API origin of the environment, and is shared', () {
      final container = ProviderContainer(overrides: [appEnvironmentProvider.overrideWithValue(testEnvironment())]);
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);

      expect(dio.options.baseUrl, 'https://api.example.test');
      expect(container.read(dioProvider), same(dio));
    });

    test('announces the end of the session once and clears the token when the server answers 401', () async {
      final store = MemoryTokenStore('tok-1');
      final container = ProviderContainer(
        overrides: [
          appEnvironmentProvider.overrideWithValue(testEnvironment()),
          tokenStoreProvider.overrideWithValue(store),
          appLoggerProvider.overrideWithValue(RecordingLogger()),
        ],
      );
      addTearDown(container.dispose);
      container.read(dioProvider).httpClientAdapter = FakeHttpAdapter(
        (_) => jsonResponse(401, readApiFixture('errors/not_authenticated_401')),
      );
      final announcements = <int>[];
      container.listen(sessionExpiredProvider, (_, next) => announcements.add(next));

      await expectLater(
        runApi(() => CustomersClient(container.read(dioProvider)).customersMe()),
        throwsA(isA<UnauthenticatedFailure>()),
      );

      expect(announcements, [1]);
      expect(await store.read(), isNull);
    });
  });

  test('without an override the environment is a programming error, not a default server', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(appEnvironmentProvider), throwsA(anything));
  });
}
