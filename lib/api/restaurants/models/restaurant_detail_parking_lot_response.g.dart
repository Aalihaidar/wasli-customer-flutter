// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_detail_parking_lot_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantDetailParkingLot$Response _$RestaurantDetailParkingLot$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'latitude', 'longitude', 'radius_m'],
    disallowNullValues: const ['name', 'latitude', 'longitude', 'radius_m'],
  );
  return RestaurantDetailParkingLot$Response(
    name: json['name'] as String,
    latitude: json['latitude'] as num,
    longitude: json['longitude'] as num,
    radiusM: RestaurantDetailParkingLot$Response._read_radiusM(json['radius_m']),
    additionalProperties: RestaurantDetailParkingLot$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : RestaurantDetailParkingLot$Response._readExtras(
            RestaurantDetailParkingLot$Response._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$RestaurantDetailParkingLot$ResponseToJson(RestaurantDetailParkingLot$Response instance) =>
    <String, dynamic>{
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius_m': ?RestaurantDetailParkingLot$Response._write_radiusM(instance.radiusM),
    };
