// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearest_restaurant_parking_lot_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NearestRestaurantParkingLot$Response _$NearestRestaurantParkingLot$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['name', 'latitude', 'longitude', 'radius_m'],
    disallowNullValues: const ['name', 'latitude', 'longitude', 'radius_m'],
  );
  return NearestRestaurantParkingLot$Response(
    name: json['name'] as String,
    latitude: json['latitude'] as num,
    longitude: json['longitude'] as num,
    radiusM: NearestRestaurantParkingLot$Response._read_radiusM(json['radius_m']),
    additionalProperties: NearestRestaurantParkingLot$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : NearestRestaurantParkingLot$Response._readExtras(
            NearestRestaurantParkingLot$Response._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$NearestRestaurantParkingLot$ResponseToJson(NearestRestaurantParkingLot$Response instance) =>
    <String, dynamic>{
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius_m': ?NearestRestaurantParkingLot$Response._write_radiusM(instance.radiusM),
    };
