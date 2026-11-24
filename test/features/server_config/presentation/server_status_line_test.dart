import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/app/placeholder_page.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/features/server_config/domain/server_config.dart';

import '../../../support/fake_server_config_repository.dart';
import '../../../support/pump_app.dart';

void main() {
  group('the server status line on the start page', () {
    testWidgets('says it is contacting the server while it waits, then that the assistant is on', (tester) async {
      final completer = Completer<ServerConfig>();
      final repository = FakeServerConfigRepository(() => completer.future);

      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, serverConfig: repository);
      expect(find.text('Contacting the server…'), findsOneWidget);

      completer.complete(defaultServerConfig);
      await tester.pumpAndSettle();

      expect(find.text('Contacting the server…'), findsNothing);
      expect(find.text('Server connected (\u2066staging\u2069). The assistant is on.'), findsOneWidget);
    });

    testWidgets('says when the assistant is off', (tester) async {
      final repository = FakeServerConfigRepository(
        () async => const ServerConfig(
          locationCheck: LocationCheck.warn,
          requireScreenOnline: true,
          aiEnabled: false,
          languages: ['en'],
          pollInterval: Duration(seconds: 3),
        ),
      );

      await pumpApp(tester, serverConfig: repository);

      expect(find.text('Server connected (\u2066staging\u2069). The assistant is off.'), findsOneWidget);
    });

    testWidgets('says why it failed, never the server text, with the reference, and tries again on tap', (
      tester,
    ) async {
      final repository = FakeServerConfigRepository.failing(
        const UnexpectedFailure(statusCode: 500, requestId: 'req-9f3a'),
      );

      await pumpApp(tester, serverConfig: repository);

      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
      expect(find.text('Reference: \u2066req-9f3a\u2069'), findsOneWidget);
      expect(repository.loads, 1);

      repository.onLoad = () async => defaultServerConfig;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(repository.loads, 2);
      expect(find.text('Try again'), findsNothing);
      expect(find.textContaining('Server connected'), findsOneWidget);
    });

    testWidgets('names an offline phone', (tester) async {
      await pumpApp(
        tester,
        serverConfig: FakeServerConfigRepository.failing(const NetworkFailure(NetworkFailureKind.offline)),
      );

      expect(find.text('You are offline. Check your connection and try again.'), findsOneWidget);
      expect(find.textContaining('Reference'), findsNothing);
    });

    testWidgets('is in Arabic, right to left, when the customer chose Arabic', (tester) async {
      await pumpApp(tester, savedLocale: const Locale('ar'));

      expect(find.text('تم الاتصال بالخادم (\u2066staging\u2069). المساعد يعمل.'), findsOneWidget);
    });

    testWidgets('is not shown, and the server is not asked, in a production build', (tester) async {
      final repository = FakeServerConfigRepository.value();

      await pumpApp(
        tester,
        environment: testEnvironment(appEnv: 'production'),
        serverConfig: repository,
      );

      expect(find.byType(PlaceholderPage), findsOneWidget);
      expect(find.textContaining('Server connected'), findsNothing);
      expect(find.text('Contacting the server…'), findsNothing);
      expect(repository.loads, 0);
    });
  });
}
