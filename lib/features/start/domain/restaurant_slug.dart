/// The longest slug the app accepts. The backend sets no limit in its contract, so this only keeps absurd input from
/// being sent anywhere.
const int maxRestaurantSlugLength = 100;

/// The slug that is reserved by the API (`GET /restaurants/nearby`), so it never names a restaurant.
const String _reservedSlug = 'nearby';

final RegExp _slugShape = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_-]*$');

/// Whether [slug] could be a restaurant's address name: letters, digits, `-` and `_`, starting with a letter or digit,
/// at most [maxRestaurantSlugLength] characters, and not the reserved `nearby`.
///
/// A slug comes from a link or a QR code, so it is untrusted input: anything else is "not found" without asking the
/// server, and a slug is never put into a path before it passes this check.
bool isValidRestaurantSlug(String slug) {
  return slug.length <= maxRestaurantSlugLength && slug != _reservedSlug && _slugShape.hasMatch(slug);
}
