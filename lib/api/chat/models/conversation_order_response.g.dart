// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationOrder$Response _$ConversationOrder$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['id', 'number', 'status'], disallowNullValues: const ['id', 'number']);
  return ConversationOrder$Response(
    id: json['id'] as String,
    number: ConversationOrder$Response._read_number(json['number']),
    status: ConversationOrder$Response._read_status(json['status']),
    additionalProperties: ConversationOrder$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : ConversationOrder$Response._readExtras(ConversationOrder$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ConversationOrder$ResponseToJson(ConversationOrder$Response instance) => <String, dynamic>{
  'id': instance.id,
  'number': ?ConversationOrder$Response._write_number(instance.number),
  'status': ConversationOrder$Response._write_status(instance.status),
};
