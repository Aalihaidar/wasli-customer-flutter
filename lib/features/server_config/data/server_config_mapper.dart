import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/features/server_config/domain/server_config.dart';

/// Turns the generated `Config` answer into the app's [ServerConfig].
///
/// A rule or a language the server adds later is kept as `unknown` (rule) or as its raw code (language), never rejected.
ServerConfig serverConfigFromDto(Config dto) {
  return ServerConfig(
    locationCheck: switch (dto.locationCheck) {
      LocationCheckEnumKnown(value: LocationCheckEnumValue.off) => LocationCheck.off,
      LocationCheckEnumKnown(value: LocationCheckEnumValue.warn) => LocationCheck.warn,
      LocationCheckEnumKnown(value: LocationCheckEnumValue.enforce) => LocationCheck.enforce,
      LocationCheckEnumUnknown() => LocationCheck.unknown,
    },
    requireScreenOnline: dto.requireScreenOnline,
    aiEnabled: dto.aiEnabled,
    languages: [
      for (final language in dto.languages)
        switch (language) {
          LanguagesEnumKnown(:final value) => value.value,
          LanguagesEnumUnknown(:final rawValue) => rawValue,
        },
    ],
    pollInterval: Duration(seconds: dto.pollIntervalSeconds),
  );
}
