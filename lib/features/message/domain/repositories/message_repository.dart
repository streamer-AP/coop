import '../models/message.dart';

abstract class MessageRepository {
  Future<List<Message>> getMessages();
  Stream<List<Message>> watchMessages();
  Future<void> markAsRead(int id);
  Future<void> markAllAsRead();
  Stream<int> watchUnreadCount();
}
