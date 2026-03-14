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
import 'verification_code_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCodeAndNavigate() async {
    if (!_agreedToTerms) {
      TopBannerToast.show(context, message: '登录前请先阅读并同意相关协议');
      return;
    }
    if (_phoneController.text.length < 11) return;

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
          title: '验证码登录',
          onVerified: (code) => _loginWithCode(code),
        ),
      ),
    );
  }

  Future<void> _loginWithCode(String code) async {
    await ref.read(authNotifierProvider.notifier).loginWithCode(
          phone: _phoneController.text,
          code: code,
        );

    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      TopBannerToast.show(
        context,
        message: _errorMsg(authState.error),
      );
      return;
    }

    final user = authState.valueOrNull;
    if (user?.needsPasswordSetup == true) {
      context.goNamed(RouteNames.setupPassword);
    }
    // Otherwise GoRouter redirect handles navigation
  }

  String _errorMsg(Object? e) {
    if (e is AuthException) return e.displayMessage;
    return '操作失败，请重试';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.homeBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.white,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Hello!',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '欢迎来到 OMAO',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // White card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 0),
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '验证码登录',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              context.pushNamed(RouteNames.register),
                          child: const Text(
                            '注册账号',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textHint.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '输入手机号码',
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
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 32),
                    // Send code button
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: (_phoneController.text.length >= 11 &&
                                !_isLoading)
                            ? _sendCodeAndNavigate
                            : null,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: _phoneController.text.length >= 11
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
                    const SizedBox(height: 16),
                    // Agreement
                    _buildAgreement(),
                    const SizedBox(height: 120),
                    // Password login link
                    Center(
                      child: GestureDetector(
                        onTap: () => context
                            .pushNamed(RouteNames.passwordLogin),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '密码登录',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primary.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppColors.primary.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
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
              color: _agreedToTerms
                  ? AppColors.primary
                  : Colors.transparent,
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
