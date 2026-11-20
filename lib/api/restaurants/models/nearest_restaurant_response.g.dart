// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearest_restaurant_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NearestRestaurant$Response _$NearestRestaurant$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['slug', 'name_en', 'name_ar', 'logo_url', 'latitude', 'longitude', 'distance_m', 'is_open'],
    disallowNullValues: const [
      'slug',
      'name_en',
      'name_ar',
      'latitude',
      'longitude',
      'service_radius_m',
      'distance_m',
      'is_open',
    ],
  );
  return NearestRestaurant$Response(
    slug: json['slug'] as String,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    logoUrl: json['logo_url'] as String?,
    latitude: json['latitude'] as num,
    longitude: json['longitude'] as num,
    serviceRadiusM: NearestRestaurant$Response._read_serviceRadiusM(json['service_radius_m']),
    distanceM: NearestRestaurant$Response._read_distanceM(json['distance_m']),
    isOpen: json['is_open'] as bool,
    additionalProperties: NearestRestaurant$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : NearestRestaurant$Response._readExtras(NearestRestaurant$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$NearestRestaurant$ResponseToJson(NearestRestaurant$Response instance) => <String, dynamic>{
  'slug': instance.slug,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'logo_url': instance.logoUrl,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'service_radius_m': ?NearestRestaurant$Response._write_serviceRadiusM(instance.serviceRadiusM),
  'distance_m': ?NearestRestaurant$Response._write_distanceM(instance.distanceM),
  'is_open': instance.isOpen,
};
