import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/l10n/app_locales.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/l10n/locale_controller.dart';
import 'package:wasli_customer/theme/theme.dart';

/// Switches the app between English and Arabic. Each language is named in its own language, so a customer finds
/// theirs whatever the app currently shows.
class LanguageSwitch extends ConsumerWidget {
  /// Creates the switch.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l10n = context.l10n;

    return Semantics(
      container: true,
      label: l10n.languageSwitchLabel,
      child: SegmentedButton<Locale>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(minimumSize: const Size(0, WasliLayout.minTapTarget)),
        segments: [
          ButtonSegment(value: AppLocales.english, label: Text(l10n.languageEnglish)),
          ButtonSegment(value: AppLocales.arabic, label: Text(l10n.languageArabic)),
        ],
        selected: {locale},
        onSelectionChanged: (selection) => ref.read(localeProvider.notifier).setLocale(selection.single),
      ),
    );
  }
}
