import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
import '../../domain/models/auth_exception.dart';
import '../widgets/auth_chrome.dart';
import '../widgets/auth_fields.dart';
import 'verification_code_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  String get _phoneDigits =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _sendCodeAndNavigate() async {
    if (_phoneDigits.length < 11) {
      TopBannerToast.show(context, message: '请输入正确的手机号码');
      return;
    }
    if (_passwordController.text.length < 6) {
      TopBannerToast.show(context, message: '请输入至少6位密码');
      return;
    }
    if (_passwordController.text != _confirmController.text) {
      TopBannerToast.show(context, message: '密码输入不一致，请重新输入');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(apiClientProvider)
          .post(
            ApiEndpoints.forgotPwdSendCode,
            queryParameters: {'mobile': _phoneDigits},
          );
    } catch (e) {
      if (mounted) {
        TopBannerToast.show(
          context,
          message: e is AuthException ? e.displayMessage : '验证码发送失败',
        );
      }
      rethrow;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => VerificationCodeScreen(
              phone: _phoneDigits,
              title: '重置密码',
              onVerified: _resetPassword,
              onResendCode: () async {
                await ref
                    .read(apiClientProvider)
                    .post(
                      ApiEndpoints.forgotPwdSendCode,
                      queryParameters: {'mobile': _phoneDigits},
                    );
              },
            ),
      ),
    );
  }

  Future<void> _resetPassword(String code) async {
    try {
      await ref
          .read(apiClientProvider)
          .post(
            ApiEndpoints.forgotPwd,
            queryParameters: {
              'mobile': _phoneDigits,
              'code': code,
              'newPwd': _passwordController.text,
            },
          );
    } catch (_) {
      if (mounted) {
        TopBannerToast.show(context, message: '重置失败，请重试');
      }
      return;
    }

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 304,
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  const Color(0xFFF1ECFF).withValues(alpha: 0.94),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5F5382).withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF12BE6C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '密码重置成功',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AuthPalette.title,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 116,
                  child: AuthPrimaryButton(
                    label: '确定',
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context)
                        ..pop()
                        ..pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                const SizedBox(height: 76),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: AuthPageTitle(title: '重置密码', subtitle: 'Password'),
                ),
                const SizedBox(height: 76),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuthUnderlineField(
                        label: '输入手机号码',
                        controller: _phoneController,
                        hintText: '请输入手机号',
                        leadingText: '+86 |',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ChinesePhoneNumberFormatter(),
                        ],
                        trailing:
                            _phoneController.text.isEmpty
                                ? null
                                : AuthClearButton(
                                  onTap: () {
                                    _phoneController.clear();
                                    setState(() {});
                                  },
                                ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 28),
                      AuthUnderlineField(
                        label: '输入新密码',
                        controller: _passwordController,
                        hintText: '请输入新密码',
                        obscureText: true,
                        trailing:
                            _passwordController.text.isEmpty
                                ? null
                                : AuthClearButton(
                                  onTap: () {
                                    _passwordController.clear();
                                    setState(() {});
                                  },
                                ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 28),
                      AuthUnderlineField(
                        label: '再次输入新密码',
                        controller: _confirmController,
                        hintText: '再次输入新密码',
                        obscureText: true,
                        trailing:
                            _confirmController.text.isEmpty
                                ? null
                                : AuthClearButton(
                                  onTap: () {
                                    _confirmController.clear();
                                    setState(() {});
                                  },
                                ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 42),
                      AuthPrimaryButton(
                        label: '发送验证码',
                        loading: _isLoading,
                        onTap: () async {
                          try {
                            await _sendCodeAndNavigate();
                          } catch (_) {}
                        },
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
