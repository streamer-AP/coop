import '../../../core/network/api_client.dart';
import '../domain/models/user.dart';
import '../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<User> login({required String phone, required String code}) async {
    // TODO: implement
    throw UnimplementedError();
  }

  @override
  Future<void> register({required String phone, required String code}) async {
    // TODO: implement
  }

  @override
  Future<void> verifyIdentity({
    required String name,
    required String idNumber,
  }) async {
    // TODO: implement
  }

  @override
  Future<void> logout() async {
    // TODO: implement
  }

  @override
  Future<User?> getCurrentUser() async {
    // TODO: implement
    return null;
  }
}
