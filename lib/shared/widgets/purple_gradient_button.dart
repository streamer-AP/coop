import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PurpleGradientButton extends StatelessWidget {
  const PurpleGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 42,
    this.enabled = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: width ?? 253,
        height: height,
        decoration: BoxDecoration(
          gradient: enabled
              ? AppColors.purpleButtonGradient
              : const LinearGradient(
                  colors: [Color(0xFFBBBBBB), Color(0xFFCCCCCC)],
                ),
          borderRadius: BorderRadius.circular(25),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
