// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_category_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuCategory$Response _$MenuCategory$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'name_en', 'name_ar', 'items'],
    disallowNullValues: const ['id', 'name_en', 'name_ar', 'items'],
  );
  return MenuCategory$Response(
    id: json['id'] as String,
    nameEn: json['name_en'] as String,
    nameAr: json['name_ar'] as String,
    items: (json['items'] as List<dynamic>).map((e) => MenuItem$Response.fromJson(e as Map<String, dynamic>)).toList(),
    additionalProperties: MenuCategory$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : MenuCategory$Response._readExtras(MenuCategory$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$MenuCategory$ResponseToJson(MenuCategory$Response instance) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ar': instance.nameAr,
  'items': instance.items.map((e) => e.toJson()).toList(),
};
