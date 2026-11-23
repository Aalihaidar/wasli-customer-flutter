// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picked_line_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickedLineRequest _$PickedLineRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const ['item_id', 'quantity'],
    disallowNullValues: const ['item_id', 'quantity', 'option_ids', 'note'],
  );
  return PickedLineRequest(
    itemId: json['item_id'] as String,
    quantity: PickedLineRequest._read_quantity(json['quantity']),
    optionIds: (json['option_ids'] as List<dynamic>?)?.map((e) => e as String).toList(),
    note: json['note'] as String?,
    additionalProperties: PickedLineRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : PickedLineRequest._readExtras(PickedLineRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$PickedLineRequestToJson(PickedLineRequest instance) => <String, dynamic>{
  'item_id': instance.itemId,
  'quantity': ?PickedLineRequest._write_quantity(instance.quantity),
  'option_ids': ?instance.optionIds,
  'note': ?instance.note,
};
