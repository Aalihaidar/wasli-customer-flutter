// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_request_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupRequest$Request _$SignupRequest$RequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['full_name', 'password', 'locale'],
    disallowNullValues: const ['full_name', 'email', 'phone', 'password', 'locale'],
  );
  return SignupRequest$Request(
    fullName: json['full_name'] as String,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    password: json['password'] as String,
    locale: SignupRequest$Request._read_locale(json['locale']),
    additionalProperties: SignupRequest$Request._extras(json, 'additionalProperties') == null
        ? const {}
        : SignupRequest$Request._readExtras(SignupRequest$Request._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$SignupRequest$RequestToJson(SignupRequest$Request instance) => <String, dynamic>{
  'full_name': instance.fullName,
  'email': ?instance.email,
  'phone': ?instance.phone,
  'password': instance.password,
  'locale': ?SignupRequest$Request._write_locale(instance.locale),
};
