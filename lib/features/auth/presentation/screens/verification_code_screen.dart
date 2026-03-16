import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/pin_code_input.dart';
import '../../application/providers/auth_providers.dart';

class VerificationCodeScreen extends ConsumerStatefulWidget {
  const VerificationCodeScreen({
    super.key,
    required this.phone,
    required this.title,
    required this.onVerified,
    this.isRegister = false,
  });

  final String phone;
  final String title;
  final ValueChanged<String> onVerified;
  final bool isRegister;

  @override
  ConsumerState<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState
    extends ConsumerState<VerificationCodeScreen> {
  Timer? _timer;
  int _remaining = 56;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _remaining = 56);
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

  Future<void> _resend() async {
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendVerificationCode(widget.phone, isRegister: widget.isRegister);
      _startCountdown();
    } catch (_) {}
  }

  String get _maskedPhone {
    final p = widget.phone;
    if (p.length >= 11) {
      return '+86 ${p.substring(0, 3)} ${p.substring(3, 7)} ${p.substring(7)}';
    }
    return '+86 $p';
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _subtitleText,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textHint.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                '输入6位验证码',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              PinCodeInput(
                onCompleted: widget.onVerified,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '已发送至 $_maskedPhone',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textHint,
                    ),
                  ),
                  GestureDetector(
                    onTap: _remaining <= 0 ? _resend : null,
                    child: Text(
                      _remaining > 0 ? '$_remaining 秒后再次发送' : '再次发送',
                      style: TextStyle(
                        fontSize: 13,
                        color: _remaining > 0
                            ? AppColors.primary
                            : AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _subtitleText {
    return switch (widget.title) {
      '验证码登录' => 'Sign In',
      '验证码注册' => 'Sign Up',
      '重置密码' => 'Password',
      _ => '',
    };
  }
}
