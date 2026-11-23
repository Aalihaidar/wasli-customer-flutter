// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message$Response _$Message$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'seq',
      'sender',
      'kind',
      'text',
      'image_url',
      'transcript',
      'used_voice',
      'payload',
      'created_at',
    ],
    disallowNullValues: const ['id', 'seq', 'text', 'used_voice', 'created_at'],
  );
  return Message$Response(
    id: json['id'] as String,
    seq: Message$Response._read_seq(json['seq']),
    sender: Message$Response._read_sender(json['sender']),
    kind: Message$Response._read_kind(json['kind']),
    text: json['text'] as String,
    imageUrl: json['image_url'] as String?,
    transcript: json['transcript'] as String?,
    usedVoice: json['used_voice'] as bool,
    payload: json['payload'],
    createdAt: Message$Response._read_createdAt(json['created_at']),
    additionalProperties: Message$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : Message$Response._readExtras(Message$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$Message$ResponseToJson(Message$Response instance) => <String, dynamic>{
  'id': instance.id,
  'seq': ?Message$Response._write_seq(instance.seq),
  'sender': Message$Response._write_sender(instance.sender),
  'kind': Message$Response._write_kind(instance.kind),
  'text': instance.text,
  'image_url': instance.imageUrl,
  'transcript': instance.transcript,
  'used_voice': instance.usedVoice,
  'payload': instance.payload,
  'created_at': ?Message$Response._write_createdAt(instance.createdAt),
};
