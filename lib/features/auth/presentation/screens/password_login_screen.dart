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

class PasswordLoginScreen extends ConsumerStatefulWidget {
  const PasswordLoginScreen({super.key});

  @override
  ConsumerState<PasswordLoginScreen> createState() =>
      _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends ConsumerState<PasswordLoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;

  String get _phoneDigits =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  bool get _canLogin =>
      _phoneDigits.length >= 11 && _passwordController.text.length >= 6;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_handleChanged);
    _passwordController.addListener(_handleChanged);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_handleChanged)
      ..dispose();
    _passwordController
      ..removeListener(_handleChanged)
      ..dispose();
    super.dispose();
  }

  void _handleChanged() {
    setState(() {});
  }

  Future<void> _login() async {
    if (!_agreedToTerms) {
      TopBannerToast.show(context, message: '登录前请先阅读并同意相关协议');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .loginWithPassword(
            phone: _phoneDigits,
            password: _passwordController.text,
          );
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isLoading = false);

    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      TopBannerToast.show(
        context,
        message:
            authState.error is AuthException
                ? (authState.error as AuthException).displayMessage
                : '手机号或密码错误，请重新输入',
      );
    }
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
                    padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AuthBackButton(
                          iconColor: AuthPalette.title,
                          backgroundColor: Color(0x40FFFFFF),
                        ),
                        const SizedBox(height: 78),
                        const _PasswordTitleArt(),
                        const SizedBox(height: 74),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              const SizedBox(height: 34),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '密码',
                                        style: AuthFonts.chineseTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AuthPalette.body,
                                        ),
                                      ),
                                      AuthGhostLink(
                                        label: '忘记密码',
                                        onTap:
                                            () => context.pushNamed(
                                              RouteNames.forgotPassword,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  AuthUnderlineField(
                                    controller: _passwordController,
                                    hintText: '请输入密码',
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
                                ],
                              ),
                              const SizedBox(height: 42),
                              AuthPrimaryButton(
                                label: '登录',
                                enabled: _canLogin,
                                loading: _isLoading,
                                onTap: _canLogin ? _login : null,
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

class _PasswordTitleArt extends StatelessWidget {
  const _PasswordTitleArt();

  @override
  Widget build(BuildContext context) {
    return const AuthTitleBlock(title: '密码登录', subtitle: 'Password');
  }
}
