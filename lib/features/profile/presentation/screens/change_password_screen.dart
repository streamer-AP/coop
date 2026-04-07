import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/omao_page_background.dart';
import '../../application/providers/profile_providers.dart';

class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OmaoPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '修改方式',
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              _OptionCard(
                title: '验证码修改',
                onTap: () => context.pushNamed(RouteNames.changePasswordCode),
              ),
              const SizedBox(height: 16),
              _OptionCard(
                title: '原密码修改',
                onTap:
                    () => context.pushNamed(RouteNames.originalPasswordChange),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class OriginalPasswordScreen extends ConsumerStatefulWidget {
  const OriginalPasswordScreen({super.key});

  @override
  ConsumerState<OriginalPasswordScreen> createState() =>
      _OriginalPasswordScreenState();
}

class _OriginalPasswordScreenState
    extends ConsumerState<OriginalPasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _oldPasswordController.dispose();
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
          automaticallyImplyLeading: false,
          title: const Text(
            '原密码修改',
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '输入原密码',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(_oldPasswordController),
              const SizedBox(height: 24),
              const Text(
                '输入新密码',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(_newPasswordController),
              const SizedBox(height: 24),
              const Text(
                '再次输入新密码',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(_confirmPasswordController),
              if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    _errorText!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.error,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _submit,
                  child: Container(
                    width: 253,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleButtonGradient,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '确认',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
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

  Widget _buildPasswordField(TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        suffixIcon:
            controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.cancel, size: 20),
                  onPressed: () {
                    controller.clear();
                    setState(() {});
                  },
                )
                : null,
        border: const UnderlineInputBorder(),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0x668988AB)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0x668988AB)),
        ),
      ),
      onChanged: (_) => setState(() => _errorText = null),
    );
  }

  void _submit() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorText = '两次输入的密码不一致');
      return;
    }
    if (_newPasswordController.text.length < 6) {
      setState(() => _errorText = '密码长度至少6位');
      return;
    }
    try {
      await ref
          .read(profileRepositoryProvider)
          .changePassword(
            oldPassword: _oldPasswordController.text,
            newPassword: _newPasswordController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('密码修改成功')));
      Navigator.of(context).pop();
    } catch (e) {
      final message = '$e'.replaceFirst('Exception: ', '').trim();
      setState(() => _errorText = message.isEmpty ? '修改失败，请重试' : message);
    }
  }
}
