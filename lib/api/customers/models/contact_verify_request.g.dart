// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_verify_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactVerifyRequest _$ContactVerifyRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['code'], disallowNullValues: const ['code']);
  return ContactVerifyRequest(
    code: json['code'] as String,
    additionalProperties: ContactVerifyRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : ContactVerifyRequest._readExtras(ContactVerifyRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ContactVerifyRequestToJson(ContactVerifyRequest instance) => <String, dynamic>{
  'code': instance.code,
};
