import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/error/failure.dart';
import 'package:wasli_customer/core/l10n/failure_text.dart';
import 'package:wasli_customer/core/l10n/l10n.dart';
import 'package:wasli_customer/core/widgets/page_frame.dart';
import 'package:wasli_customer/features/start/application/start_providers.dart';
import 'package:wasli_customer/features/start/domain/restaurant_profile.dart';
import 'package:wasli_customer/features/start/presentation/restaurant_logo.dart';
import 'package:wasli_customer/theme/theme.dart';

/// The page of one restaurant, opened from the list or from its QR code (`/r/<slug>`).
///
/// It shows the restaurant's logo and name, and under them the chat for a signed-in customer or the offer to sign in. A restaurant that does not exist or is
/// not active says so, and any other failure offers "Try again". The slug must already have passed
/// `isValidRestaurantSlug`: the router does that.
class RestaurantPage extends ConsumerWidget {
  /// Creates the page for the restaurant named [slug]. [onGoToStart] opens the start page. [chatBuilder] makes what sits
  /// under the restaurant's name (the chat belongs to another feature, so the router hands it in).
  const new({required this.slug, required this.onGoToStart, required this.chatBuilder, super.key});

  /// The restaurant's address name.
  final String slug;

  /// Opens the start page.
  final VoidCallback onGoToStart;

  /// Builds the chat (or the offer to sign in) for the loaded restaurant.
  final Widget Function(RestaurantProfile restaurant) chatBuilder;

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
          child: ref
              .watch(restaurantProfileProvider(slug))
              .when(
                loading: () => _Centered(
                  child: Semantics(
                    label: l10n.restaurantLoading,
                    liveRegion: true,
                    child: const CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => _Centered(
                  child: switch (error) {
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
                ),
                data: (restaurant) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(vertical: WasliSpacing.space3),
                      child: Row(
                        children: [
                          RestaurantLogo(url: restaurant.logoUrl),
                          const SizedBox(width: WasliSpacing.space3),
                          Expanded(
                            child: Text(restaurant.nameFor(locale.languageCode), style: context.wasliText.heading2),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: chatBuilder(restaurant)),
                  ],
                ),
              ),
        ),
      ),
    );
  }
}

/// Centres a short message and lets it scroll when a large text size makes it taller than the screen.
class _Centered extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Center(child: SingleChildScrollView(child: child));
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
