import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/features/settings/presentation/language_setting.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The settings page. Today it holds the language; the account (contact details, sign out) joins it with the account
/// screens.
class SettingsPage extends StatelessWidget {
  /// Creates the page. [onGoToStart] opens the start page; it is the way back when the page was opened directly from
  /// its address, so there is nothing to go back to.
  const new({required this.onGoToStart, super.key});

  /// Goes to the start page.
  final VoidCallback onGoToStart;

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.canPop(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settingsTitle),
        leading: canGoBack
            ? null
            : IconButton(
                icon: const BackButtonIcon(),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onGoToStart,
              ),
      ),
      body: SafeArea(
        child: PageFrame(
          child: ListView(
            padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space4),
            children: const [LanguageSetting()],
          ),
        ),
      ),
    );
  }
}
