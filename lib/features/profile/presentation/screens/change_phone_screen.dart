import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/purple_gradient_button.dart';
import '../../../../shared/widgets/verification_code_input.dart';

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
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.profileBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(_currentStep == 0 ? '验证原手机号' : '输入新手机号'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () {
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
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStep1(),
            _buildStep2(),
          ],
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
            onSendCode: () {
              // TODO: send code to old phone
            },
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
            onSendCode: () {
              // TODO: send code to new phone
            },
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: PurpleGradientButton(
              text: '确定修改',
              onPressed: () {
                // TODO: call change phone provider
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
