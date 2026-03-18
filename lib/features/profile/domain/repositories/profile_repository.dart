import '../models/app_version.dart';
import '../models/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile();
  Future<void> updateProfile(Profile profile);
  Future<void> updateNickname(String nickname);
  Future<void> updateAvatar(String avatarUrl);
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  Future<void> changePasswordByCode({
    required String phone,
    required String code,
    required String newPassword,
  });
  Future<void> changePhone({
    required String oldPhone,
    required String oldCode,
    required String newPhone,
    required String newCode,
  });
  Future<void> submitFeedback(String content);
  Future<AppVersion> checkForUpdate();
  Future<void> deactivateAccount({
    required String phone,
    required String code,
  });
}
