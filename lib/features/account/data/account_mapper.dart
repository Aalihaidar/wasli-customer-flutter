import 'package:wasli_customer/api/api.dart' as api;
import 'package:wasli_customer/features/account/domain/code_channel.dart';
import 'package:wasli_customer/features/account/domain/customer.dart';
import 'package:wasli_customer/features/account/domain/customer_language.dart';
import 'package:wasli_customer/features/account/domain/customer_session.dart';
import 'package:wasli_customer/features/account/domain/sent_code.dart';

/// Turns the generated profile into a [Customer].
Customer customerFromDto(api.CustomerProfile$Response dto) {
  return Customer(
    id: dto.id,
    fullName: dto.fullName,
    language: CustomerLanguage.fromCode(dto.locale.value),
    email: dto.email,
    emailVerified: dto.emailVerified,
    phone: dto.phone,
    phoneVerified: dto.phoneVerified,
  );
}

/// Turns the generated `verify` and `login` answer into a [CustomerSession].
CustomerSession customerSessionFromDto(api.Session$Response dto) {
  return CustomerSession(token: dto.token, customer: customerFromDto(dto.customer));
}

/// Turns the generated "a code was sent" answer into a [SentCode]. A channel the server adds later is [CodeChannel.unknown].
SentCode sentCodeFromDto(api.SentCode dto) {
  return SentCode(
    identifier: dto.identifier,
    channel: switch (dto.channel) {
      api.ChannelEnumKnown(value: api.ChannelEnumValue.email) => CodeChannel.email,
      api.ChannelEnumKnown(value: api.ChannelEnumValue.sms) => CodeChannel.sms,
      api.ChannelEnumUnknown() => CodeChannel.unknown,
    },
    expiresIn: Duration(seconds: dto.codeExpiresInSeconds),
    resendAvailableIn: Duration(seconds: dto.resendAvailableInSeconds),
  );
}
