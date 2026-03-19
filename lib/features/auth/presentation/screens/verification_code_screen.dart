import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/pin_code_input.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
import '../../application/providers/auth_providers.dart';
import '../../domain/models/auth_exception.dart';
import '../widgets/auth_chrome.dart';

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
  final FutureOr<void> Function(String code) onVerified;
  final bool isRegister;

  @override
  ConsumerState<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState
    extends ConsumerState<VerificationCodeScreen> {
  Timer? _timer;
  int _remaining = 56;
  bool _isSubmitting = false;

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
        _remaining -= 1;
        if (_remaining <= 0) {
          _remaining = 0;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resend() async {
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendVerificationCode(widget.phone, isRegister: widget.isRegister);
      _startCountdown();
      if (mounted) {
        TopBannerToast.show(context, message: '验证码已重新发送', isError: false);
      }
    } catch (error) {
      if (!mounted) return;
      TopBannerToast.show(
        context,
        message: error is AuthException ? error.displayMessage : '验证码发送失败',
      );
    }
  }

  Future<void> _submitCode(String code) async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.onVerified(code);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String get _maskedPhone {
    final digits = widget.phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 11) {
      return '+86 ${digits.substring(0, 3)} ${digits.substring(3, 7)} ${digits.substring(7, 11)}';
    }
    return '+86 $digits';
  }

  String get _subtitleText {
    return switch (widget.title) {
      '验证码登录' => 'Sign In',
      '验证码注册' => 'Sign Up',
      '重置密码' => 'Password',
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: keyboardInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthBackButton(
                          iconColor: AuthPalette.title,
                          backgroundColor: Color(0x40FFFFFF),
                        ),
                        const SizedBox(height: 76),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: AuthTitleBlock(
                            title: widget.title,
                            subtitle: _subtitleText,
                          ),
                        ),
                        const SizedBox(height: 78),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '输入6位验证码',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AuthPalette.body,
                                ),
                              ),
                              const SizedBox(height: 28),
                              IgnorePointer(
                                ignoring: _isSubmitting,
                                child: PinCodeInput(onCompleted: _submitCode),
                              ),
                              const SizedBox(height: 22),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '已发送至 $_maskedPhone',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AuthPalette.hint,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _remaining > 0 ? null : _resend,
                                    child: Text(
                                      _remaining > 0
                                          ? '$_remaining 秒后再次发送'
                                          : '再次发送',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            _remaining > 0
                                                ? AuthPalette.hint
                                                : AuthPalette.link,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_isSubmitting) ...[
                                const SizedBox(height: 24),
                                const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AuthPalette.actionDark,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
