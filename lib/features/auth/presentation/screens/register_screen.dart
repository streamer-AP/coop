import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/purple_gradient_button.dart';
import '../../application/providers/auth_providers.dart';
import '../../domain/models/auth_exception.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  Timer? _timer;
  int _remaining = 0;
  bool _isLoading = false;
  bool _agreedToTerms = false;

  bool get _canSendCode =>
      _remaining == 0 && _phoneController.text.length >= 11;

  bool get _canRegister =>
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
    } catch (e) {
      if (mounted) _showError(_errorMsg(e));
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

  Future<void> _register() async {
    if (!_agreedToTerms) {
      _showError('请先阅读并同意用户协议和隐私政策');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).register(
            phone: _phoneController.text,
            code: _codeController.text,
          );
    } catch (_) {}

    _timer?.cancel();
    if (!mounted) return;
    setState(() => _isLoading = false);

    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      _showError(_errorMsg(authState.error));
      return;
    }

    // 注册成功后跳转设置密码
    if (mounted) {
      context.goNamed(RouteNames.setupPassword);
    }
  }

  String _errorMsg(Object? e) {
    if (e is AuthException) return e.displayMessage;
    return '操作失败，请重试';
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
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
                '注册账号',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '仅支持中国大陆手机号注册',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhoneField(),
                    const SizedBox(height: 20),
                    _buildCodeField(),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: PurpleGradientButton(
                        text: _isLoading ? '' : '注册',
                        enabled: _canRegister && !_isLoading,
                        onPressed: _register,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildAgreement(),
            ],
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
        prefixStyle: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: _canSendCode ? AppColors.purpleButtonGradient : null,
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
              color: _agreedToTerms ? AppColors.primary : Colors.transparent,
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '已阅读并同意《用户协议》和《隐私政策》',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}
