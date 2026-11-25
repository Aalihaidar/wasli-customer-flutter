/// The paths of the app's pages. Paths have no trailing slash.
abstract final class AppRoutes {
  /// The start page.
  static const String home = '/';

  /// The settings page, where the customer changes the language.
  static const String settings = '/settings';

  /// The sign-up page.
  static const String signUp = '/signup';

  /// The page where the customer types the 6-digit code that was sent to them.
  static const String verify = '/verify';
}
