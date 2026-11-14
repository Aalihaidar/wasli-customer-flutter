// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest$Request _$LoginRequest$RequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['identifier', 'password'],
    disallowNullValues: const ['identifier', 'password'],
  );
  return LoginRequest$Request(
    identifier: json['identifier'] as String,
    password: json['password'] as String,
    additionalProperties: LoginRequest$Request._extras(json, 'additionalProperties') == null
        ? const {}
        : LoginRequest$Request._readExtras(LoginRequest$Request._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$LoginRequest$RequestToJson(LoginRequest$Request instance) => <String, dynamic>{
  'identifier': instance.identifier,
  'password': instance.password,
};
