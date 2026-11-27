import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wasli_customer/core/session/session_controller.dart';
import 'package:wasli_customer/core/session/session_state.dart';
import 'package:wasli_customer/features/chat/presentation/chat_view.dart';
import 'package:wasli_customer/features/chat/presentation/sign_in_gate.dart';

/// What sits under the restaurant's name: the chat for a signed-in customer, or the offer to sign in or create an account
/// (an order needs one). The pages it opens belong to other features, so the way to them is a callback.
class ChatSection extends ConsumerWidget {
  /// Creates the section for the restaurant [slug]. [restaurantPosition] is only for the test build's simulate button.
  const new({
    required this.slug,
    required this.restaurantPosition,
    required this.onSignIn,
    required this.onSignUp,
    required this.onConfirmPhone,
    super.key,
  });

  /// The restaurant's address name.
  final String slug;

  /// The restaurant's position.
  final ({double latitude, double longitude}) restaurantPosition;

  /// Opens the sign-in page.
  final VoidCallback onSignIn;

  /// Opens the sign-up page.
  final VoidCallback onSignUp;

  /// Opens the page where the customer adds and confirms a phone number.
  final VoidCallback onConfirmPhone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(sessionProvider)) {
      SignedIn() => ChatView(slug: slug, restaurantPosition: restaurantPosition, onConfirmPhone: onConfirmPhone),
      SignedOut() => Align(
        alignment: AlignmentDirectional.topCenter,
        child: SingleChildScrollView(
          child: SignInGate(onSignIn: onSignIn, onSignUp: onSignUp),
        ),
      ),
    };
  }
}
