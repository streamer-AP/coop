import '../models/user.dart';
import '../models/verification_result.dart';

abstract class AuthRepository {
  Future<User> login({required String phone, required String code});
  Future<void> register({required String phone, required String code});
  Future<VerificationResult> verifyIdentity({
    required String name,
    required String idNumber,
  });
  Future<void> sendVerificationCode(String phone);
  Future<void> logout();
  Future<User?> getCurrentUser();
}
