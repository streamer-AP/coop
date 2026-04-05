import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  static const _labelColor = Color(0xFF000000);
  static const _dividerColor = Color(0x668988AB); // #8988AB @ 0.4

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
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: _labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: _labelColor,
          ),
          decoration: InputDecoration(
            hintText: '请输入手机号码',
            hintStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Color(0xFF787878),
            ),
            prefixText: '${widget.phonePrefix} | ',
            prefixStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: _labelColor,
            ),
            suffixIcon:
                widget.phoneController.text.isNotEmpty
                    ? GestureDetector(
                      onTap: () {
                        widget.phoneController.clear();
                        setState(() {});
                      },
                      child: Center(
                        widthFactor: 1,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF000000).withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    : null,
            border: const UnderlineInputBorder(),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _dividerColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _dividerColor),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        const Text(
          '输入验证码',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: _labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.codeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: _labelColor,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                decoration: const InputDecoration(
                  hintText: '请输入验证码',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF787878),
                  ),
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _dividerColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _dividerColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _canSend ? () => _startCountdown() : null,
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: _remaining > 0
                      ? const Color(0xFF6A53A7).withValues(alpha: 0.4)
                      : const Color(0xFFA299C8),
                  borderRadius: BorderRadius.circular(200),
                ),
                alignment: Alignment.center,
                child: Text(
                  _isSending
                      ? '发送中...'
                      : _remaining > 0
                      ? '已发送(${_remaining}s)'
                      : '获取验证码',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.2,
                    color: Colors.white.withValues(alpha: 0.8),
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
