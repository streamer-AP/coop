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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
      TopBannerToast.show(context, message: '登录前请先阅读并同意相关协议');
      return;
    }
    if (!_canSubmit) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendVerificationCode(_phoneDigits);
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
        'title': '验证码登录',
        'flow': 'login',
      },
    );
    if (code == null || !mounted) return;
    await _loginWithCode(code);
  }

  Future<void> _loginWithCode(String code) async {
    await ref
        .read(authNotifierProvider.notifier)
        .loginWithCode(phone: _phoneDigits, code: code);

    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      TopBannerToast.show(context, message: _errorMsg(authState.error));
      return;
    }

    final user = authState.valueOrNull;
    if (user?.needsPasswordSetup == true) {
      context.goNamed(RouteNames.setupPassword);
    }
  }

  String _errorMsg(Object? error) {
    if (error is AuthException) return error.displayMessage;
    return '操作失败，请重试';
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      heroMode: true,
      showWatermark: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
                    child: AuthBackButton(),
                  ),
                  const SizedBox(height: 52),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: _GreetingBlock(),
                  ),
                  SizedBox(
                    height: (constraints.maxHeight * 0.088).clamp(28.0, 56.0),
                  ),
                  Expanded(
                    child: _LoginSheet(
                      child: LayoutBuilder(
                        builder: (context, sheetConstraints) {
                          return SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: sheetConstraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    30,
                                    56,
                                    30,
                                    22,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Expanded(
                                            child: _LoginTitleArt(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: AuthGhostLink(
                                              label: '注册账号',
                                              onTap:
                                                  () => context.pushNamed(
                                                    RouteNames.register,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 58),
                                      AuthUnderlineField(
                                        label: '输入手机号码',
                                        controller: _phoneController,
                                        hintText: '请输入手机号码',
                                        leadingText: '+86 |',
                                        keyboardType: TextInputType.phone,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
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
                                      const SizedBox(height: 36),
                                      AuthPrimaryButton(
                                        label: '发送验证码',
                                        enabled: _canSubmit,
                                        loading: _isLoading,
                                        onTap:
                                            _canSubmit
                                                ? _sendCodeAndNavigate
                                                : null,
                                      ),
                                      const SizedBox(height: 14),
                                      AuthAgreementRow(
                                        agreed: _agreedToTerms,
                                        onToggle:
                                            () => setState(
                                              () =>
                                                  _agreedToTerms =
                                                      !_agreedToTerms,
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
                                      const Spacer(),
                                      Center(
                                        child: AuthGhostLink(
                                          label: '密码登录',
                                          trailingIcon: const Icon(
                                            Icons.help_outline_rounded,
                                            size: 13,
                                            color: AuthPalette.link,
                                          ),
                                          onTap:
                                              () => context.pushNamed(
                                                RouteNames.passwordLogin,
                                              ),
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
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginSheet extends StatelessWidget {
  const _LoginSheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x2ECDCDF0), Color(0xE6FFFFFF)],
          stops: [0.0, 1.0],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
      ),
      child: child,
    );
  }
}

class _LoginTitleArt extends StatelessWidget {
  const _LoginTitleArt();

  @override
  Widget build(BuildContext context) {
    return const AuthTitleBlock(title: '验证码登录', subtitle: 'Sign In');
  }
}

class _GreetingBlock extends StatelessWidget {
  const _GreetingBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello!',
          style: AuthFonts.englishTextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.95),
            height: 1,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '欢迎来到 ',
                style: AuthFonts.chineseTextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.82),
                  letterSpacing: 0.24,
                ),
              ),
              TextSpan(
                text: 'OMAO',
                style: AuthFonts.englishTextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.82),
                  letterSpacing: 0.24,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
