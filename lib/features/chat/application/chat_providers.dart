import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:wasli_customer/core/network/network_providers.dart';
import 'package:wasli_customer/features/chat/data/chat_repository_impl.dart';
import 'package:wasli_customer/features/chat/domain/chat_repository.dart';

/// The repository that talks to the conversation endpoints. Tests replace it with a fake.
final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepositoryImpl.fromDio(ref.watch(dioProvider)));

/// Makes the id of a message (a UUID v4), once per user action. Tests replace it to get known ids.
final messageIdProvider = Provider<String Function()>((ref) {
  const uuid = Uuid();
  return uuid.v4;
});
