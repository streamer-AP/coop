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
    // TODO: implement
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
}
