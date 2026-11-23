// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat$Response _$Chat$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['conversation', 'messages'],
    disallowNullValues: const ['conversation', 'messages'],
  );
  return Chat$Response(
    conversation: Conversation$Response.fromJson(json['conversation'] as Map<String, dynamic>),
    messages: (json['messages'] as List<dynamic>)
        .map((e) => Message$Response.fromJson(e as Map<String, dynamic>))
        .toList(),
    additionalProperties: Chat$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : Chat$Response._readExtras(Chat$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$Chat$ResponseToJson(Chat$Response instance) => <String, dynamic>{
  'conversation': instance.conversation.toJson(),
  'messages': instance.messages.map((e) => e.toJson()).toList(),
};
