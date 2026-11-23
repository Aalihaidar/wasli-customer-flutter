import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/app/router/app_router.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The themes for the active language, built once per language and not on every rebuild. Arabic has its own type
/// settings (letter spacing 0), so a language change rebuilds them.
final _lightThemeProvider = Provider<ThemeData>((ref) => WasliTheme.light(ref.watch(localeProvider)));
final _darkThemeProvider = Provider<ThemeData>((ref) => WasliTheme.dark(ref.watch(localeProvider)));

/// Root widget of the customer app.
///
/// It wires the router, the language (English by default, Arabic right to left, chosen in the settings), the
/// localization delegates and the Ink & Mustard theme, light or dark by the system setting.
class App extends ConsumerWidget {
  /// Creates the root widget.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocales.supported,
      // `GlobalMaterialLocalizations.delegates` (from `material_ui`, not the deprecated Material delegate of
      // `flutter_localizations`) holds the Material, Widgets and Cupertino delegates; the framework warns in debug builds
      // when a supported language has no Cupertino delegate. `AppLocalizations.localizationsDelegates` is not used for
      // the same reason.
      localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
      theme: ref.watch(_lightThemeProvider),
      darkTheme: ref.watch(_darkThemeProvider),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
