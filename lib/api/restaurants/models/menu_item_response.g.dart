// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem$Response _$MenuItem$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'name_en',
      'name_ar',
      'description_en',
      'description_ar',
      'price_minor',
      'image_url',
      'is_available',
      'option_groups',
    ],
    disallowNullValues: const [
      'id',
      'name_en',
      'name_ar',
      'description_en',
      'description_ar',
      'price_minor',
      'is_available',
      'option_groups',
    ],
  );
  return MenuItem$Response(
    id: json['id'] as String,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    descriptionEn: json['description_en'] as String,
    descriptionAr: json['description_ar'] as String,
    priceMinor: MenuItem$Response._read_priceMinor(json['price_minor']),
    imageUrl: json['image_url'] as String?,
    isAvailable: json['is_available'] as bool,
    optionGroups: (json['option_groups'] as List<dynamic>)
        .map((e) => OptionGroup$Response.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: MenuItem$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : MenuItem$Response._readExtras(MenuItem$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$MenuItem$ResponseToJson(MenuItem$Response instance) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'description_en': instance.descriptionEn,
  'description_ar': instance.descriptionAr,
  'price_minor': ?MenuItem$Response._write_priceMinor(instance.priceMinor),
  'image_url': instance.imageUrl,
  'is_available': instance.isAvailable,
  'option_groups': instance.optionGroups.map((e) => e.toJson()).toList(),
};
