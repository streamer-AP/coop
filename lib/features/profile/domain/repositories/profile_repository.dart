import '../models/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile();
  Future<void> updateProfile(Profile profile);
}
