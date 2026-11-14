// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sent_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SentCode _$SentCodeFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['identifier', 'channel'],
    disallowNullValues: const ['identifier', 'channel', 'code_expires_in_seconds', 'resend_available_in_seconds'],
  );
  return SentCode(
    identifier: json['identifier'] as String,
    channel: SentCode._read_channel(json['channel']),
    codeExpiresInSeconds: SentCode._presentValue(json, 'code_expires_in_seconds') == null
        ? 600
        : SentCode._read_codeExpiresInSeconds(SentCode._presentValue(json, 'code_expires_in_seconds') as Object),
    resendAvailableInSeconds: SentCode._presentValue(json, 'resend_available_in_seconds') == null
        ? 60
        : SentCode._read_resendAvailableInSeconds(
            SentCode._presentValue(json, 'resend_available_in_seconds') as Object,
          ),
    additionalProperties: SentCode._extras(json, 'additionalProperties') == null
        ? const {}
        : SentCode._readExtras(SentCode._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SentCodeToJson(SentCode instance) => <String, dynamic>{
  'identifier': instance.identifier,
  'channel': ?SentCode._write_channel(instance.channel),
  'code_expires_in_seconds': ?SentCode._write_codeExpiresInSeconds(instance.codeExpiresInSeconds),
  'resend_available_in_seconds': ?SentCode._write_resendAvailableInSeconds(instance.resendAvailableInSeconds),
};
