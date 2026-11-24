// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationRequest _$LocationRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['lat', 'lng', 'source'],
    disallowNullValues: const ['lat', 'lng', 'accuracy_m', 'source'],
  );
  return LocationRequest(
    lat: json['lat'] as num,
    lng: json['lng'] as num,
    accuracyM: json['accuracy_m'] as num?,
    source: LocationRequest._read_source(json['source']),
    additionalProperties: LocationRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : LocationRequest._readExtras(LocationRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$LocationRequestToJson(LocationRequest instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
  'accuracy_m': ?instance.accuracyM,
  'source': ?LocationRequest._write_source(instance.source),
};
