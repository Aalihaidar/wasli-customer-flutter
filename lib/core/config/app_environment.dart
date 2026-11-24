import 'package:flutter/services.dart' show appFlavor;
import 'package:wasli_customer/core/config/app_config_exception.dart';
import 'package:wasli_customer/core/config/app_stage.dart';

/// The build-time configuration of the app: the stage and the public URLs.
///
/// It is the only place that reads `APP_ENV`, the flavor and the `--dart-define` values; nothing else looks at flavor
/// names. All values are public (they are compiled into a web app): no secret ever belongs here.
class AppEnvironment {
  const new _({required this.stage, required this.apiBaseUrl, required this.apiOrigin, required this.customerSiteUrl});

  /// Reads the values this build was compiled with.
  ///
  /// Throws [AppConfigException] when `API_BASE_URL` is missing or a URL is invalid.
  factory fromBuild() => AppEnvironment.parse(
    appEnv: const String.fromEnvironment('APP_ENV'),
    // Without defines the analyzer reads `appFlavor` as the constant null, the parameter default, and calls the
    // argument redundant. A real build sets it.
    // ignore: avoid_redundant_argument_values
    flavor: appFlavor,
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
    customerSiteUrl: const String.fromEnvironment('CUSTOMER_SITE_URL'),
  );

  /// Validates raw build-time values and builds the environment.
  ///
  /// [apiBaseUrl] is required. [customerSiteUrl] is optional; an empty value means "not set". Every URL must be an
  /// absolute `http` or `https` address without a query, a fragment or credentials, and the production stage accepts
  /// `https` only. Trailing slashes are dropped, because the API paths are joined to the base without one. The
  /// [apiBaseUrl] must end with `/api/v1`: the generated client's paths already start with it (see [apiOrigin]).
  ///
  /// Throws [AppConfigException] on the first value that is wrong.
  factory parse({required String apiBaseUrl, String? appEnv, String? flavor, String? customerSiteUrl}) {
    final stage = AppStage.resolve(appEnv: appEnv, flavor: flavor);
    final api = _parseUrl('API_BASE_URL', apiBaseUrl, stage);
    if (api == null) {
      throw const AppConfigException('API_BASE_URL is not set.');
    }
    return AppEnvironment._(
      stage: stage,
      apiBaseUrl: api,
      apiOrigin: _originOf(api),
      customerSiteUrl: _parseUrl('CUSTOMER_SITE_URL', customerSiteUrl, stage),
    );
  }

  /// The stage this build targets.
  final AppStage stage;

  /// The API base URL, for example `https://host/api/v1`, without a trailing slash.
  final Uri apiBaseUrl;

  /// The API base URL without its `/api/v1` ending, for example `https://host`.
  ///
  /// This is what the HTTP client uses as its base: every path of the generated client starts with `/api/v1`, so joining
  /// them to [apiBaseUrl] would repeat it.
  final Uri apiOrigin;

  /// The public origin of this web app, used for links and QR targets (`/r/<slug>`). `null` when not set.
  final Uri? customerSiteUrl;

  /// Whether this is the production stage.
  bool get isProduction => stage == AppStage.production;

  static Uri _originOf(Uri apiBaseUrl) {
    const suffix = '/api/v1';
    final path = apiBaseUrl.path;
    if (!path.endsWith(suffix)) {
      throw const AppConfigException('API_BASE_URL must end with /api/v1.');
    }
    return apiBaseUrl.replace(path: path.substring(0, path.length - suffix.length));
  }

  static Uri? _parseUrl(String name, String? raw, AppStage stage) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(value);
    final scheme = uri?.scheme;
    if (uri == null || !uri.isAbsolute || uri.host.isEmpty || (scheme != 'http' && scheme != 'https')) {
      throw AppConfigException('$name must be an absolute http or https URL.');
    }
    if (uri.hasQuery || uri.hasFragment || uri.userInfo.isNotEmpty) {
      throw AppConfigException('$name must not contain a query, a fragment or credentials.');
    }
    if (stage == AppStage.production && scheme != 'https') {
      throw AppConfigException('$name must use https in production.');
    }
    final path = uri.path.replaceFirst(RegExp(r'/+$'), '');
    return uri.replace(path: path);
  }
}
