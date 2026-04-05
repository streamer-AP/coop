import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';

class VerificationResultDialog extends StatelessWidget {
  const VerificationResultDialog._({
    required this.svgPath,
    required this.iconGradientColors,
    required this.title,
    this.subtitle,
  });

  final String svgPath;
  final List<Color> iconGradientColors;
  final String title;
  final String? subtitle;

  static Future<void> showSuccess(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const VerificationResultDialog._(
        svgPath: AppIcons.success,
        iconGradientColors: [Color(0xFFECF9FD), Color(0xFF533A99)],
        title: '年龄认证通过，欢迎体验',
      ),
    );
  }

  static Future<void> showFailed(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const VerificationResultDialog._(
        svgPath: AppIcons.fail,
        iconGradientColors: [Color(0xFFFDECEC), Color(0xFF993A3A)],
        title: '实名不匹配or信息有误',
      ),
    );
  }

  static Future<void> showUnderage(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const VerificationResultDialog._(
        svgPath: AppIcons.fail,
        iconGradientColors: [Color(0xFFFDECEC), Color(0xFF993A3A)],
        title: '年龄验证不通过',
        subtitle: '很抱歉，根据相关法律法规要求，此功能仅面对成年用户开放。',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 344,
        padding: const EdgeInsets.symmetric(horizontal: 38, vertical: 38),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.9),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFEAEAEA).withValues(alpha: 0.95),
              const Color(0xFFEAEAEA).withValues(alpha: 0.7),
              const Color(0xFF634D83).withValues(alpha: 0.8),
            ],
            stops: const [0.02, 0.27, 1.0],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: iconGradientColors,
                  ),
                ),
                child: Center(
                  child: AppIcons.icon(svgPath, size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.6,
                  color: Color(0xFF5B5561),
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF5B5561),
                    height: 1.5,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 128,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A53A7),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '确定',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      decoration: TextDecoration.none,
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
