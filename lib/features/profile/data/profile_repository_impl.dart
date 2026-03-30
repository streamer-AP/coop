import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
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
    // TODO: implement
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
  Future<void> sendDeactivateCode(String phone) async {
    final phoneValue = phone.trim();
    if (phoneValue.isEmpty) {
      throw Exception('手机号不能为空');
    }

    final auditContext = await _loadCancellationAuditContext(
      fallbackPhone: phoneValue,
    );
    final timestamp = _formatBackendTimestamp(DateTime.now());

    try {
      final json = await _apiClient.post(
        ApiEndpoints.sendCancelCode,
        data: {
          ..._buildCancellationAuditPayload(
            context: auditContext,
            timestamp: timestamp,
          ),
          'success': 0,
          'verifiedStatus': auditContext.verifiedStatus,
          'operationDetail': 'send_cancel_code',
        },
      );
      _ensureSuccess(json, fallbackMessage: '验证码发送失败');
    } on DioException catch (error) {
      throw Exception(
        _extractDioMessage(error) ?? '验证码发送失败，请检查网络后重试',
      );
    }
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
    final phoneValue = phone.trim();
    final codeValue = code.trim();
    if (phoneValue.isEmpty) {
      throw Exception('手机号不能为空');
    }
    if (codeValue.isEmpty) {
      throw Exception('验证码不能为空');
    }

    final auditContext = await _loadCancellationAuditContext(
      fallbackPhone: phoneValue,
    );
    final timestamp = _formatBackendTimestamp(DateTime.now());

    try {
      final json = await _apiClient.post(
        ApiEndpoints.deactivateAccount,
        queryParameters: {'code': codeValue},
        data: {
          ..._buildCancellationAuditPayload(
            context: auditContext,
            timestamp: timestamp,
          ),
          'verificationCode': codeValue,
          'updatedAt': timestamp,
          'deletedAt': timestamp,
          'deletedReason': 'user_requested',
        },
      );
      _ensureSuccess(json, fallbackMessage: '注销失败，请重试');
    } on DioException catch (error) {
      throw Exception(
        _extractDioMessage(error) ?? '注销失败，请检查网络后重试',
      );
    }
  }

  Map<String, dynamic> _buildCancellationAuditPayload({
    required _CancellationAuditContext context,
    required String timestamp,
  }) {
    return {
      'id': context.id,
      'logId': 0,
      'userId': context.userId,
      'mobile': context.mobile,
      'accountStatus': context.accountStatus,
      'accountDeletedTimestamp': timestamp,
      'operator': context.operator,
      'ipAddress': '',
      'ipInfo': '',
      'deviceModel': '',
      'deviceOs': Platform.operatingSystem,
      'deviceType': _resolveDeviceType(),
      'deviceInfo': Platform.operatingSystemVersion,
      'appInfo': _appInfo,
      'createdAt': timestamp,
    };
  }

  Future<_CancellationAuditContext> _loadCancellationAuditContext({
    required String fallbackPhone,
  }) async {
    final normalizedPhone = fallbackPhone.trim();
    var id = 0;
    var userId = 0;
    var accountStatus = 0;
    var verifiedStatus = 0;
    var operator = '';
    var mobile = normalizedPhone;

    try {
      final json = await _apiClient.get(ApiEndpoints.getCurrentUserInfo);
      final code = json['code'] as int?;
      final data = json['data'] as Map<String, dynamic>?;
      if (code == 200 && data != null) {
        id = int.tryParse('${_readField(data, const ['id']) ?? 0}') ?? 0;
        userId =
            int.tryParse(
              '${_readField(data, const ['userId', 'loginId', 'id']) ?? 0}',
            ) ??
            0;
        accountStatus =
            int.tryParse('${_readField(data, const ['status']) ?? 0}') ?? 0;
        verifiedStatus =
            int.tryParse(
              '${_readField(data, const ['residentStatus']) ?? 0}',
            ) ??
            0;
        mobile =
            _normalizeOptionalString(
              _readField(data, const ['mobile', 'phone']),
            ) ??
            normalizedPhone;
        operator =
            _extractNickname(data) ??
            _normalizeOptionalString(
              _readField(data, const ['mobile', 'phone']),
            ) ??
            'user';
      }
    } catch (_) {}

    if (mobile.isNotEmpty &&
        normalizedPhone.isNotEmpty &&
        mobile != normalizedPhone) {
      throw Exception('请输入当前登录手机号');
    }

    if (userId == 0) {
      userId = int.tryParse(await _resolveCurrentUserId()) ?? 0;
    }

    if (operator.trim().isEmpty) {
      operator = mobile.isNotEmpty ? mobile : 'user';
    }

    return _CancellationAuditContext(
      id: id,
      userId: userId,
      mobile: mobile.isNotEmpty ? mobile : normalizedPhone,
      accountStatus: accountStatus,
      verifiedStatus: verifiedStatus,
      operator: operator,
    );
  }

  String _formatBackendTimestamp(DateTime value) {
    return _backendDateTimeFormat.format(value);
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

  static const String _appInfo = 'omao_app/1.0.0+1';
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

class _CancellationAuditContext {
  const _CancellationAuditContext({
    required this.id,
    required this.userId,
    required this.mobile,
    required this.accountStatus,
    required this.verifiedStatus,
    required this.operator,
  });

  final int id;
  final int userId;
  final String mobile;
  final int accountStatus;
  final int verifiedStatus;
  final String operator;
}
