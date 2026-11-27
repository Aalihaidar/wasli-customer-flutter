import 'package:wasli_customer/features/start/domain/coordinates.dart';

/// A restaurant the start screen lists, as `GET /restaurants/nearby` describes it.
class NearbyRestaurant {
  /// Creates a restaurant entry.
  const new({
    required this.slug,
    required this.nameEn,
    required this.nameAr,
    required this.logoUrl,
    required this.position,
    required this.serviceRadiusMetres,
    required this.distanceMetres,
    required this.isOpen,
  });

  /// The restaurant's address name, used in links and QR codes (`/r/<slug>`).
  final String slug;

  /// The English name.
  final String nameEn;

  /// The Arabic name (the server sends the English one when there is no Arabic name).
  final String nameAr;

  /// The absolute address of the logo, or `null` when the restaurant has none.
  final String? logoUrl;

  /// Where the restaurant is.
  final Coordinates position;

  /// How far from the restaurant it serves cars, or `null` when it sets no limit.
  final int? serviceRadiusMetres;

  /// How far the restaurant is from the customer, in metres.
  final int distanceMetres;

  /// Whether the restaurant's site is online and can take an order now.
  final bool isOpen;

  /// The name in [languageCode] (`ar` or anything else for English).
  String nameFor(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
}
