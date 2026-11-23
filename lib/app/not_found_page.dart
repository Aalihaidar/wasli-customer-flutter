import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/router/app_routes.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/theme/theme.dart';

/// Shown when the address matches no page of the app, with a way back to the start page.
class NotFoundPage extends StatelessWidget {
  /// Creates the page.
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: SafeArea(
        child: PageFrame(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.notFoundTitle, style: context.wasliText.heading1, textAlign: TextAlign.center),
                const SizedBox(height: WasliSpacing.space2),
                Text(l10n.notFoundMessage, textAlign: TextAlign.center),
                const SizedBox(height: WasliSpacing.space5),
                FilledButton(onPressed: () => context.go(AppRoutes.home), child: Text(l10n.notFoundAction)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
