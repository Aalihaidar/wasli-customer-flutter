// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_confirm_request_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordResetConfirmRequest$Request _$PasswordResetConfirmRequest$RequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['identifier', 'code', 'new_password'],
    disallowNullValues: const ['identifier', 'code', 'new_password'],
  );
  return PasswordResetConfirmRequest$Request(
    identifier: json['identifier'] as String,
    code: json['code'] as String,
    newPassword: json['new_password'] as String,
    additionalProperties: PasswordResetConfirmRequest$Request._extras(json, 'additionalProperties') == null
        ? const {}
        : PasswordResetConfirmRequest$Request._readExtras(
            PasswordResetConfirmRequest$Request._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$PasswordResetConfirmRequest$RequestToJson(PasswordResetConfirmRequest$Request instance) =>
    <String, dynamic>{'identifier': instance.identifier, 'code': instance.code, 'new_password': instance.newPassword};
