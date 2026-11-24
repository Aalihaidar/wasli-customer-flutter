import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/network/network_timeouts.dart';
import 'package:wasli_customer/features/server_config/data/server_config_mapper.dart';
import 'package:wasli_customer/features/server_config/data/server_config_repository_impl.dart';
import 'package:wasli_customer/features/server_config/domain/server_config.dart';

import '../../../support/api_fixtures.dart';
import '../../../support/fake_http_adapter.dart';
import '../../../support/network_harness.dart';

void main() {
  group('serverConfigFromDto', () {
    test('reads the answer of GET /config', () {
      final config = serverConfigFromDto(Config.fromJson(readApiFixture('config_200')));

      expect(config.locationCheck, LocationCheck.warn);
      expect(config.requireScreenOnline, isTrue);
      expect(config.aiEnabled, isTrue);
      expect(config.languages, ['en', 'ar']);
      expect(config.pollInterval, const Duration(seconds: 3));
    });

    test('reads every location rule', () {
      for (final (raw, expected) in [
        ('off', LocationCheck.off),
        ('warn', LocationCheck.warn),
        ('enforce', LocationCheck.enforce),
      ]) {
        final json = {...readApiFixture('config_200'), 'location_check': raw};

        expect(serverConfigFromDto(Config.fromJson(json)).locationCheck, expected, reason: raw);
      }
    });

    test('keeps a rule or a language the server adds later, and does not reject the answer', () {
      final json = {
        ...readApiFixture('config_200'),
        'location_check': 'strict',
        'languages': ['en', 'ar', 'fr'],
        'ai_enabled': false,
      };

      final config = serverConfigFromDto(Config.fromJson(json));

      expect(config.locationCheck, LocationCheck.unknown);
      expect(config.languages, ['en', 'ar', 'fr']);
      expect(config.aiEnabled, isFalse);
    });
  });

  group('ServerConfigRepositoryImpl', () {
    test('reads the settings without a token and waits long enough for a sleeping server', () async {
      final harness = NetworkHarness((_) => jsonResponse(200, readApiFixture('config_200')), token: 'tok-1');

      final config = await ServerConfigRepositoryImpl(ConfigClient(harness.dio)).load();

      expect(config.pollInterval, const Duration(seconds: 3));
      final request = harness.adapter.requests.single;
      expect(request.uri.toString(), 'https://api.example.test/api/v1/config');
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(request.receiveTimeout, NetworkTimeouts.coldStart);
    });

    test('throws a Failure when the server cannot be reached', () async {
      final harness = NetworkHarness((options) => throw connectionFailure(options, DioExceptionType.connectionError));

      await expectLater(
        ServerConfigRepositoryImpl(ConfigClient(harness.dio)).load(),
        throwsA(isA<NetworkFailure>().having((f) => f.kind, 'kind', NetworkFailureKind.offline)),
      );
    });

    test('throws a generic Failure when the answer is not what the contract says', () async {
      final harness = NetworkHarness((_) => jsonResponse(200, {'ai_enabled': 'yes'}));

      await expectLater(
        ServerConfigRepositoryImpl(ConfigClient(harness.dio)).load(),
        throwsA(isA<UnexpectedFailure>()),
      );
    });
  });
}
