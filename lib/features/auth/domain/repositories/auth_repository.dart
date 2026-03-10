import '../models/user.dart';

abstract class AuthRepository {
  Future<User> login({required String phone, required String code});
  Future<void> register({required String phone, required String code});
  Future<void> verifyIdentity({required String name, required String idNumber});
  Future<void> logout();
  Future<User?> getCurrentUser();
}
