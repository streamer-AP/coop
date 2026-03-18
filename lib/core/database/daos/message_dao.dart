import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/message_tables.dart';

part 'message_dao.g.dart';

@DriftAccessor(tables: [Messages])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  Future<List<Message>> getAllMessages() {
    return (select(messages)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
  }

  Stream<List<Message>> watchAllMessages() {
    return (select(messages)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Future<void> markAsRead(int id) {
    return (update(messages)..where(
      (t) => t.id.equals(id),
    )).write(const MessagesCompanion(isRead: Value(true)));
  }

  Future<void> markAllAsRead() {
    return update(messages).write(const MessagesCompanion(isRead: Value(true)));
  }

  Future<List<Message>> getMessagesByServerIds(Iterable<int> serverIds) {
    final ids = serverIds.toSet().toList();
    if (ids.isEmpty) {
      return Future.value(const <Message>[]);
    }
    return (select(messages)..where((t) => t.serverId.isIn(ids))).get();
  }

  Future<void> updateMessage(int id, MessagesCompanion entry) {
    return (update(messages)..where((t) => t.id.equals(id))).write(entry);
  }

  Stream<int> watchUnreadCount() {
    final count = messages.id.count();
    final query =
        selectOnly(messages)
          ..addColumns([count])
          ..where(messages.isRead.equals(false));
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  Future<int> insertMessage(MessagesCompanion entry) {
    return into(messages).insert(entry);
  }
}
