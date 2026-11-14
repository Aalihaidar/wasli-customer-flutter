// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_restaurant_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NearbyRestaurant$Response _$NearbyRestaurant$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['slug', 'name_en', 'name_ar', 'logo_url', 'latitude', 'longitude', 'distance_m', 'is_open'],
    disallowNullValues: const ['slug', 'name_en', 'name_ar', 'latitude', 'longitude', 'distance_m', 'is_open'],
  );
  return NearbyRestaurant$Response(
    slug: json['slug'] as String,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    logoUrl: json['logo_url'] as String?,
    latitude: json['latitude'] as num,
    longitude: json['longitude'] as num,
    distanceM: NearbyRestaurant$Response._read_distanceM(json['distance_m']),
    isOpen: json['is_open'] as bool,
    additionalProperties: NearbyRestaurant$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : NearbyRestaurant$Response._readExtras(NearbyRestaurant$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$NearbyRestaurant$ResponseToJson(NearbyRestaurant$Response instance) => <String, dynamic>{
  'slug': instance.slug,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'logo_url': instance.logoUrl,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'distance_m': ?NearbyRestaurant$Response._write_distanceM(instance.distanceM),
  'is_open': instance.isOpen,
};
