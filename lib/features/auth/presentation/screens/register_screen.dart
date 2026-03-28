import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
import '../../application/providers/auth_providers.dart';
import '../../domain/models/auth_exception.dart';
import '../widgets/auth_chrome.dart';
import '../widgets/auth_fields.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _phoneController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;

  String get _phoneDigits =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  bool get _canSubmit => _phoneDigits.length >= 11;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_handleChanged)
      ..dispose();
    super.dispose();
  }

  void _handleChanged() {
    setState(() {});
  }

  Future<void> _sendCodeAndNavigate() async {
    if (!_agreedToTerms) {
      TopBannerToast.show(context, message: '注册前请先阅读并同意相关协议');
      return;
    }
    if (!_canSubmit) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendVerificationCode(_phoneDigits, isRegister: true);
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        TopBannerToast.show(
          context,
          message: error is AuthException ? error.displayMessage : '验证码发送失败',
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    final code = await context.pushNamed<String>(
      RouteNames.verificationCode,
      queryParameters: {
        'phone': _phoneDigits,
        'title': '验证码注册',
        'flow': 'register',
      },
    );
    if (code == null || !mounted) return;
    _onCodeVerified(code);
  }

  void _onCodeVerified(String code) {
    if (!mounted) return;
    context.pushNamed(
      RouteNames.setupPassword,
      extra: {'phone': _phoneDigits, 'code': code},
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthBackButton(
                          iconColor: AuthPalette.title,
                          backgroundColor: Color(0x40FFFFFF),
                        ),
                        const SizedBox(height: 76),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: AuthTitleBlock(
                            title: '账号注册',
                            subtitle: 'Sign Up',
                          ),
                        ),
                        const SizedBox(height: 76),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              AuthUnderlineField(
                                label: '手机号码',
                                controller: _phoneController,
                                hintText: '请输入手机号码',
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
                              const SizedBox(height: 42),
                              AuthPrimaryButton(
                                label: '发送验证码',
                                enabled: _canSubmit,
                                loading: _isLoading,
                                onTap: _canSubmit ? _sendCodeAndNavigate : null,
                              ),
                              const SizedBox(height: 14),
                              AuthAgreementRow(
                                agreed: _agreedToTerms,
                                onToggle:
                                    () => setState(
                                      () => _agreedToTerms = !_agreedToTerms,
                                    ),
                                onUserAgreementTap:
                                    () => context.pushNamed(
                                      RouteNames.userAgreement,
                                    ),
                                onPrivacyTap:
                                    () => context.pushNamed(
                                      RouteNames.privacyPolicy,
                                    ),
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
          },
        ),
      ),
    );
  }
}
