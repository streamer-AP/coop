import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
import '../../application/providers/auth_providers.dart';
import '../../domain/models/auth_exception.dart';
import '../../../profile/application/providers/profile_providers.dart';
import '../widgets/auth_chrome.dart';
import '../widgets/auth_fields.dart';

class SetupPasswordScreen extends ConsumerStatefulWidget {
  const SetupPasswordScreen({
    super.key,
    required this.phone,
    required this.code,
  });

  final String phone;
  final String code;

  @override
  ConsumerState<SetupPasswordScreen> createState() =>
      _SetupPasswordScreenState();
}

class _SetupPasswordScreenState extends ConsumerState<SetupPasswordScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  static const _maxNameLength = 8;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      TopBannerToast.show(context, message: '请输入用户名');
      return;
    }
    if (_passwordController.text.length < 6) {
      TopBannerToast.show(context, message: '请输入至少6位密码');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).register(
            phone: widget.phone,
            code: widget.code,
            password: _passwordController.text,
          );

      if (!mounted) return;
      final authState = ref.read(authNotifierProvider);
      if (authState.hasError) {
        TopBannerToast.show(
          context,
          message:
              authState.error is AuthException
                  ? (authState.error as AuthException).displayMessage
                  : '注册失败',
        );
        return;
      }

      await ref.read(profileNotifierProvider.notifier).updateNickname(username);
      ref.read(authNotifierProvider.notifier).updateNicknameLocally(username);
      if (mounted) {
        context.goNamed(RouteNames.home);
      }
    } catch (e) {
      if (mounted) {
        TopBannerToast.show(
          context,
          message:
              e is AuthException ? e.displayMessage : '设置失败，请重试',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AuthBackButton(onTap: () => Navigator.of(context).pop()),
                const SizedBox(height: 88),
                const Center(child: _SetupAvatar()),
                const SizedBox(height: 86),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AuthFieldLabel(label: '用户名'),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _usernameController,
                        maxLength: _maxNameLength,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AuthPalette.title,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: authUnderlineInputDecoration(
                          hintText: '请输入不超过8个字符用户名',
                          suffixText:
                              '${_usernameController.text.length}/$_maxNameLength',
                          counterText: '',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 28),
                      const AuthFieldLabel(label: '密码'),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AuthPalette.title,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: authUnderlineInputDecoration(
                          hintText: '请输入密码',
                          suffixIcon:
                              _passwordController.text.isNotEmpty
                                  ? Padding(
                                    padding: const EdgeInsets.only(right: 2),
                                    child: AuthClearButton(
                                      onTap: () {
                                        _passwordController.clear();
                                        setState(() {});
                                      },
                                    ),
                                  )
                                  : null,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 34),
                      AuthPrimaryButton(
                        label: '完成',
                        loading: _isLoading,
                        onTap: _submit,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupAvatar extends StatelessWidget {
  const _SetupAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFF5B8CC), Color(0xFFC5B6F6), Color(0x44FFFFFF)],
          stops: [0.0, 0.7, 1.0],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          const BoxShadow(
            color: Color(0x66FFFFFF),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.air_rounded,
          size: 38,
          color: Color(0xFFFFF2A0),
        ),
      ),
    );
  }
}
