// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_sent.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordResetSent _$PasswordResetSentFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['code_expires_in_seconds'],
    disallowNullValues: const ['code_expires_in_seconds'],
  );
  return PasswordResetSent(
    codeExpiresInSeconds: PasswordResetSent._read_codeExpiresInSeconds(json['code_expires_in_seconds']),
    additionalProperties: PasswordResetSent._extras(json, 'additionalProperties') == null
        ? const {}
        : PasswordResetSent._readExtras(PasswordResetSent._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PasswordResetSentToJson(PasswordResetSent instance) => <String, dynamic>{
  'code_expires_in_seconds': ?PasswordResetSent._write_codeExpiresInSeconds(instance.codeExpiresInSeconds),
};
