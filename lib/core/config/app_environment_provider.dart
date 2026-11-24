import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wasli_customer/core/config/app_environment.dart';

/// The build-time configuration, read once at start-up.
///
/// The start-up code overrides it with [AppEnvironment.fromBuild]; reading it without an override is a programming
/// error, so there is no default that could point a build at the wrong server.
final appEnvironmentProvider = Provider<AppEnvironment>(
  (ref) => throw StateError('appEnvironmentProvider must be overridden at start-up.'),
);
