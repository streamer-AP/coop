import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class GlowingAvatar extends StatelessWidget {
  const GlowingAvatar({
    super.key,
    this.imageUrl,
    this.size = 72,
    this.onTap,
  });

  final String? imageUrl;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.3),
              AppColors.primary.withValues(alpha: 0.1),
              Colors.transparent,
            ],
            stops: const [0.6, 0.8, 1.0],
          ),
        ),
        child: Center(
          child: Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultIcon(),
                    ),
                  )
                : _defaultIcon(),
          ),
        ),
      ),
    );
  }

  Widget _defaultIcon() {
    return Icon(
      Icons.person,
      size: size * 0.4,
      color: Colors.white.withValues(alpha: 0.8),
    );
  }
}
