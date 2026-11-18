// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session$Response _$Session$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const ['token', 'customer'], disallowNullValues: const ['token', 'customer']);
  return Session$Response(
    token: json['token'] as String,
    customer: CustomerProfile$Response.fromJson(json['customer'] as Map<String, dynamic>),
    additionalProperties: Session$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : Session$Response._readExtras(Session$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$Session$ResponseToJson(Session$Response instance) => <String, dynamic>{
  'token': instance.token,
  'customer': instance.customer.toJson(),
};
