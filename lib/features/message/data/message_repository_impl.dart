import '../../../core/database/daos/message_dao.dart';
import '../domain/models/message.dart' as domain;
import '../domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageDao _dao;

  MessageRepositoryImpl(this._dao);

  @override
  Future<List<domain.Message>> getMessages() async {
    final rows = await _dao.getAllMessages();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<domain.Message>> watchMessages() {
    return _dao.watchAllMessages().map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }

  @override
  Future<void> markAsRead(int id) => _dao.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _dao.markAllAsRead();

  @override
  Stream<int> watchUnreadCount() => _dao.watchUnreadCount();

  domain.Message _toDomain(dynamic row) {
    return domain.Message(
      id: row.id as int,
      title: row.title as String,
      body: row.body as String,
      createdAt: row.createdAt as DateTime,
      isRead: row.isRead as bool,
    );
  }
}
