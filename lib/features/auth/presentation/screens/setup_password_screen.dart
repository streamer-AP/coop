import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
import '../../application/providers/auth_providers.dart';
import '../../../profile/presentation/widgets/glowing_avatar.dart';

class SetupPasswordScreen extends ConsumerStatefulWidget {
  const SetupPasswordScreen({super.key});

  @override
  ConsumerState<SetupPasswordScreen> createState() =>
      _SetupPasswordScreenState();
}

class _SetupPasswordScreenState extends ConsumerState<SetupPasswordScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  static const _maxNameLength = 8;

  bool get _canSubmit =>
      _passwordController.text.length >= 6;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .setupPassword(_passwordController.text);
      if (mounted) {
        context.goNamed(RouteNames.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        TopBannerToast.show(context, message: '设置失败，请重试');
      }
    }
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Avatar
              const GlowingAvatar(size: 100),
              const SizedBox(height: 40),
              // Username
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  '用户名',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                maxLength: _maxNameLength,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '请输入不超过8个字符用户名',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  counterText: '',
                  suffixText:
                      '${_usernameController.text.length}/$_maxNameLength',
                  suffixStyle: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textHint,
                  ),
                  border: const UnderlineInputBorder(),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              // Password
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  '密码',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '请输入密码',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  suffixIcon: _passwordController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.cancel,
                              size: 18, color: AppColors.textHint),
                          onPressed: () {
                            _passwordController.clear();
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
              const SizedBox(height: 40),
              // Submit button
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: (_canSubmit && !_isLoading) ? _submit : null,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: _canSubmit
                          ? AppColors.purpleButtonGradient
                          : const LinearGradient(
                              colors: [Color(0xFFCCCCCC), Color(0xFFDDDDDD)],
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
                            '完成',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
}
