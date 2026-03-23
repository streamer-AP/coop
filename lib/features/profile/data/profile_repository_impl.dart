import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/app_version.dart';
import '../domain/models/profile.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  final String _avatarDirectory;

  ProfileRepositoryImpl(this._apiClient, {required String avatarDirectory})
    : _tokenStorage = TokenStorage(),
      _avatarDirectory = avatarDirectory;

  @override
  Future<Profile> getProfile() async {
    Profile profile = _emptyProfile();
    try {
      final json = await _apiClient.get(ApiEndpoints.getCurrentUserInfo);
      final code = json['code'] as int?;
      final data = json['data'] as Map<String, dynamic>?;

      if (code == 200 && data != null) {
        final residentStatus = '${data['residentStatus'] ?? '0'}';
        final phone = data['mobile'] as String? ?? '';
        final userId = _extractUserId(data);
        final nickname = _normalizeOptionalString(data['userName']);
        profile = Profile(
          userId: userId,
          nickname: nickname,
          avatarUrl:
              data['avatarUrl'] as String? ??
              data['avatar'] as String? ??
              data['headImage'] as String?,
          phone: _maskPhone(phone),
          isVerified: residentStatus == '1',
          avatarPreset: 'flower',
        );
        await _persistCurrentUserId(userId);
      }
    } catch (_) {}

    final cachedUserId = await _resolveCurrentUserId();
    final effectiveUserId =
        profile.userId.trim().isNotEmpty ? profile.userId.trim() : cachedUserId;
    if (effectiveUserId.isNotEmpty && profile.userId != effectiveUserId) {
      profile = profile.copyWith(userId: effectiveUserId);
    }

    // 读取用户目录下的本地头像
    final localAvatar = await _findLocalAvatar();
    if (localAvatar != null && await File(localAvatar).exists()) {
      profile = profile.copyWith(avatarUrl: localAvatar);
    }

    return profile;
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    // TODO: implement
  }

  @override
  Future<void> updateNickname(String nickname) async {
    final value = nickname.trim();
    if (value.isEmpty) {
      throw Exception('用户名不能为空');
    }

    Object? firstError;
    try {
      await _submitNicknameUpdate(value, mode: _NicknameUpdateMode.body);
      return;
    } catch (error) {
      firstError = error;
    }

    try {
      await _submitNicknameUpdate(value, mode: _NicknameUpdateMode.query);
      return;
    } catch (secondError) {
      try {
        await _submitNicknameUpdate(
          value,
          mode: _NicknameUpdateMode.bodyAndQuery,
        );
        return;
      } catch (thirdError) {
        throw _preferNicknameUpdateError(firstError, secondError, thirdError);
      }
    }
  }

  @override
  Future<void> updateAvatar(String avatarUrl) async {
    final value = avatarUrl.trim();
    if (value.isEmpty) {
      throw Exception('头像地址为空');
    }

    final localFile = _resolveLocalFile(value);
    if (localFile == null || !await localFile.exists()) {
      throw Exception('头像文件不存在');
    }

    // 确保头像目录存在
    final avatarDir = Directory(_avatarDirectory);
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }

    final ext = p.extension(localFile.path);
    final destPath = p.join(_avatarDirectory, 'avatar$ext');

    // 删除旧头像
    final previousAvatar = await _findLocalAvatar();
    if (previousAvatar != null && previousAvatar != destPath) {
      await _deleteFileIfExists(previousAvatar);
    }

    final destFile = File(destPath);
    if (await destFile.exists()) {
      await destFile.delete();
    }

    await localFile.copy(destPath);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    // TODO: implement
  }

  @override
  Future<void> changePasswordByCode({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    // TODO: implement
  }

  @override
  Future<void> changePhone({
    required String oldPhone,
    required String oldCode,
    required String newPhone,
    required String newCode,
  }) async {
    // TODO: implement
  }

  @override
  Future<void> submitFeedback(String content) async {
    // TODO: implement
  }

  @override
  Future<AppVersion> checkForUpdate() async {
    // TODO: implement
    return const AppVersion(version: '1.2.96');
  }

  @override
  Future<void> deactivateAccount({
    required String phone,
    required String code,
  }) async {
    // TODO: implement
  }

  String _maskPhone(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }

  /// 在用户头像目录中查找 avatar.* 文件。
  Future<String?> _findLocalAvatar() async {
    final avatarDir = Directory(_avatarDirectory);
    if (!await avatarDir.exists()) return null;

    await for (final entity in avatarDir.list()) {
      if (entity is File) {
        final basename = p.basenameWithoutExtension(entity.path);
        if (basename == 'avatar') {
          return entity.path;
        }
      }
    }
    return null;
  }

  File? _resolveLocalFile(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return null;
    }
    if (value.startsWith('file://')) {
      final uri = Uri.tryParse(value);
      if (uri == null) return null;
      final filePath = uri.toFilePath();
      return File(filePath);
    }
    return File(value);
  }

  Profile _emptyProfile() {
    return const Profile(
      userId: '',
      nickname: null,
      phone: '',
      avatarPreset: 'flower',
    );
  }

  String _extractUserId(Map<String, dynamic> data) {
    final raw = data['id'] ?? data['userId'] ?? data['loginId'];
    if (raw == null) return '';
    return '$raw'.trim();
  }

  String? _normalizeOptionalString(Object? value) {
    final normalized = '$value'.trim();
    if (value == null || normalized.isEmpty || normalized == 'null') {
      return null;
    }
    return normalized;
  }

  Future<void> _submitNicknameUpdate(
    String value, {
    required _NicknameUpdateMode mode,
  }) async {
    final useBody =
        mode == _NicknameUpdateMode.body ||
        mode == _NicknameUpdateMode.bodyAndQuery;
    final useQuery =
        mode == _NicknameUpdateMode.query ||
        mode == _NicknameUpdateMode.bodyAndQuery;

    final json = await _apiClient.post(
      ApiEndpoints.updateNickname,
      data: useBody ? {'userName': value} : null,
      queryParameters: useQuery ? {'userName': value} : null,
    );
    final code = json['code'] as int?;
    if (code == 200 || code == 0) {
      return;
    }

    throw Exception(
      json['message'] as String? ?? json['msg'] as String? ?? '用户名更新失败',
    );
  }

  Exception _preferNicknameUpdateError(
    Object? firstError,
    Object? secondError,
    Object? thirdError,
  ) {
    final messages =
        [
          _extractNicknameUpdateMessage(firstError),
          _extractNicknameUpdateMessage(secondError),
          _extractNicknameUpdateMessage(thirdError),
        ].where((message) => message.isNotEmpty).toList();

    if (messages.isEmpty) {
      return Exception('用户名更新失败');
    }

    final specificMessage = messages.cast<String?>().firstWhere(
      (message) => !_isGenericNicknameUpdateMessage(message!),
      orElse: () => null,
    );

    return Exception(specificMessage ?? messages.last);
  }

  String _extractNicknameUpdateMessage(Object? error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['msg'] ?? data['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
      if (error.message?.trim().isNotEmpty ?? false) {
        return error.message!.trim();
      }
    }

    final raw = '$error'.replaceFirst('Exception: ', '').trim();
    if (raw == 'null') {
      return '';
    }
    return raw;
  }

  bool _isGenericNicknameUpdateMessage(String message) {
    return message.isEmpty ||
        message.contains('系统异常') ||
        message.contains('请求失败') ||
        message.contains('Internal Server Error') ||
        message.contains('500');
  }

  Future<void> _persistCurrentUserId(String userId) async {
    if (userId.trim().isEmpty) return;
    await _tokenStorage.saveCurrentUserId(userId);
  }

  Future<String> _resolveCurrentUserId() async {
    final cachedUserId = (await _tokenStorage.getCurrentUserId())?.trim() ?? '';
    if (cachedUserId.isNotEmpty) {
      return cachedUserId;
    }

    try {
      final json = await _apiClient.get(ApiEndpoints.getCurrentUserInfo);
      final code = json['code'] as int?;
      final data = json['data'] as Map<String, dynamic>?;
      if (code == 200 && data != null) {
        final userId = _extractUserId(data);
        if (userId.isNotEmpty) {
          await _persistCurrentUserId(userId);
          return userId;
        }
      }
    } catch (_) {}

    return '';
  }

  Future<void> _deleteFileIfExists(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

enum _NicknameUpdateMode { body, query, bodyAndQuery }
