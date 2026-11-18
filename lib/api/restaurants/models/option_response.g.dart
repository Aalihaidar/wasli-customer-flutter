// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Option$Response _$Option$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name_en', 'name_ar', 'price_delta_minor', 'is_available', 'is_default'],
    disallowNullValues: const ['id', 'name_en', 'name_ar', 'price_delta_minor', 'is_available', 'is_default'],
  );
  return Option$Response(
    id: json['id'] as String,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    priceDeltaMinor: Option$Response._read_priceDeltaMinor(json['price_delta_minor']),
    isAvailable: json['is_available'] as bool,
    isDefault: json['is_default'] as bool,
    additionalProperties: Option$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : Option$Response._readExtras(Option$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$Option$ResponseToJson(Option$Response instance) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'price_delta_minor': ?Option$Response._write_priceDeltaMinor(instance.priceDeltaMinor),
  'is_available': instance.isAvailable,
  'is_default': instance.isDefault,
};
