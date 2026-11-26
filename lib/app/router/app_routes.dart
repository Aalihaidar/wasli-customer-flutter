/// The paths of the app's pages. Paths have no trailing slash.
abstract final class AppRoutes {
  /// The start page.
  static const String home = '/';

  /// The settings page, where the customer manages the account and changes the language.
  static const String settings = '/settings';

  /// The sign-in page.
  static const String signIn = '/signin';

  /// The sign-up page.
  static const String signUp = '/signup';

  /// The page where the customer types the 6-digit code that was sent to them.
  static const String verify = '/verify';

  /// The page where a signed-in customer adds an email address to the account.
  static const String addEmail = '/settings/email';

  /// The page where a signed-in customer adds a phone number to the account.
  static const String addPhone = '/settings/phone';
}
