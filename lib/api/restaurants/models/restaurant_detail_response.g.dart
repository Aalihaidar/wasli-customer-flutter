// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantDetail$Response _$RestaurantDetail$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'slug',
      'name_en',
      'name_ar',
      'logo_url',
      'brand_colour',
      'latitude',
      'longitude',
      'currency',
      'parking_lot',
      'menu_images',
      'menu',
    ],
    disallowNullValues: const [
      'slug',
      'name_en',
      'name_ar',
      'brand_colour',
      'latitude',
      'longitude',
      'currency',
      'parking_lot',
      'menu_images',
      'menu',
    ],
  );
  return RestaurantDetail$Response(
    slug: json['slug'] as String,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    logoUrl: json['logo_url'] as String?,
    brandColour: json['brand_colour'] as String,
    latitude: json['latitude'] as num,
    longitude: json['longitude'] as num,
    currency: json['currency'] as String,
    parkingLot: RestaurantDetailParkingLot$Response.fromJson(json['parking_lot'] as Map<String, dynamic>),
    menuImages: (json['menu_images'] as List<dynamic>)
        .map((e) => MenuImage$Response.fromJson(e as Map<String, dynamic>))
        .toList(),
    menu: (json['menu'] as List<dynamic>)
        .map((e) => MenuCategory$Response.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: RestaurantDetail$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : RestaurantDetail$Response._readExtras(RestaurantDetail$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$RestaurantDetail$ResponseToJson(RestaurantDetail$Response instance) => <String, dynamic>{
  'slug': instance.slug,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'logo_url': instance.logoUrl,
  'brand_colour': instance.brandColour,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'currency': instance.currency,
  'parking_lot': instance.parkingLot.toJson(),
  'menu_images': instance.menuImages.map((e) => e.toJson()).toList(),
  'menu': instance.menu.map((e) => e.toJson()).toList(),
};
