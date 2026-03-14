import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/providers/auth_providers.dart';
import '../../domain/models/auth_exception.dart';

enum _LoginMode { code, password }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  Timer? _timer;
  int _remaining = 0;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  _LoginMode _mode = _LoginMode.code;

  bool get _canSendCode =>
      _remaining == 0 && _phoneController.text.length >= 11;

  bool get _canLogin {
    if (_phoneController.text.length < 11 || !_agreedToTerms) return false;
    return switch (_mode) {
      _LoginMode.code => _codeController.text.length == 6,
      _LoginMode.password => _passwordController.text.length >= 6,
    };
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startCountdown() async {
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendVerificationCode(_phoneController.text);
    } catch (e) {
      if (mounted) _showError(_extractErrorMessage(e));
      return;
    }
    setState(() => _remaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remaining--;
        if (_remaining <= 0) timer.cancel();
      });
    });
  }

  Future<void> _login() async {
    if (!_agreedToTerms) {
      _showError('请先阅读并同意用户协议和隐私政策');
      return;
    }
    setState(() => _isLoading = true);

    try {
      if (_mode == _LoginMode.code) {
        await ref.read(authNotifierProvider.notifier).loginWithCode(
              phone: _phoneController.text,
              code: _codeController.text,
            );
      } else {
        await ref.read(authNotifierProvider.notifier).loginWithPassword(
              phone: _phoneController.text,
              password: _passwordController.text,
            );
      }
    } catch (_) {
      // Error handled below
    }

    _timer?.cancel();

    if (!mounted) return;
    setState(() => _isLoading = false);

    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      _showError(_extractErrorMessage(authState.error));
      return;
    }

    // Check if user needs password setup
    final user = authState.valueOrNull;
    if (user?.needsPasswordSetup == true && mounted) {
      context.pushNamed(RouteNames.setupPassword);
    }
    // Otherwise navigation handled by GoRouter redirect
  }

  String _extractErrorMessage(Object? error) {
    if (error is AuthException) return error.displayMessage;
    return '操作失败，请重试';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.homeBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'OMAO',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '欢迎使用OMAO',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 48),
                _buildCard(),
                const SizedBox(height: 24),
                _buildAgreement(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModeSwitch(),
          const SizedBox(height: 24),
          _buildPhoneField(),
          const SizedBox(height: 20),
          if (_mode == _LoginMode.code) _buildCodeField(),
          if (_mode == _LoginMode.password) _buildPasswordField(),
          const SizedBox(height: 28),
          _buildLoginButton(),
          const SizedBox(height: 16),
          _buildFooterLinks(),
        ],
      ),
    );
  }

  Widget _buildModeSwitch() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _mode = _LoginMode.code),
          child: Text(
            '验证码登录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: _mode == _LoginMode.code
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: _mode == _LoginMode.code
                  ? AppColors.textPrimary
                  : AppColors.textHint,
            ),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: () => setState(() => _mode = _LoginMode.password),
          child: Text(
            '密码登录',
            style: TextStyle(
              fontSize: 18,
              fontWeight: _mode == _LoginMode.password
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: _mode == _LoginMode.password
                  ? AppColors.textPrimary
                  : AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      decoration: InputDecoration(
        prefixText: '+86 | ',
        prefixStyle: const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        hintText: '请输入手机号',
        hintStyle: const TextStyle(color: AppColors.textHint),
        suffixIcon: _phoneController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.cancel, size: 20),
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
    );
  }

  Widget _buildCodeField() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            decoration: const InputDecoration(
              hintText: '请输入验证码',
              hintStyle: TextStyle(color: AppColors.textHint),
              border: UnderlineInputBorder(),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _canSendCode ? _startCountdown : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              gradient:
                  _canSendCode ? AppColors.purpleButtonGradient : null,
              color: _canSendCode ? null : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _remaining > 0 ? '${_remaining}s' : '获取验证码',
              style: TextStyle(
                fontSize: 14,
                color: _canSendCode ? Colors.white : AppColors.textHint,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        hintText: '请输入密码',
        hintStyle: const TextStyle(color: AppColors.textHint),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            size: 20,
            color: AppColors.textHint,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: const UnderlineInputBorder(),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildLoginButton() {
    final enabled = _canLogin && !_isLoading;
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: enabled ? _login : null,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: enabled
                ? AppColors.purpleButtonGradient
                : const LinearGradient(
                    colors: [Color(0xFFCCCCCC), Color(0xFFDDDDDD)],
                  ),
            borderRadius: BorderRadius.circular(24),
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
    );
  }

  Widget _buildFooterLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_mode == _LoginMode.password)
          GestureDetector(
            onTap: () => context.pushNamed(RouteNames.forgotPassword),
            child: const Text(
              '忘记密码',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          const SizedBox.shrink(),
        GestureDetector(
          onTap: () => context.pushNamed(RouteNames.register),
          child: Text(
            '注册账号',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.primary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ],
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
                    : Colors.white.withValues(alpha: 0.5),
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
              text: '已阅读并同意',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              children: [
                TextSpan(
                  text: '《用户协议》',
                  style: const TextStyle(color: Colors.white),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () =>
                        context.pushNamed(RouteNames.userAgreement),
                ),
                const TextSpan(text: '和'),
                TextSpan(
                  text: '《隐私政策》',
                  style: const TextStyle(color: Colors.white),
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
