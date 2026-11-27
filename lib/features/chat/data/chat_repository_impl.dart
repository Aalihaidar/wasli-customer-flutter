import 'package:dio/dio.dart';
import 'package:wasli_customer/api/api.dart';
import 'package:wasli_customer/core/network/run_api.dart';
import 'package:wasli_customer/features/chat/data/chat_mapper.dart';
import 'package:wasli_customer/features/chat/domain/chat_action.dart';
import 'package:wasli_customer/features/chat/domain/chat_repository.dart';
import 'package:wasli_customer/features/chat/domain/chat_snapshot.dart';
import 'package:wasli_customer/features/chat/domain/shared_position.dart';

/// Talks to the conversation endpoints through the generated `ChatClient`.
///
/// Every call needs the customer's token; the network layer adds it because the generated client says so. A position
/// travels only in the body of `shareLocation` and is never logged.
class ChatRepositoryImpl implements ChatRepository {
  /// Creates the repository over the generated client.
  const new(this._client);

  /// Creates the repository over the app's HTTP client, building the generated client here, because only `data/`
  /// imports `lib/api`.
  factory fromDio(Dio dio) => ChatRepositoryImpl(ChatClient(dio));

  final ChatClient _client;

  @override
  Future<ChatSnapshot> open(String slug, {required String languageCode, bool startNew = false}) async {
    final body = OpenConversationRequest(
      locale: languageCode == 'ar' ? LocaleEnum.ar : LocaleEnum.en,
      startNew: startNew,
    );
    final dto = await runApi(() async {
      try {
        return await _client.restaurantsConversationsCreate(slug: slug, body: body);
      } on DioException catch (error) {
        // The server answers `201` for a conversation it just made and `200` for an existing one, but the generated
        // method accepts only `200` (it cannot be edited), so the `201` arrives as an error that still carries the
        // whole answer. Read it here and let every other failure through.
        final response = error.response;
        final data = response?.data;
        if (response?.statusCode == 201 && data is Map<String, Object?>) {
          return Chat$Response.fromJson(data);
        }
        rethrow;
      }
    });
    return chatSnapshotFromDto(dto);
  }

  @override
  Future<ChatSnapshot> messagesAfter(String conversationId, int afterSeq) async {
    final dto = await runApi(() => _client.conversationsMessagesList(id: conversationId, afterSeq: afterSeq));
    return chatSnapshotFromDto(dto);
  }

  @override
  Future<ChatSnapshot> sendText(String conversationId, {required String clientMessageId, required String text}) async {
    final dto = await runApi(
      () => _client.conversationsMessagesCreate(
        id: conversationId,
        body: SendMessageRequest(clientMessageId: clientMessageId, text: text),
      ),
    );
    return chatSnapshotFromDto(dto);
  }

  @override
  Future<ChatSnapshot> sendAction(
    String conversationId, {
    required String clientMessageId,
    required ChatAction action,
  }) async {
    final dto = await runApi(
      () => _client.conversationsMessagesCreate(id: conversationId, body: sendActionRequest(clientMessageId, action)),
    );
    return chatSnapshotFromDto(dto);
  }

  @override
  Future<void> shareLocation(String conversationId, SharedPosition position) {
    return runApi(
      () => _client.conversationsLocationUpdate(
        id: conversationId,
        body: LocationRequest(
          lat: position.latitude,
          lng: position.longitude,
          accuracyM: position.accuracyMetres,
          source: position.simulated ? SourceEnum.simulated : SourceEnum.gps,
        ),
      ),
    );
  }
}
