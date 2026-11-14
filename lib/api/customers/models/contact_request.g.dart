// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactRequest _$ContactRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['email', 'phone']);
  return ContactRequest(
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    additionalProperties: ContactRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : ContactRequest._readExtras(ContactRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$ContactRequestToJson(ContactRequest instance) => <String, dynamic>{
  'email': ?instance.email,
  'phone': ?instance.phone,
};
