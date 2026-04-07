import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/omao_page_background.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OmaoPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          automaticallyImplyLeading: false,
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
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              _QrCard(
                title: '小红书',
                icon: Icons.bookmark_border,
              ),
              SizedBox(height: 24),
              _QrCard(
                title: '企业微信',
                icon: Icons.chat_bubble_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.qr_code,
              size: 120,
              color: AppColors.textPrimary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
