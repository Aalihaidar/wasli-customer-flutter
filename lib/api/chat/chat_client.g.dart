// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_client.dart';

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: type=lint
// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _ChatClient extends ChatClient {
  _ChatClient._(this._dio, Dio _transport, {this.baseUrl, this.errorLogger})
    : super._(_transport);

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<void> conversationsLocationUpdate({
    Map<String, Object?> extra = const {
      "openapi.security": [
        {"customerAuth": []},
      ],
      "openapi.securitySchemes": {
        "customerAuth": {
          "type": "apiKey",
          "name": "Authorization",
          "in": "header",
          "description": "Customer token, sent as `Customer <token>`. It is returned once, when a sign-up is verified or a customer signs in.",
        },
      },
    },
    CancelToken? cancelToken,
    Options? options,
    required String id,
    required LocationRequest body,
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extra);
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Accept': 'application/json',
      r'Content-Type': 'application/json',
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<void>(
      Options(
            method: 'PUT',
            headers: _headers,
            extra: _extra,
            contentType: 'application/json',
          )
          .compose(
            _dio.options,
            '/api/v1/conversations/${id}/location',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    await _dio.fetch<void>(_options);
  }

  @override
  Future<Chat$Response> conversationsMessagesList({
    Map<String, Object?> extra = const {
      "openapi.security": [
        {"customerAuth": []},
      ],
      "openapi.securitySchemes": {
        "customerAuth": {
          "type": "apiKey",
          "name": "Authorization",
          "in": "header",
          "description": "Customer token, sent as `Customer <token>`. It is returned once, when a sign-up is verified or a customer signs in.",
        },
      },
    },
    CancelToken? cancelToken,
    Options? options,
    int? afterSeq,
    required String id,
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extra);
    final queryParameters = <String, dynamic>{r'after_seq': afterSeq};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Accept': 'application/json'};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<Chat$Response>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/api/v1/conversations/${id}/messages',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late Chat$Response _value;
    try {
      _value = Chat$Response.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<Chat$Response> conversationsMessagesCreate({
    Map<String, Object?> extra = const {
      "openapi.security": [
        {"customerAuth": []},
      ],
      "openapi.securitySchemes": {
        "customerAuth": {
          "type": "apiKey",
          "name": "Authorization",
          "in": "header",
          "description": "Customer token, sent as `Customer <token>`. It is returned once, when a sign-up is verified or a customer signs in.",
        },
      },
    },
    CancelToken? cancelToken,
    Options? options,
    required String id,
    required SendMessageRequest body,
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extra);
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{
      r'Accept': 'application/json',
      r'Content-Type': 'application/json',
    };
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(body.toJson());
    final _options = _setStreamType<Chat$Response>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'application/json',
          )
          .compose(
            _dio.options,
            '/api/v1/conversations/${id}/messages',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late Chat$Response _value;
    try {
      _value = Chat$Response.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<Chat$Response> conversationsVoiceCreate({
    Map<String, Object?> extra = const {
      "openapi.security": [
        {"customerAuth": []},
      ],
      "openapi.securitySchemes": {
        "customerAuth": {
          "type": "apiKey",
          "name": "Authorization",
          "in": "header",
          "description": "Customer token, sent as `Customer <token>`. It is returned once, when a sign-up is verified or a customer signs in.",
        },
      },
    },
    CancelToken? cancelToken,
    Options? options,
    required String id,
    required String clientMessageId,
    required MultipartFile audio,
  }) async {
    final _extra = <String, dynamic>{};
    _extra.addAll(extra);
    final queryParameters = <String, dynamic>{};
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{r'Accept': 'application/json'};
    _headers.removeWhere((k, v) => v == null);
    final _data = FormData();
    _data.fields.add(MapEntry('client_message_id', clientMessageId));
    _data.files.add(MapEntry('audio', audio));
    final _options = _setStreamType<Chat$Response>(
      Options(
            method: 'POST',
            headers: _headers,
            extra: _extra,
            contentType: 'multipart/form-data',
          )
          .compose(
            _dio.options,
            '/api/v1/conversations/${id}/voice',
            queryParameters: queryParameters,
            data: _data,
            cancelToken: cancelToken,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, Object?>>(_options);
    late Chat$Response _value;
    try {
      _value = Chat$Response.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
