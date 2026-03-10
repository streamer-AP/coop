import '../../../core/network/api_client.dart';
import '../domain/models/profile.dart';
import '../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepositoryImpl(this._apiClient);

  @override
  Future<Profile> getProfile() async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> updateProfile(Profile profile) async {
    // TODO: implement
  }
}
