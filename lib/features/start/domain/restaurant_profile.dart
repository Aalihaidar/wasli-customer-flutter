import 'package:wasli_customer/features/start/domain/coordinates.dart';

/// What the public page of a restaurant shows, as `GET /restaurants/{slug}` describes it. The menu is not part of it yet:
/// the chat and the item picker read it when they are built.
class RestaurantProfile {
  /// Creates a profile.
  const new({
    required this.slug,
    required this.nameEn,
    required this.nameAr,
    required this.logoUrl,
    required this.position,
  });

  /// The restaurant's address name.
  final String slug;

  /// The English name.
  final String nameEn;

  /// The Arabic name (the server sends the English one when there is no Arabic name).
  final String nameAr;

  /// The absolute address of the logo, or `null` when the restaurant has none.
  final String? logoUrl;

  /// Where the restaurant is.
  final Coordinates position;

  /// The name in [languageCode] (`ar` or anything else for English).
  String nameFor(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
}
