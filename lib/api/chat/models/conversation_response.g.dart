// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Conversation$Response _$Conversation$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'restaurant_slug', 'state', 'locale', 'order_type', 'ai_available', 'expires_at'],
    disallowNullValues: const ['id', 'restaurant_slug', 'ai_available', 'expires_at'],
  );
  return Conversation$Response(
    id: json['id'] as String,
    restaurantSlug: json['restaurant_slug'] as String,
    state: Conversation$Response._read_state(json['state']),
    locale: Conversation$Response._read_locale(json['locale']),
    orderType: Conversation$Response._read_orderType(json['order_type']),
    aiAvailable: json['ai_available'] as bool,
    expiresAt: Conversation$Response._read_expiresAt(json['expires_at']),
    additionalProperties: Conversation$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : Conversation$Response._readExtras(Conversation$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$Conversation$ResponseToJson(Conversation$Response instance) => <String, dynamic>{
  'id': instance.id,
  'restaurant_slug': instance.restaurantSlug,
  'state': Conversation$Response._write_state(instance.state),
  'locale': Conversation$Response._write_locale(instance.locale),
  'order_type': Conversation$Response._write_orderType(instance.orderType),
  'ai_available': instance.aiAvailable,
  'expires_at': ?Conversation$Response._write_expiresAt(instance.expiresAt),
};
