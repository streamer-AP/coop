import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/models/app_version.dart';
import '../domain/models/cancellation_session.dart';
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
        final residentStatus =
            '${_readField(data, const ['residentStatus']) ?? '0'}';
        final phone =
            (_readField(data, const ['mobile', 'phone']) as String?) ?? '';
        final userId = _extractUserId(data);
        final nickname = _extractNickname(data);
        final avatarUrl = _extractAvatarUrl(data);
        profile = Profile(
          userId: userId,
          nickname: nickname,
          avatarUrl: avatarUrl,
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
    final nickname = profile.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      await updateNickname(nickname);
    }
    final avatarUrl = profile.avatarUrl?.trim();
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      await updateAvatar(avatarUrl);
    }
  }

  @override
  Future<void> updateNickname(String nickname) async {
    final value = nickname.trim();
    if (value.isEmpty) {
      throw Exception('用户名不能为空');
    }

    final json = await _apiClient.put(
      ApiEndpoints.updateNickname,
      queryParameters: {'userName': value},
    );
    final code = json['code'] as int?;
    if (code != 200) {
      throw Exception(
        json['message'] as String? ?? json['msg'] as String? ?? '修改用户名失败',
      );
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
    final destPath = p.join(
      _avatarDirectory,
      'avatar_${DateTime.now().millisecondsSinceEpoch}$ext',
    );

    await _deleteAllLocalAvatars();

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
    final previousValue = oldPassword.trim();
    final nextValue = newPassword.trim();
    if (previousValue.isEmpty) {
      throw Exception('原密码不能为空');
    }
    if (nextValue.isEmpty) {
      throw Exception('新密码不能为空');
    }

    final json = await _apiClient.post(
      ApiEndpoints.updatePwd,
      queryParameters: {'oldPwd': previousValue},
      data: {
        'oldPwd': previousValue,
        'newPwd': nextValue,
        'confirmPassword': nextValue,
      },
    );
    _ensureSuccess(json, fallbackMessage: '修改密码失败');
  }

  @override
  Future<void> changePasswordByCode({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    final phoneValue = phone.trim();
    final codeValue = code.trim();
    final passwordValue = newPassword.trim();
    if (phoneValue.isEmpty) {
      throw Exception('手机号不能为空');
    }
    if (codeValue.isEmpty) {
      throw Exception('验证码不能为空');
    }
    if (passwordValue.isEmpty) {
      throw Exception('新密码不能为空');
    }

    final json = await _apiClient.post(
      ApiEndpoints.forgotPwd,
      queryParameters: {
        'mobile': phoneValue,
        'code': codeValue,
        'newPwd': passwordValue,
      },
    );
    _ensureSuccess(json, fallbackMessage: '修改密码失败');
  }

  @override
  Future<void> sendPasswordResetCode(String phone) async {
    final phoneValue = phone.trim();
    if (phoneValue.isEmpty) {
      throw Exception('手机号不能为空');
    }

    final json = await _apiClient.post(
      ApiEndpoints.forgotPwdSendCode,
      queryParameters: {'mobile': phoneValue},
    );
    _ensureSuccess(json, fallbackMessage: '验证码发送失败');
  }

  @override
  Future<CancellationSession> sendDeactivateCode(String phone) async {
    final phoneValue = phone.trim();
    if (phoneValue.isEmpty) {
      throw Exception('手机号不能为空');
    }

    try {
      final json = await _apiClient.post(
        ApiEndpoints.sendCancelCode,
        data: _buildSimpleCancelPayload(mobile: phoneValue),
      );
      final code = json['code'] as int?;
      final msg = json['message'] as String? ?? '';
      if (code != 200 && code != 0) {
        throw Exception(msg.isNotEmpty ? msg : '验证码发送失败');
      }
    } on DioException catch (error) {
      throw Exception(_extractDioMessage(error) ?? '验证码发送失败，请检查网络后重试');
    }

    // 返回简单 session，用于后续 cancel 调用
    return CancellationSession(
      id: 0,
      logId: 0,
      userId: 0,
      mobile: phoneValue,
      accountStatus: 0,
      accountDeletedTimestamp: '',
      operator: '',
      verifiedStatus: 0,
      ipAddress: '',
      ipInfo: '',
      deviceModel: '',
      deviceOs: Platform.operatingSystem,
      deviceType: _resolveDeviceType(),
      deviceInfo: _buildDeviceInfoJson(),
      appInfo: _buildAppInfoJson(),
      createdAt: '',
    );
  }

  @override
  Future<void> changePhone({
    required String oldPhone,
    required String oldCode,
    required String newPhone,
    required String newCode,
  }) async {
    final oldPhoneVal = oldPhone.trim();
    final oldCodeVal = oldCode.trim();
    final newPhoneVal = newPhone.trim();
    final newCodeVal = newCode.trim();
    if (oldPhoneVal.isEmpty || oldCodeVal.isEmpty) {
      throw Exception('请先验证原手机号');
    }
    if (newPhoneVal.isEmpty || newCodeVal.isEmpty) {
      throw Exception('请输入新手机号和验证码');
    }

    final json = await _apiClient.post(
      ApiEndpoints.changePhone,
      data: {
        'oldMobile': oldPhoneVal,
        'oldCode': oldCodeVal,
        'newMobile': newPhoneVal,
        'newCode': newCodeVal,
      },
    );
    _ensureSuccess(json, fallbackMessage: '修改手机号失败');
  }

  @override
  Future<void> submitFeedback(String content) async {
    if (content.trim().isEmpty) {
      throw Exception('反馈内容不能为空');
    }

    // 获取用户信息
    String omaoId = '';
    int userId = 0;
    try {
      final userJson = await _apiClient.get(ApiEndpoints.getCurrentUserInfo);
      final userData = userJson['data'] as Map<String, dynamic>?;
      if (userData != null) {
        omaoId = (userData['omaoId'] as String?) ?? '';
        userId =
            int.tryParse('${userData['userId'] ?? userData['id'] ?? 0}') ?? 0;
      }
    } catch (_) {}

    final json = await _apiClient.post(
      ApiEndpoints.feedback,
      data: {
        'id': 0,
        'userId': userId,
        'omaoId': omaoId,
        'content': content.trim(),
        'deviceModel': '',
        'deviceOs': Platform.operatingSystem,
        'deviceType': _resolveDeviceType(),
        'deviceInfo': _buildDeviceInfoJson(),
        'ipAddress': '',
        'ipInfo': '',
        'networkType': '',
        'appInfo': _buildAppInfoJson(),
        'opStatus': 0,
        'opTags': '',
        'opRemark': '',
        'operator': '',
        'createdAt': _formatBackendTimestamp(DateTime.now()),
        'updatedAt': _formatBackendTimestamp(DateTime.now()),
      },
    );
    final code = json['code'] as int?;
    if (code != 200 && code != 0) {
      final msg = json['message'] as String? ?? '反馈提交失败';
      throw Exception(msg);
    }
  }

  @override
  Future<AppVersion> checkForUpdate() async {
    // 读取当前 app 版本号
    const currentVersion = '1.0.0'; // 与 pubspec.yaml version 保持同步

    try {
      final json = await _apiClient.get(ApiEndpoints.checkUpdate);
      final code = json['code'] as int?;
      final data = json['data'] as Map<String, dynamic>?;

      if (code == 200 && data != null) {
        final latestVersion =
            (data['version'] as String?)?.trim() ?? currentVersion;
        final downloadUrl = data['downloadUrl'] as String?;
        final changelog = data['changelog'] as String?;
        final hasUpdate = _isNewerVersion(latestVersion, currentVersion);
        return AppVersion(
          version: currentVersion,
          hasUpdate: hasUpdate,
          downloadUrl: downloadUrl,
          changelog: changelog,
        );
      }
    } catch (_) {
      // 网络异常时返回当前版本，不阻塞 UI
    }

    return const AppVersion(version: currentVersion);
  }

  /// 比较语义版本号，latestVersion > currentVersion 时返回 true
  bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final length = latestParts.length > currentParts.length
        ? latestParts.length
        : currentParts.length;
    for (var i = 0; i < length; i++) {
      final l = i < latestParts.length ? latestParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  @override
  Future<void> deactivateAccount({
    required CancellationSession session,
    required String code,
  }) async {
    final codeValue = code.trim();
    if (codeValue.isEmpty) {
      throw Exception('验证码不能为空');
    }
    if (session.mobile.trim().isEmpty) {
      throw Exception('请先获取验证码');
    }

    try {
      final payload = _buildSimpleCancelPayload(mobile: session.mobile);
      payload['verificationCode'] = codeValue;

      final json = await _apiClient.post(
        ApiEndpoints.deactivateAccount,
        data: payload,
      );
      final respCode = json['code'] as int?;
      final msg = json['message'] as String? ?? json['msg'] as String? ?? '';
      if (respCode != 200 && respCode != 0) {
        throw Exception(msg.isNotEmpty ? msg : '注销失败，请重试');
      }
    } on DioException catch (error) {
      throw Exception(_extractDioMessage(error) ?? '注销失败，请检查网络后重试');
    }
  }

  String _formatBackendTimestamp(DateTime value) {
    return _backendDateTimeFormat.format(value);
  }

  Map<String, dynamic> _buildSimpleCancelPayload({required String mobile}) {
    return {
      'mobile': mobile,
      'appInfo': _buildAppInfoJson(),
      'deviceInfo': _buildDeviceInfoJson(),
      'deviceModel': '',
      'deviceOs': Platform.operatingSystem,
      'deviceType': _resolveDeviceType(),
    };
  }

  String _resolveDeviceType() {
    if (Platform.isAndroid || Platform.isIOS) {
      return 'mobile';
    }
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return 'desktop';
    }
    return Platform.operatingSystem;
  }

  String? _extractDioMessage(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return '网络连接失败';
    }

    final data = error.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final message =
          map['message'] as String? ?? map['msg'] as String? ?? error.message;
      final normalized = message?.trim() ?? '';
      if (normalized.isNotEmpty) {
        return normalized;
      }
    }

    final message = error.message?.trim() ?? '';
    if (message.isEmpty) {
      return null;
    }
    return message;
  }

  static String _buildDeviceInfoJson() {
    return json.encode({
      'platform': Platform.operatingSystem,
      'osVersion': Platform.operatingSystemVersion,
    });
  }

  static String _buildAppInfoJson() {
    return json.encode({
      'version': '1.0.0',
      'package': 'com.example.omao_app',
      'platform': Platform.operatingSystem,
    });
  }
  static final DateFormat _backendDateTimeFormat = DateFormat(
    'yyyy-MM-dd HH:mm:ss',
  );

  String _maskPhone(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }

  /// 在用户头像目录中查找 avatar.* 文件。
  Future<String?> _findLocalAvatar() async {
    final avatarDir = Directory(_avatarDirectory);
    if (!await avatarDir.exists()) return null;

    FileSystemEntity? latestAvatar;
    DateTime? latestModifiedAt;

    await for (final entity in avatarDir.list()) {
      if (entity is File) {
        final basename = p.basenameWithoutExtension(entity.path);
        if (!basename.startsWith('avatar')) {
          continue;
        }

        final modifiedAt = await entity.lastModified();
        if (latestModifiedAt == null || modifiedAt.isAfter(latestModifiedAt)) {
          latestAvatar = entity;
          latestModifiedAt = modifiedAt;
        }
      }
    }

    return latestAvatar?.path;
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
    // userId/loginId 才是用户维度标识，id 可能只是资料记录主键。
    final raw = _readField(data, const ['userId', 'loginId', 'id']);
    if (raw == null) return '';
    return '$raw'.trim();
  }

  String? _extractNickname(Map<String, dynamic> data) {
    return _normalizeOptionalString(
      _readField(data, const [
        'userName',
        'username',
        'nickName',
        'nickname',
        'name',
      ]),
    );
  }

  String? _extractAvatarUrl(Map<String, dynamic> data) {
    return _normalizeOptionalString(
      _readField(data, const ['avatarUrl', 'avatar', 'headImage', 'headImg']),
    );
  }

  String? _normalizeOptionalString(Object? value) {
    final normalized = '$value'.trim();
    if (value == null || normalized.isEmpty || normalized == 'null') {
      return null;
    }
    return normalized;
  }

  Future<void> _persistCurrentUserId(String userId) async {
    if (userId.trim().isEmpty) return;
    await _tokenStorage.saveCurrentUserId(userId);
  }

  Object? _readField(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final direct = data[key];
      if (direct != null) {
        return direct;
      }
    }

    for (final nestedKey in const [
      'userInfo',
      'userAccount',
      'account',
      'profile',
    ]) {
      final nested = data[nestedKey];
      if (nested is! Map) {
        continue;
      }

      final nestedMap = Map<String, dynamic>.from(nested);
      for (final key in keys) {
        final value = nestedMap[key];
        if (value != null) {
          return value;
        }
      }
    }

    return null;
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

  Future<void> _deleteAllLocalAvatars() async {
    final avatarDir = Directory(_avatarDirectory);
    if (!await avatarDir.exists()) {
      return;
    }

    await for (final entity in avatarDir.list()) {
      if (entity is! File) {
        continue;
      }

      final basename = p.basenameWithoutExtension(entity.path);
      if (!basename.startsWith('avatar')) {
        continue;
      }

      await _deleteFileIfExists(entity.path);
    }
  }

  void _ensureSuccess(
    Map<String, dynamic> json, {
    required String fallbackMessage,
  }) {
    final code = json['code'] as int?;
    if (code == 200 || code == 0) {
      return;
    }
    throw Exception(
      json['message'] as String? ?? json['msg'] as String? ?? fallbackMessage,
    );
  }
}

