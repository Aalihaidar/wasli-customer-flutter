import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/features/settings/presentation/language_setting.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The settings page: the language, then the customer's account.
///
/// The language comes first because the app starts in English whatever the device language is, so a customer who reads
/// Arabic must find the switch without scrolling.
///
/// The account section belongs to the account feature, and a feature never imports another one, so the router hands it
/// in as [accountSection].
class SettingsPage extends StatelessWidget {
  /// Creates the page. [onGoToStart] opens the start page; it is the way back when the page was opened directly from
  /// its address, so there is nothing to go back to.
  const new({required this.onGoToStart, required this.accountSection, super.key});

  /// Goes to the start page.
  final VoidCallback onGoToStart;

  /// The account part of the page (contact details, sign in and out).
  final Widget accountSection;

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
            children: [
              const LanguageSetting(),
              const SizedBox(height: WasliSpacing.space5),
              accountSection,
            ],
          ),
        ),
      ),
    );
  }
}
