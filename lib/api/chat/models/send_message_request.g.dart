// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['client_message_id'],
    disallowNullValues: const ['client_message_id', 'text', 'action', 'field', 'value', 'lines', 'locale'],
  );
  return SendMessageRequest(
    clientMessageId: json['client_message_id'] as String,
    text: json['text'] as String?,
    action: SendMessageRequest._read_action(json['action']),
    field: SendMessageRequest._read_field(json['field']),
    value: json['value'] as String?,
    lines: (json['lines'] as List<dynamic>?)
        ?.map((e) => PickedLineRequest.fromJson(e as Map<String, dynamic>))
        .toList(),
    locale: SendMessageRequest._read_locale(json['locale']),
    additionalProperties: SendMessageRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : SendMessageRequest._readExtras(SendMessageRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SendMessageRequestToJson(SendMessageRequest instance) => <String, dynamic>{
  'client_message_id': instance.clientMessageId,
  'text': ?instance.text,
  'action': ?SendMessageRequest._write_action(instance.action),
  'field': ?SendMessageRequest._write_field(instance.field),
  'value': ?instance.value,
  'lines': ?instance.lines?.map((e) => e.toJson()).toList(),
  'locale': ?SendMessageRequest._write_locale(instance.locale),
};
