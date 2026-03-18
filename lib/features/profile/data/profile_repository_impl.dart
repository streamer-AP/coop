import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/models/app_version.dart';
import '../domain/models/profile.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepositoryImpl(this._apiClient);

  @override
  Future<Profile> getProfile() async {
    try {
      final json = await _apiClient.get(ApiEndpoints.getCurrentUserInfo);
      final code = json['code'] as int?;
      final data = json['data'] as Map<String, dynamic>?;

      if (code == 200 && data != null) {
        final residentStatus = '${data['residentStatus'] ?? '0'}';
        final phone = data['mobile'] as String? ?? '';
        return Profile(
          userId: '${data['id'] ?? data['userId'] ?? ''}',
          nickname: data['userName'] as String?,
          avatarUrl:
              data['avatarUrl'] as String? ??
              data['avatar'] as String? ??
              data['headImage'] as String?,
          phone: _maskPhone(phone),
          isVerified: residentStatus == '1',
          avatarPreset: 'flower',
        );
      }
    } catch (_) {
      // Fall through to an empty profile so the profile page remains usable.
    }

    return const Profile(
      userId: '',
      nickname: null,
      phone: '',
      avatarPreset: 'flower',
    );
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    // TODO: implement
  }

  @override
  Future<void> updateNickname(String nickname) async {
    final json = await _apiClient.post(
      ApiEndpoints.updateNickname,
      data: {'userName': nickname},
      queryParameters: {'userName': nickname},
    );
    final code = json['code'] as int?;
    if (code != 200) {
      throw Exception(json['message'] ?? '用户名更新失败');
    }
  }

  @override
  Future<void> updateAvatar(String avatarUrl) async {
    final value = avatarUrl.trim();
    if (value.isEmpty) {
      throw Exception('头像地址为空');
    }

    final localFile = _resolveLocalFile(value);
    if (localFile != null) {
      await _uploadAvatarFile(localFile);
      return;
    }

    try {
      final json = await _apiClient.post(
        ApiEndpoints.updateAvatar,
        data: {'avatarUrl': value},
        queryParameters: {'avatarUrl': value},
      );
      _ensureSuccess(json, fallbackMessage: '头像更新失败');
    } on DioException catch (error) {
      throw Exception(_extractDioMessage(error, fallback: '头像更新失败'));
    }
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

  Future<void> _uploadAvatarFile(File file) async {
    final path = file.path;
    if (!await file.exists()) {
      throw Exception('头像文件不存在');
    }
    if (await file.length() <= 0) {
      throw Exception('头像文件为空');
    }

    final fileName = p.basename(path);
    final fields = ['file', 'avatar', 'headImage', 'avatarFile', 'image'];
    Object? lastError;

    for (final field in fields) {
      try {
        final formData = FormData.fromMap({
          field: await MultipartFile.fromFile(path, filename: fileName),
        });
        final json = await _apiClient.post(
          ApiEndpoints.updateAvatar,
          data: formData,
        );
        _ensureSuccess(json, fallbackMessage: '头像上传失败');
        return;
      } on DioException catch (error) {
        lastError = Exception(_extractDioMessage(error, fallback: '头像上传失败'));
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError == null) {
      throw Exception('头像上传失败');
    }
    if (lastError is Exception) {
      throw lastError;
    }
    throw Exception('$lastError');
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

  void _ensureSuccess(
    Map<String, dynamic> json, {
    required String fallbackMessage,
  }) {
    final code = json['code'];
    final isSuccess = code == null || code == 0 || code == 200;
    if (isSuccess) return;
    throw Exception(json['message'] ?? fallbackMessage);
  }

  String _extractDioMessage(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['msg'] ?? data['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    return error.message?.trim().isNotEmpty == true
        ? error.message!.trim()
        : fallback;
  }
}
