import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The language section of the settings: a heading and one choice per language.
///
/// Each language is named in its own language, so a customer finds theirs whatever the app currently shows. Choosing
/// one switches the whole app at once and is remembered for the next visit.
class LanguageSetting extends ConsumerWidget {
  /// Creates the section.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(header: true, child: Text(l10n.settingsLanguageTitle, style: context.wasliText.heading3)),
        const SizedBox(height: WasliSpacing.space2),
        Card(
          child: RadioGroup<Locale>(
            groupValue: locale,
            onChanged: (value) {
              if (value != null) ref.read(localeProvider.notifier).setLocale(value);
            },
            child: Column(
              children: [
                RadioListTile<Locale>(value: AppLocales.english, title: Text(l10n.languageEnglish)),
                RadioListTile<Locale>(value: AppLocales.arabic, title: Text(l10n.languageArabic)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
