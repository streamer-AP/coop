import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/omao_page_background.dart';
import '../../../../shared/widgets/purple_gradient_button.dart';
import '../../../../shared/widgets/verification_code_input.dart';
import '../../application/providers/profile_providers.dart';

class ChangePasswordCodeScreen extends ConsumerStatefulWidget {
  const ChangePasswordCodeScreen({super.key});

  @override
  ConsumerState<ChangePasswordCodeScreen> createState() =>
      _ChangePasswordCodeScreenState();
}

class _ChangePasswordCodeScreenState
    extends ConsumerState<ChangePasswordCodeScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static const _labelColor = Color(0xFF000000);
  static const _dividerColor = Color(0x668988AB); // #8988AB @ 0.4

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OmaoPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            '验证码修改',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.8,
              color: Color(0xFF000000),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcons.icon(
                      AppIcons.arrowLeft,
                      size: 20,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
              ),
            ),
          ),
          leadingWidth: 56,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VerificationCodeInput(
                phoneController: _phoneController,
                codeController: _codeController,
                onSendCode:
                    () => ref
                        .read(profileRepositoryProvider)
                        .sendPasswordResetCode(_phoneController.text),
              ),
              const SizedBox(height: 24),
              const Text(
                '输入新密码',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: _labelColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: _labelColor,
                ),
                decoration: const InputDecoration(
                  hintText: '请输入新密码',
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
              const SizedBox(height: 24),
              const Text(
                '再次输入新密码',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: _labelColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: _labelColor,
                ),
                decoration: const InputDecoration(
                  hintText: '再次输入新密码',
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
              const SizedBox(height: 40),
              Center(
                child: PurpleGradientButton(
                  text: '确认',
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('两次输入的密码不一致')));
      }
      return;
    }
    if (_newPasswordController.text.trim().length < 6) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('密码长度至少6位')));
      }
      return;
    }
    try {
      await ref
          .read(profileRepositoryProvider)
          .changePasswordByCode(
            phone: _phoneController.text,
            code: _codeController.text,
            newPassword: _newPasswordController.text,
          );
      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      final message = '$e'.replaceFirst('Exception: ', '').trim();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message.isEmpty ? '修改失败，请重试' : message)),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _PasswordChangeSuccessDialog(
        onConfirm: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.of(context).pop(); // go back
        },
      ),
    );
  }
}

class _PasswordChangeSuccessDialog extends StatelessWidget {
  const _PasswordChangeSuccessDialog({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 344,
        padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 38),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.9),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFEAEAEA).withValues(alpha: 0.95),
              const Color(0xFFEAEAEA).withValues(alpha: 0.7),
              const Color(0xFF634D83).withValues(alpha: 0.8),
            ],
            stops: const [0.02, 0.27, 1.0],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon with gradient circle
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFECF9FD), Color(0xFF533A99)],
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '修改成功',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.6,
                  color: Color(0xFF5B5561),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onConfirm,
                child: Container(
                  width: 128,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A53A7),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '确定',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      decoration: TextDecoration.none,
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
