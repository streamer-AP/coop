import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../features/auth/domain/models/auth_exception.dart';

class VerificationCodeInput extends StatefulWidget {
  const VerificationCodeInput({
    super.key,
    required this.phoneController,
    required this.codeController,
    this.onSendCode,
    this.phonePrefix = '+86',
    this.countdownSeconds = 60,
  });

  final TextEditingController phoneController;
  final TextEditingController codeController;
  final Future<void> Function()? onSendCode;
  final String phonePrefix;
  final int countdownSeconds;

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  Timer? _timer;
  int _remaining = 0;
  bool _isSending = false;

  bool get _canSend =>
      !_isSending &&
      _remaining == 0 &&
      widget.phoneController.text.length >= 11;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startCountdown() async {
    if (!_canSend) return;

    setState(() => _isSending = true);
    try {
      await widget.onSendCode?.call();
    } catch (error) {
      if (!mounted) return;
      final message =
          error is AuthException
              ? error.displayMessage
              : '$error'.replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? '验证码发送失败' : message)),
      );
      return;
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }

    if (!mounted) return;
    setState(() => _remaining = widget.countdownSeconds);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remaining--;
        if (_remaining <= 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '输入手机号码',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: InputDecoration(
            prefixText: '${widget.phonePrefix} | ',
            prefixStyle: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
            suffixIcon:
                widget.phoneController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.cancel, size: 20),
                      onPressed: () {
                        widget.phoneController.clear();
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
        const Text(
          '输入验证码',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.codeController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _canSend ? () => _startCountdown() : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      _canSend
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isSending
                      ? '发送中...'
                      : _remaining > 0
                      ? '已发送(${_remaining}s)'
                      : '获取验证码',
                  style: TextStyle(
                    fontSize: 14,
                    color: _canSend ? AppColors.primary : AppColors.textHint,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
