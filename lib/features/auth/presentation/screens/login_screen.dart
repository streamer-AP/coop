import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  Timer? _timer;
  int _remaining = 0;
  bool _agreedToTerms = false;

  bool get _canSendCode =>
      _remaining == 0 && _phoneController.text.length >= 11;

  bool get _canLogin =>
      _phoneController.text.length >= 11 &&
      _codeController.text.length == 6 &&
      _agreedToTerms;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startCountdown() async {
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendVerificationCode(_phoneController.text);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('验证码发送失败，请重试')),
        );
      }
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
    await ref.read(authNotifierProvider.notifier).login(
          phone: _phoneController.text,
          code: _codeController.text,
        );
    _timer?.cancel();
    final authState = ref.read(authNotifierProvider);
    if (authState.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录失败，请重试')),
      );
      return;
    }
    // Navigation handled by GoRouter redirect via refreshListenable
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
          child: Padding(
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
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '手机号登录',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildPhoneField(),
                      const SizedBox(height: 20),
                      _buildCodeField(),
                      const SizedBox(height: 28),
                      _buildLoginButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildAgreement(),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _canLogin ? _login : null,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: _canLogin
                ? AppColors.purpleButtonGradient
                : const LinearGradient(
                    colors: [Color(0xFFCCCCCC), Color(0xFFDDDDDD)],
                  ),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: const Text(
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
