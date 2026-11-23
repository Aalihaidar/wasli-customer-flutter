// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_conversation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenConversationRequest _$OpenConversationRequestFromJson(Map<String, dynamic> json) {
  $checkKeys(json, disallowNullValues: const ['locale', 'start_new']);
  return OpenConversationRequest(
    locale: OpenConversationRequest._read_locale(json['locale']),
    startNew: OpenConversationRequest._presentValue(json, 'start_new') == null
        ? false
        : OpenConversationRequest._read_startNew(OpenConversationRequest._presentValue(json, 'start_new') as Object),
    orderType: OpenConversationRequest._presentValue(json, 'order_type') == null
        ? const OrderTypeEnum("car")
        : OpenConversationRequest._read_orderType(OpenConversationRequest._presentValue(json, 'order_type') as Object),
    additionalProperties: OpenConversationRequest._extras(json, 'additionalProperties') == null
        ? const {}
        : OpenConversationRequest._readExtras(OpenConversationRequest._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$OpenConversationRequestToJson(OpenConversationRequest instance) => <String, dynamic>{
  'locale': ?OpenConversationRequest._write_locale(instance.locale),
  'start_new': ?OpenConversationRequest._write_startNew(instance.startNew),
  'order_type': OpenConversationRequest._write_orderType(instance.orderType),
};
