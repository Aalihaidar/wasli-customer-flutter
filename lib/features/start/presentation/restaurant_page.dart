import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/failure_text.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/features/start/application/start_providers.dart';
import 'package:wasli_customer/features/start/presentation/restaurant_logo.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The page of one restaurant, opened from the list or from its QR code (`/r/<slug>`).
///
/// For now it shows the restaurant's logo and name; the chat takes over this page. A restaurant that does not exist or is
/// not active says so, and any other failure offers "Try again". The slug must already have passed
/// `isValidRestaurantSlug`: the router does that.
class RestaurantPage extends ConsumerWidget {
  /// Creates the page for the restaurant named [slug]. [onGoToStart] opens the start page.
  const new({required this.slug, required this.onGoToStart, super.key});

  /// The restaurant's address name.
  final String slug;

  /// Opens the start page.
  final VoidCallback onGoToStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final canGoBack = Navigator.of(context).canPop();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        // Opened from a link there is nothing to go back to, so the bar offers the start page instead.
        leading: canGoBack
            ? null
            : IconButton(
                icon: Icon(Icons.home_outlined, semanticLabel: l10n.notFoundAction),
                tooltip: l10n.notFoundAction,
                onPressed: onGoToStart,
              ),
      ),
      body: SafeArea(
        child: PageFrame(
          // Scrollable so a large text size never overflows; centred while it fits.
          child: Center(
            child: SingleChildScrollView(
              child: ref
                  .watch(restaurantProfileProvider(slug))
                  .when(
                    loading: () => Semantics(
                      label: l10n.restaurantLoading,
                      liveRegion: true,
                      child: const CircularProgressIndicator(),
                    ),
                    error: (error, _) => switch (error) {
                      NotFoundFailure() => _Message(
                        title: l10n.restaurantUnavailableTitle,
                        body: l10n.restaurantUnavailableBody,
                        actionLabel: l10n.notFoundAction,
                        onAction: onGoToStart,
                      ),
                      _ => _Message(
                        title: error is Failure ? failureText(l10n, error) : l10n.failureGeneric,
                        actionLabel: l10n.startTryAgain,
                        onAction: () => ref.invalidate(restaurantProfileProvider(slug)),
                      ),
                    },
                    data: (restaurant) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RestaurantLogo(url: restaurant.logoUrl),
                        const SizedBox(height: WasliSpacing.space4),
                        Text(
                          restaurant.nameFor(locale.languageCode),
                          style: context.wasliText.display,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const new({required this.title, required this.actionLabel, required this.onAction, this.body});

  final String title;
  final String? body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final text = body;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(title, style: context.wasliText.heading2, textAlign: TextAlign.center),
        ),
        if (text != null) ...[const SizedBox(height: WasliSpacing.space2), Text(text, textAlign: TextAlign.center)],
        const SizedBox(height: WasliSpacing.space5),
        FilledButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}
