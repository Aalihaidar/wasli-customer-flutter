import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/config/app_config_exception.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/theme/theme.dart';

/// What opens instead of the app when this build's configuration is wrong (for example `API_BASE_URL` is missing).
///
/// A plain page, so the problem is visible and not a blank screen. The customer reads a short localized explanation;
/// the developer also gets the name of the wrong value ([AppConfigException.message] names it and never holds its value).
class ConfigErrorApp extends StatelessWidget {
  /// Creates the page for [error], in [locale] (English when it is null or not supported).
  const new({required this.error, this.locale, super.key});

  /// What is wrong with the configuration.
  final AppConfigException error;

  /// The language the customer saved, if any.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final language = (locale == null ? null : AppLocales.normalize(locale!)) ?? AppLocales.fallback;
    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: language,
      supportedLocales: AppLocales.supported,
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      theme: WasliTheme.light(language),
      darkTheme: WasliTheme.dark(language),
      home: _ConfigErrorPage(error: error),
    );
  }
}

class _ConfigErrorPage extends StatelessWidget {
  const new({required this.error});

  final AppConfigException error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = context.wasliText;
    return Scaffold(
      body: SafeArea(
        child: PageFrame(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.configErrorTitle, textAlign: TextAlign.center, style: text.heading2),
                const SizedBox(height: WasliSpacing.space3),
                Text(l10n.configErrorMessage, textAlign: TextAlign.center, style: text.body),
                const SizedBox(height: WasliSpacing.space4),
                Text(error.message, textAlign: TextAlign.center, textDirection: TextDirection.ltr, style: text.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
