import 'package:wasli_customer/core/error/api_issue.dart';

/// Reads the backend's one error body: `{"type": ..., "errors": [{"code", "detail", "attr"}]}`.
///
/// Returns the issues in order, or `null` when [data] is not that body (a proxy page, Django's own page, an empty
/// body, a body without a usable `errors` list). Entries without a text `code` are skipped. The body's `type` is not
/// needed: the HTTP status and the codes decide.
List<ApiIssue>? parseErrorBody(Object? data) {
  if (data is! Map<Object?, Object?>) {
    return null;
  }
  final errors = data['errors'];
  if (errors is! List<Object?>) {
    return null;
  }

  final issues = <ApiIssue>[];
  for (final entry in errors) {
    if (entry is! Map<Object?, Object?>) {
      continue;
    }
    final code = entry['code'];
    if (code is! String || code.isEmpty) {
      continue;
    }
    final attr = entry['attr'];
    issues.add(ApiIssue(code: code, attr: attr is String ? attr : null));
  }
  return issues.isEmpty ? null : issues;
}
