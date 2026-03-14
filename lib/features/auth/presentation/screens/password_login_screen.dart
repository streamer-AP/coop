import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
import '../../application/providers/auth_providers.dart';
import '../../domain/models/auth_exception.dart';

class PasswordLoginScreen extends ConsumerStatefulWidget {
  const PasswordLoginScreen({super.key});

  @override
  ConsumerState<PasswordLoginScreen> createState() =>
      _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends ConsumerState<PasswordLoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _obscure = true;

  bool get _canLogin =>
      _phoneController.text.length >= 11 &&
      _passwordController.text.length >= 6;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_agreedToTerms) {
      TopBannerToast.show(context, message: '登录或注册前请先阅读并同意相关协议');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).loginWithPassword(
            phone: _phoneController.text,
            password: _passwordController.text,
          );
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isLoading = false);

    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      TopBannerToast.show(
        context,
        message: authState.error is AuthException
            ? (authState.error as AuthException).displayMessage
            : '手机号或密码错误，请重新输入',
      );
    }
    // GoRouter redirect handles successful navigation
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
                '密码登录',
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
              // Phone field
              const Text(
                '手机号码',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
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
              // Password field
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '密码',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        context.pushNamed(RouteNames.forgotPassword),
                    child: const Text(
                      '忘记密码',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '请输入密码',
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
              const SizedBox(height: 40),
              // Login button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: (_canLogin && !_isLoading) ? _login : null,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: _canLogin
                          ? AppColors.purpleButtonGradient
                          : const LinearGradient(
                              colors: [
                                Color(0xFFCCCCCC),
                                Color(0xFFDDDDDD),
                              ],
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
                            '登录',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildAgreement(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgreement() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          child: Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _agreedToTerms
                    ? AppColors.primary
                    : AppColors.textHint,
              ),
              color: _agreedToTerms ? AppColors.primary : Colors.transparent,
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              text: '我已阅读并同意',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                  text: '《用户协议》',
                  style: const TextStyle(color: AppColors.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () =>
                        context.pushNamed(RouteNames.userAgreement),
                ),
                const TextSpan(text: '和'),
                TextSpan(
                  text: '《隐私政策》',
                  style: const TextStyle(color: AppColors.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () =>
                        context.pushNamed(RouteNames.privacyPolicy),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
