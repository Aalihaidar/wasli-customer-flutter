// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_image_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuImage$Response _$MenuImage$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['image_url', 'caption_en', 'caption_ar'],
    disallowNullValues: const ['caption_en', 'caption_ar'],
  );
  return MenuImage$Response(
    imageUrl: json['image_url'] as String?,
    captionEn: json['caption_en'] as String,
    captionAr: json['caption_ar'] as String,
    additionalProperties: MenuImage$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : MenuImage$Response._readExtras(MenuImage$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$MenuImage$ResponseToJson(MenuImage$Response instance) => <String, dynamic>{
  'image_url': instance.imageUrl,
  'caption_en': instance.captionEn,
  'caption_ar': instance.captionAr,
};
