import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';

class GlowingAvatar extends StatelessWidget {
  const GlowingAvatar({super.key, this.imageUrl, this.size = 72, this.onTap});

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
            child:
                imageUrl != null
                    ? ClipOval(child: _buildAvatarImage(imageUrl!))
                    : _defaultIcon(),
          ),
        ),
      ),
    );
  }

  Widget _defaultIcon() {
    return AppIcons.icon(
      AppIcons.user,
      size: size * 0.4,
      color: Colors.white.withValues(alpha: 0.8),
    );
  }

  Widget _buildAvatarImage(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return _defaultIcon();

    final localPath = _resolveLocalPath(value);
    if (localPath != null) {
      return Image.file(
        File(localPath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultIcon(),
      );
    }

    return Image.network(
      value,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _defaultIcon(),
    );
  }

  String? _resolveLocalPath(String value) {
    if (value.startsWith('file://')) {
      final uri = Uri.tryParse(value);
      if (uri == null) return null;
      return uri.toFilePath();
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return null;
    }

    final file = File(value);
    return file.existsSync() ? file.path : null;
  }
}
