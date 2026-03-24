import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../domain/models/audio_collection.dart';

class CollectionCard extends StatelessWidget {
  const CollectionCard({
    super.key,
    required this.collection,
    this.onTap,
    this.onMoreTap,
  });

  final AudioCollection collection;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            CollectionArtwork(coverPath: collection.coverPath),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    collection.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  CollectionCountText(
                    count: collection.entryCount,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF797979),
                      height: 22 / 14,
                    ),
                  ),
                ],
              ),
            ),
            if (onMoreTap != null)
              IconButton(
                icon: AppIcons.icon(
                  AppIcons.more1,
                  size: 20,
                  color: const Color(0xFF79747E),
                ),
                onPressed: onMoreTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
          ],
        ),
      ),
    );
  }
}

class NewCollectionTile extends StatelessWidget {
  const NewCollectionTile({super.key, this.label = '新建合集', this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const CollectionArtwork(isCreateTile: true),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF797979),
                height: 22 / 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CollectionCountText extends StatelessWidget {
  const CollectionCountText({super.key, required this.count, this.textStyle});

  final int count;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        textStyle ?? const TextStyle(fontSize: 14, color: Color(0xFF797979));
    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: '共 '),
          TextSpan(
            text: '$count',
            style: baseStyle.copyWith(color: AppColors.primary),
          ),
          const TextSpan(text: ' 个'),
        ],
      ),
    );
  }
}

class CollectionArtwork extends StatelessWidget {
  const CollectionArtwork({
    super.key,
    this.coverPath,
    this.isCreateTile = false,
  });

  final String? coverPath;
  final bool isCreateTile;

  static const _size = 56.0;
  static const _radius = 6.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: isCreateTile ? _buildCreateTile() : _buildCover(),
      ),
    );
  }

  Widget _buildCreateTile() {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF8B8892)),
      child: Center(child: AppIcons.asset(AppIcons.add, width: 16, height: 16)),
    );
  }

  Widget _buildCover() {
    if (coverPath != null) {
      return Image.file(
        File(coverPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderCover(),
      );
    }
    return _buildPlaceholderCover();
  }

  Widget _buildPlaceholderCover() {
    return Image.asset(
      'assets/figma/player/default_cover.png',
      fit: BoxFit.cover,
    );
  }
}
