import '../models/user.dart';
import '../models/verification_result.dart';

abstract class AuthRepository {
  /// 验证码登录
  Future<User> loginWithCode({required String phone, required String code});

  /// 密码登录
  Future<User> loginWithPassword({
    required String phone,
    required String password,
  });

  /// 注册（手机号+验证码+密码）
  Future<User> register({required String phone, required String code, String? password});

  /// 首次设置密码（验证码登录后）
  Future<void> setupPassword({required String password});

  /// 发送验证码
  Future<void> sendVerificationCode(String phone, {bool isRegister = false});

  /// 实名认证
  Future<VerificationResult> verifyIdentity({
    required String name,
    required String idNumber,
  });

  /// 登出
  Future<void> logout();

  /// 获取当前用户（从本地 token 恢复）
  Future<User?> getCurrentUser();

  /// 保存 token 到本地
  Future<void> saveToken(String token);

  /// 清除本地 token
  Future<void> clearToken();

  /// 读取本地 token
  Future<String?> getToken();
}
