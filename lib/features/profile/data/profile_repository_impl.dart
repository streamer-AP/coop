import '../../../core/network/api_client.dart';
import '../domain/models/app_version.dart';
import '../domain/models/profile.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepositoryImpl(this._apiClient);

  @override
  Future<Profile> getProfile() async {
    // TODO: implement API call
    return const Profile(
      userId: 'demo',
      nickname: '昵称3934',
      phone: '136****5678',
      avatarPreset: 'flower',
    );
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    // TODO: implement
  }

  @override
  Future<void> updateNickname(String nickname) async {
    // TODO: implement
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
}
