import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.svgPath,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? svgPath;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                svgPath != null
                    ? AppIcons.icon(svgPath!, size: 22, color: AppColors.textPrimary)
                    : Icon(icon, size: 22, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
                AppIcons.icon(AppIcons.arrowRight, size: 20, color: AppColors.textHint),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 54,
            endIndent: 20,
            color: Colors.white.withValues(alpha: 0.3),
          ),
      ],
    );
  }
}
