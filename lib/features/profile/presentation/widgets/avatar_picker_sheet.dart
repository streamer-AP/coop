import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/models/avatar_preset.dart';

class AvatarPickerSheet extends StatelessWidget {
  const AvatarPickerSheet({
    super.key,
    this.onPresetSelected,
    this.onCameraSelected,
    this.onGallerySelected,
  });

  final ValueChanged<AvatarPreset>? onPresetSelected;
  final VoidCallback? onCameraSelected;
  final VoidCallback? onGallerySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Text(
                  '取消',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('相册'),
            onTap: () {
              Navigator.of(context).pop();
              onGallerySelected?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('相机'),
            onTap: () {
              Navigator.of(context).pop();
              onCameraSelected?.call();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
