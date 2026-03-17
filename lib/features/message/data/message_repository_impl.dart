import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart' as db;
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/database/daos/message_dao.dart';
import '../domain/models/message.dart' as domain;
import '../domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageDao _dao;
  final ApiClient _apiClient;

  MessageRepositoryImpl(this._dao, this._apiClient);

  @override
  Future<List<domain.Message>> getMessages() async {
    final rows = await _dao.getAllMessages();
    return rows.map(_toDomain).toList();
  }

  @override
  Stream<List<domain.Message>> watchMessages() {
    return _dao.watchAllMessages().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<void> syncMessages({DateTime? planSendTime}) async {
    final requestTime = planSendTime ?? DateTime.now();
    try {
      final json = await _fetchMessageBatch(requestTime, planSendTime);

      final data = json['data'];
      final payload = _resolveDataList(data);
      if (payload == null) {
        return;
      }

      final remoteById = <int, _RemoteMessage>{};
      for (final item in payload) {
        final remote = _parseRemoteMessage(item, fallbackTime: requestTime);
        if (remote != null) {
          remoteById[remote.serverId] = remote;
        }
      }

      if (remoteById.isEmpty) {
        return;
      }

      final existingRows = await _dao.getMessagesByServerIds(remoteById.keys);
      final existingByServerId = {
        for (final row in existingRows)
          if (row.serverId != null) row.serverId!: row,
      };

      for (final remote in remoteById.values) {
        final existing = existingByServerId[remote.serverId];
        if (existing == null) {
          await _dao.insertMessage(
            db.MessagesCompanion.insert(
              serverId: Value(remote.serverId),
              title: remote.title,
              body: remote.body,
              createdAt: Value(remote.createdAt),
              isRead: const Value(false),
            ),
          );
          continue;
        }

        await _dao.updateMessage(
          existing.id,
          db.MessagesCompanion(
            serverId: Value(remote.serverId),
            title: Value(remote.title),
            body: Value(remote.body),
            createdAt: Value(remote.createdAt),
          ),
        );
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        throw Exception(_errorMessage(responseData['message']));
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('系统消息拉取失败，请检查网络后重试');
      }

      throw Exception(_errorMessage(e.message));
    }
  }

  Future<Map<String, dynamic>> _fetchMessageBatch(
    DateTime requestTime,
    DateTime? planSendTime,
  ) async {
    final formattedRequestTime = _planSendTimeFormat.format(requestTime);
    final attempts = <Map<String, dynamic>>[
      {'planSendTime': ''},
      {'planSendTime': formattedRequestTime},
      {'planSendTime': requestTime.toIso8601String()},
    ];

    if (planSendTime != null) {
      attempts.insert(0, {
        'planSendTime': _planSendTimeFormat.format(planSendTime),
      });
    }

    final seen = <String>{};
    Exception? lastException;

    for (final query in attempts) {
      final signature = query.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');
      if (!seen.add(signature)) {
        continue;
      }

      try {
        final json = await _apiClient.get(
          ApiEndpoints.messages,
          queryParameters: query,
        );
        if (_isSuccessCode(json['code'])) {
          return json;
        }
        lastException = Exception(_errorMessage(json['message']));
      } on DioException catch (e) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          lastException = Exception(_errorMessage(responseData['message']));
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          lastException = Exception('系统消息拉取失败，请检查网络后重试');
        } else {
          lastException = Exception(_errorMessage(e.message));
        }
      }
    }

    if (lastException != null) {
      throw lastException;
    }
    throw Exception('系统消息拉取失败');
  }

  bool _isSuccessCode(dynamic code) {
    final numeric = _toInt(code);
    return numeric == 0 || numeric == 200;
  }

  @override
  Future<void> markAsRead(int id) => _dao.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _dao.markAllAsRead();

  @override
  Stream<int> watchUnreadCount() => _dao.watchUnreadCount();

  domain.Message _toDomain(db.Message row) {
    return domain.Message(
      id: row.id,
      title: row.title,
      body: row.body,
      createdAt: row.createdAt,
      isRead: row.isRead,
    );
  }

  _RemoteMessage? _parseRemoteMessage(
    dynamic raw, {
    required DateTime fallbackTime,
  }) {
    if (raw is! Map) {
      return null;
    }

    final json = Map<String, dynamic>.from(raw);
    final serverId = _toInt(json['id']);
    if (serverId == null) {
      return null;
    }

    final title = _normalizedText(json['title']) ?? '系统消息';
    final body = _normalizedText(json['content']) ?? '';
    final createdAt =
        _parseDate(json['createdAt']) ??
        _parseDate(json['planSendTime']) ??
        _parseDate(json['updatedAt']) ??
        fallbackTime;

    return _RemoteMessage(
      serverId: serverId,
      title: title,
      body: body,
      createdAt: createdAt,
    );
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse('${value ?? ''}'.trim());
  }

  String? _normalizedText(dynamic value) {
    final text = '${value ?? ''}'.trim();
    if (text.isEmpty) {
      return null;
    }
    return text;
  }

  DateTime? _parseDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is int) {
      if (value <= 0) {
        return null;
      }
      final milliseconds = value > 1000000000000 ? value : value * 1000;
      return DateTime.fromMillisecondsSinceEpoch(milliseconds);
    }

    final raw = '${value ?? ''}'.trim();
    if (raw.isEmpty) {
      return null;
    }

    return DateTime.tryParse(raw) ??
        DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  }

  String _errorMessage(dynamic value) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? '系统消息拉取失败' : text;
  }

  List<dynamic>? _resolveDataList(dynamic data) {
    if (data is List) {
      return data;
    }
    if (data is Map<String, dynamic>) {
      final records = data['records'];
      if (records is List) return records;
      final list = data['list'];
      if (list is List) return list;
      final items = data['items'];
      if (items is List) return items;
    }
    return null;
  }

  static final DateFormat _planSendTimeFormat = DateFormat(
    'yyyy-MM-dd HH:mm:ss',
  );
}

class _RemoteMessage {
  const _RemoteMessage({
    required this.serverId,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final int serverId;
  final String title;
  final String body;
  final DateTime createdAt;
}
