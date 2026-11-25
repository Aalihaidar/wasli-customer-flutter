import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasli_customer/features/server_config/domain/server_config.dart';
import 'package:wasli_customer/features/server_config/presentation/server_status_line.dart';

import '../../../support/fake_server_config_repository.dart';
import '../../../support/pump_app.dart';

void main() {
  group('the server status line while the server is slow', () {
    testWidgets('says it is waking up after the delay, then shows the answer', (tester) async {
      final completer = Completer<ServerConfig>();
      final repository = FakeServerConfigRepository(() => completer.future);

      await pumpApp(tester, serverConfig: repository);
      expect(find.text('Contacting the server…'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Contacting the server…'), findsOneWidget);

      await tester.pump(serverWakingDelay);
      expect(find.text('Waking up the server, this can take up to a minute…'), findsOneWidget);
      expect(find.text('Contacting the server…'), findsNothing);

      completer.complete(defaultServerConfig);
      await tester.pumpAndSettle();

      expect(find.text('Waking up the server, this can take up to a minute…'), findsNothing);
      expect(find.text('Server connected (\u2066staging\u2069). The assistant is on.'), findsOneWidget);
    });

    testWidgets('a fast answer never shows the waking line', (tester) async {
      await pumpApp(tester);
      await tester.pump(serverWakingDelay * 2);

      expect(find.text('Waking up the server, this can take up to a minute…'), findsNothing);
    });

    testWidgets('says it in Arabic too', (tester) async {
      final repository = FakeServerConfigRepository(() => Completer<ServerConfig>().future);

      await pumpApp(tester, serverConfig: repository, savedLocale: const Locale('ar'));
      await tester.pump(serverWakingDelay);

      expect(find.text('جارٍ تشغيل الخادم، قد يستغرق ذلك حتى دقيقة…'), findsOneWidget);
    });
  });
}
