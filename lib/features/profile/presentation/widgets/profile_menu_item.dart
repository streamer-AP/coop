import 'package:flutter/material.dart';

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

  static const _iconColor = Color(0xFF6A53A7);
  static const _dividerColor = Color(0x668988AB); // #8988AB @ 0.4

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: svgPath != null
                        ? AppIcons.icon(svgPath!, size: 24, color: _iconColor)
                        : Icon(icon, size: 24, color: _iconColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  trailing!,
                  const SizedBox(width: 4),
                ],
                AppIcons.icon(
                  AppIcons.arrowRight,
                  size: 20,
                  color: const Color(0xFF000000),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: _dividerColor,
            ),
          ),
      ],
    );
  }
}
