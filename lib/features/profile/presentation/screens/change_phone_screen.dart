import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/omao_page_background.dart';
import '../../../../shared/widgets/purple_gradient_button.dart';
import '../../../../shared/widgets/verification_code_input.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../application/providers/profile_providers.dart';

class ChangePhoneScreen extends ConsumerStatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  ConsumerState<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends ConsumerState<ChangePhoneScreen> {
  final _pageController = PageController();
  final _oldPhoneController = TextEditingController();
  final _oldCodeController = TextEditingController();
  final _newPhoneController = TextEditingController();
  final _newCodeController = TextEditingController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _oldPhoneController.dispose();
    _oldCodeController.dispose();
    _newPhoneController.dispose();
    _newCodeController.dispose();
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
          title: Text(
            _currentStep == 0 ? '验证原手机号' : '输入新手机号',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.8,
              color: Color(0xFF000000),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () {
                if (_currentStep > 0) {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep--);
                } else {
                  Navigator.of(context).pop();
                }
              },
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
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [_buildStep1(), _buildStep2()],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          VerificationCodeInput(
            phoneController: _oldPhoneController,
            codeController: _oldCodeController,
            onSendCode:
                () => ref
                    .read(authNotifierProvider.notifier)
                    .sendVerificationCode(_oldPhoneController.text),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: PurpleGradientButton(
              text: '下一步',
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                setState(() => _currentStep = 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          VerificationCodeInput(
            phoneController: _newPhoneController,
            codeController: _newCodeController,
            onSendCode:
                () => ref
                    .read(authNotifierProvider.notifier)
                    .sendVerificationCode(_newPhoneController.text),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: PurpleGradientButton(
              text: '确定修改',
              onPressed: () async {
                try {
                  await ref
                      .read(profileRepositoryProvider)
                      .changePhone(
                        oldPhone: _oldPhoneController.text,
                        oldCode: _oldCodeController.text,
                        newPhone: _newPhoneController.text,
                        newCode: _newCodeController.text,
                      );
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('手机号修改成功')));
                  Navigator.of(context).pop();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('修改失败，请重试')));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
