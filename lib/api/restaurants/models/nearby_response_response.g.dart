// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nearby_response_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NearbyResponse$Response _$NearbyResponse$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['restaurants', 'nearest'],
    disallowNullValues: const ['restaurants', 'nearest'],
  );
  return NearbyResponse$Response(
    restaurants: (json['restaurants'] as List<dynamic>)
        .map((e) => NearbyRestaurant$Response.fromJson(e as Map<String, dynamic>))
        .toList(),
    nearest: NearestRestaurant$Response.fromJson(json['nearest'] as Map<String, dynamic>),
    additionalProperties: NearbyResponse$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : NearbyResponse$Response._readExtras(NearbyResponse$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$NearbyResponse$ResponseToJson(NearbyResponse$Response instance) => <String, dynamic>{
  'restaurants': instance.restaurants.map((e) => e.toJson()).toList(),
  'nearest': instance.nearest.toJson(),
};
