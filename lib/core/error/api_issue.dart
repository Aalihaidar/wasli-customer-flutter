import 'package:wasli_customer/core/error/api_error_code.dart';

/// One entry of the `errors` list of the backend's error body.
///
/// The server's `detail` text is not kept: the app decides what to say from [code], in the customer's language, and
/// never shows server text.
final class ApiIssue {
  /// Creates an issue with the raw [code] and the field it is about ([attr], `null` for the request as a whole).
  const new({required this.code, this.attr});

  /// The code exactly as the server wrote it.
  final String code;

  /// The field the issue is about, dotted when nested, or `null`.
  final String? attr;

  /// [code] as a known code, or [ApiErrorCode.unknown].
  ApiErrorCode get known => ApiErrorCode.fromWire(code);

  /// Whether this is one of the password validator codes (`password_too_short`, `password_too_common`, ...).
  ///
  /// Those codes are many and open, so they are matched by their prefix.
  bool get isPasswordRule => code.startsWith('password_');
}
