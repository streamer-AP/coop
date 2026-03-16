import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
import '../../application/providers/auth_providers.dart';
import '../../domain/models/auth_exception.dart';
import 'verification_code_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  bool get _canProceed =>
      _phoneController.text.length >= 11 &&
      _passwordController.text.length >= 6 &&
      _confirmController.text.isNotEmpty;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendCodeAndNavigate() async {
    if (_passwordController.text != _confirmController.text) {
      TopBannerToast.show(context, message: '密码输入不一致，请重新输入');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendVerificationCode(_phoneController.text);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        TopBannerToast.show(
          context,
          message: e is AuthException ? e.displayMessage : '验证码发送失败',
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VerificationCodeScreen(
          phone: _phoneController.text,
          title: '重置密码',
          onVerified: (code) => _resetPassword(code),
        ),
      ),
    );
  }

  Future<void> _resetPassword(String code) async {
    try {
      await ref.read(apiClientProvider).post(
        ApiEndpoints.resetPassword,
        queryParameters: {
          'mobile': _phoneController.text,
          'code': code,
          'password': _passwordController.text,
          'veryPassword': _passwordController.text,
        },
      );
    } catch (e) {
      if (mounted) {
        TopBannerToast.show(context, message: '重置失败，请重试');
      }
      return;
    }

    if (!mounted) return;

    // Show success dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withValues(alpha: 0.08),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 48,
                color: AppColors.success,
              ),
              const SizedBox(height: 16),
              const Text(
                '密码重置成功',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(ctx).pop();
                  // Pop back to login
                  Navigator.of(context)
                    ..pop() // pop verification code screen
                    ..pop(); // pop forgot password screen
                },
                child: Container(
                  width: 160,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleButtonGradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '确定',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.profileBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                '重置密码',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Password',
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textHint.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 40),
              // Phone
              const Text(
                '输入手机号码',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  prefixText: '+86 | ',
                  prefixStyle: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  hintText: '请输入手机号码',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  suffixIcon: _phoneController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel,
                              size: 18, color: AppColors.textHint),
                          onPressed: () {
                            _phoneController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: const UnderlineInputBorder(),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              // New password
              const Text(
                '输入新密码',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '请输入新密码',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  suffixIcon: _passwordController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel,
                              size: 18, color: AppColors.textHint),
                          onPressed: () {
                            _passwordController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: const UnderlineInputBorder(),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              // Confirm password
              const Text(
                '再次输入新密码',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: true,
                style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '再次输入新密码',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  suffixIcon: _confirmController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel,
                              size: 18, color: AppColors.textHint),
                          onPressed: () {
                            _confirmController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: const UnderlineInputBorder(),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 40),
              // Send code button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: (_canProceed && !_isLoading)
                      ? _sendCodeAndNavigate
                      : null,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: _canProceed
                          ? AppColors.purpleButtonGradient
                          : const LinearGradient(
                              colors: [Color(0xFFCCCCCC), Color(0xFFDDDDDD)],
                            ),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '发送验证码',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
