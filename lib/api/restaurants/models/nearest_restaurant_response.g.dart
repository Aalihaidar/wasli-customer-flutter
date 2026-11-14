// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearest_restaurant_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NearestRestaurant$Response _$NearestRestaurant$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'slug',
      'name_en',
      'name_ar',
      'logo_url',
      'latitude',
      'longitude',
      'distance_m',
      'is_open',
      'parking_lot',
    ],
    disallowNullValues: const [
      'slug',
      'name_en',
      'name_ar',
      'latitude',
      'longitude',
      'distance_m',
      'is_open',
      'parking_lot',
    ],
  );
  return NearestRestaurant$Response(
    slug: json['slug'] as String,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    logoUrl: json['logo_url'] as String?,
    latitude: json['latitude'] as num,
    longitude: json['longitude'] as num,
    distanceM: NearestRestaurant$Response._read_distanceM(json['distance_m']),
    isOpen: json['is_open'] as bool,
    parkingLot: NearestRestaurantParkingLot$Response.fromJson(json['parking_lot'] as Map<String, dynamic>),
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
  'distance_m': ?NearestRestaurant$Response._write_distanceM(instance.distanceM),
  'is_open': instance.isOpen,
  'parking_lot': instance.parkingLot.toJson(),
};
