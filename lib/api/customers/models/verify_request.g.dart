// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyRequest _$VerifyRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['identifier', 'code'], disallowNullValues: const ['identifier', 'code']);
  return VerifyRequest(
    identifier: json['identifier'] as String,
    code: json['code'] as String,
    additionalProperties: VerifyRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : VerifyRequest._readExtras(VerifyRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$VerifyRequestToJson(VerifyRequest instance) => <String, dynamic>{
  'identifier': instance.identifier,
  'code': instance.code,
};
