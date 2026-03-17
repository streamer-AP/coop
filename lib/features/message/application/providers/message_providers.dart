import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart' show appDatabaseProvider;
import '../../../../core/network/api_client.dart';
import '../../data/message_repository_impl.dart';
import '../../domain/models/message.dart';
import '../../domain/repositories/message_repository.dart';

part 'message_providers.g.dart';

@riverpod
MessageRepository messageRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final apiClient = ref.watch(apiClientProvider);
  return MessageRepositoryImpl(db.messageDao, apiClient);
}

@riverpod
Stream<List<Message>> watchMessages(Ref ref) {
  return ref.watch(messageRepositoryProvider).watchMessages();
}

@riverpod
Stream<int> unreadMessageCount(Ref ref) {
  return ref.watch(messageRepositoryProvider).watchUnreadCount();
}

@riverpod
class MessageNotifier extends _$MessageNotifier {
  @override
  FutureOr<void> build() async {
    await ref.read(messageRepositoryProvider).syncMessages();
  }

  Future<void> syncMessages() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(messageRepositoryProvider).syncMessages(),
    );
  }

  Future<void> markAsRead(int id) async {
    await ref.read(messageRepositoryProvider).markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await ref.read(messageRepositoryProvider).markAllAsRead();
  }
}
