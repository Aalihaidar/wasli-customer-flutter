// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordResetRequest _$PasswordResetRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['identifier'], disallowNullValues: const ['identifier']);
  return PasswordResetRequest(
    identifier: json['identifier'] as String,
    additionalProperties: PasswordResetRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : PasswordResetRequest._readExtras(PasswordResetRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PasswordResetRequestToJson(PasswordResetRequest instance) => <String, dynamic>{
  'identifier': instance.identifier,
};
