import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/config/app_environment_provider.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/bidi_isolate.dart';
import 'package:wasli_customer/core/l10n/failure_text.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/features/server_config/application/server_config_providers.dart';
import 'package:wasli_customer/theme/theme.dart';

/// How long the server may stay silent before the line says it is waking up.
///
/// A sleeping staging server needs up to a minute to start, and a customer who sees nothing happen leaves.
const Duration serverWakingDelay = Duration(seconds: 3);

/// One line that shows whether the server answered: waiting, connected (with the stage and the assistant), or the
/// reason it failed with a button to try again.
///
/// A diagnostic for test builds, so the page that holds it shows it only outside production.
class ServerStatusLine extends ConsumerWidget {
  /// Creates the line.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final stage = isolateLeftToRight(ref.watch(appEnvironmentProvider.select((environment) => environment.stage.name)));

    return ref
        .watch(serverConfigProvider)
        .when(
          loading: _LoadingMessage.new,
          data: (config) => _Message(
            config.aiEnabled ? l10n.serverStatusAssistantOn(stage: stage) : l10n.serverStatusAssistantOff(stage: stage),
          ),
          error: (error, _) {
            final failure = error is Failure ? error : null;
            final requestId = failure?.requestId;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Message(failure == null ? l10n.failureGeneric : failureText(l10n, failure)),
                if (requestId != null) _Message(l10n.failureReference(requestId: isolateLeftToRight(requestId))),
                TextButton(onPressed: () => ref.invalidate(serverConfigProvider), child: Text(l10n.serverStatusRetry)),
              ],
            );
          },
        );
  }
}

class _Message extends StatelessWidget {
  const new(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: TextAlign.center, style: context.wasliText.bodySmall);
  }
}

/// "Contacting the server" that turns into "Waking up the server" when the wait passes [serverWakingDelay].
class _LoadingMessage extends StatefulWidget {
  const new();

  @override
  State<_LoadingMessage> createState() => _LoadingMessageState();
}

class _LoadingMessageState extends State<_LoadingMessage> {
  late final Timer _timer;
  bool _waking = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(serverWakingDelay, () => setState(() => _waking = true));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Message(_waking ? l10n.serverStatusWaking : l10n.serverStatusLoading);
  }
}
