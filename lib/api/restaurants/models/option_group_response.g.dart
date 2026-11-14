// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'option_group_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OptionGroup$Response _$OptionGroup$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name_en', 'name_ar', 'min_select', 'max_select', 'options'],
    disallowNullValues: const ['id', 'name_en', 'name_ar', 'min_select', 'max_select', 'options'],
  );
  return OptionGroup$Response(
    id: json['id'] as String,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    minSelect: OptionGroup$Response._read_minSelect(json['min_select']),
    maxSelect: OptionGroup$Response._read_maxSelect(json['max_select']),
    options: (json['options'] as List<dynamic>)
        .map((e) => Option$Response.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: OptionGroup$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : OptionGroup$Response._readExtras(OptionGroup$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$OptionGroup$ResponseToJson(OptionGroup$Response instance) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'min_select': ?OptionGroup$Response._write_minSelect(instance.minSelect),
  'max_select': ?OptionGroup$Response._write_maxSelect(instance.maxSelect),
  'options': instance.options.map((e) => e.toJson()).toList(),
};
