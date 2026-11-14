// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerProfile$Response _$CustomerProfile$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['id', 'full_name', 'locale', 'email', 'email_verified', 'phone', 'phone_verified'],
    disallowNullValues: const ['id', 'full_name', 'email_verified', 'phone_verified'],
  );
  return CustomerProfile$Response(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    locale: CustomerProfile$Response._read_locale(json['locale']),
    email: json['email'] as String?,
    emailVerified: json['email_verified'] as bool,
    phone: json['phone'] as String?,
    phoneVerified: json['phone_verified'] as bool,
    additionalProperties: CustomerProfile$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : CustomerProfile$Response._readExtras(CustomerProfile$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$CustomerProfile$ResponseToJson(CustomerProfile$Response instance) => <String, dynamic>{
  'id': instance.id,
  'full_name': instance.fullName,
  'locale': CustomerProfile$Response._write_locale(instance.locale),
  'email': instance.email,
  'email_verified': instance.emailVerified,
  'phone': instance.phone,
  'phone_verified': instance.phoneVerified,
};
