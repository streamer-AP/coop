import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart' show appDatabaseProvider;
import '../../data/message_repository_impl.dart';
import '../../domain/models/message.dart';
import '../../domain/repositories/message_repository.dart';

part 'message_providers.g.dart';

@riverpod
MessageRepository messageRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return MessageRepositoryImpl(db.messageDao);
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
  FutureOr<void> build() {}

  Future<void> markAsRead(int id) async {
    await ref.read(messageRepositoryProvider).markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    await ref.read(messageRepositoryProvider).markAllAsRead();
  }
}
