// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resend_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResendRequest _$ResendRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['identifier'], disallowNullValues: const ['identifier']);
  return ResendRequest(
    identifier: json['identifier'] as String,
    additionalProperties: ResendRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : ResendRequest._readExtras(ResendRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ResendRequestToJson(ResendRequest instance) => <String, dynamic>{
  'identifier': instance.identifier,
};
