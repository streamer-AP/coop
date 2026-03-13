import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          title: const Text('隐私政策'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Text(
            // TODO: load from remote or assets
            '隐私政策内容加载中...',
            style: TextStyle(
              fontSize: 15,
              height: 1.8,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
