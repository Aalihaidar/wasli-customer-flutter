// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order$Response _$Order$ResponseFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'id',
      'number',
      'status',
      'order_type',
      'placed_at',
      'eta_minutes',
      'rejection_reason_code',
      'rejection_note',
      'subtotal_minor',
      'total_minor',
      'currency',
    ],
    disallowNullValues: const ['id', 'number', 'placed_at', 'subtotal_minor', 'total_minor', 'currency'],
  );
  return Order$Response(
    id: json['id'] as String,
    number: Order$Response._read_number(json['number']),
    status: Order$Response._read_status(json['status']),
    orderType: Order$Response._read_orderType(json['order_type']),
    placedAt: Order$Response._read_placedAt(json['placed_at']),
    etaMinutes: Order$Response._read_etaMinutes(json['eta_minutes']),
    rejectionReasonCode: json['rejection_reason_code'] as String?,
    rejectionNote: json['rejection_note'] as String?,
    subtotalMinor: Order$Response._read_subtotalMinor(json['subtotal_minor']),
    totalMinor: Order$Response._read_totalMinor(json['total_minor']),
    currency: json['currency'] as String,
    additionalProperties: Order$Response._extras(json, 'additionalProperties') == null
        ? const {}
        : Order$Response._readExtras(Order$Response._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$Order$ResponseToJson(Order$Response instance) => <String, dynamic>{
  'id': instance.id,
  'number': ?Order$Response._write_number(instance.number),
  'status': Order$Response._write_status(instance.status),
  'order_type': Order$Response._write_orderType(instance.orderType),
  'placed_at': ?Order$Response._write_placedAt(instance.placedAt),
  'eta_minutes': Order$Response._write_etaMinutes(instance.etaMinutes),
  'rejection_reason_code': instance.rejectionReasonCode,
  'rejection_note': instance.rejectionNote,
  'subtotal_minor': ?Order$Response._write_subtotalMinor(instance.subtotalMinor),
  'total_minor': ?Order$Response._write_totalMinor(instance.totalMinor),
  'currency': instance.currency,
};
