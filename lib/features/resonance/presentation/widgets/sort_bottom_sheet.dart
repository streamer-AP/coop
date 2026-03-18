import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/sort_providers.dart';

class SortBottomSheet extends ConsumerWidget {
  const SortBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => const SortBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(sortModeNotifierProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '排序',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF79747E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      '完成',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _SortOption(
              icon: Icons.sort_by_alpha,
              label: '按字母A-Z排序',
              isSelected: currentMode == SortMode.alphabeticalAsc,
              onTap: () {
                ref
                    .read(sortModeNotifierProvider.notifier)
                    .setSortMode(SortMode.alphabeticalAsc);
              },
            ),
            _SortOption(
              icon: Icons.sort_by_alpha,
              label: '按字母Z-A排序',
              isSelected: currentMode == SortMode.alphabeticalDesc,
              iconTransform: true,
              onTap: () {
                ref
                    .read(sortModeNotifierProvider.notifier)
                    .setSortMode(SortMode.alphabeticalDesc);
              },
            ),
            _SortOption(
              icon: Icons.arrow_upward,
              label: '按时间正序',
              isSelected: currentMode == SortMode.timeAsc,
              onTap: () {
                ref
                    .read(sortModeNotifierProvider.notifier)
                    .setSortMode(SortMode.timeAsc);
              },
            ),
            _SortOption(
              icon: Icons.arrow_downward,
              label: '按时间倒序',
              isSelected: currentMode == SortMode.timeDesc,
              onTap: () {
                ref
                    .read(sortModeNotifierProvider.notifier)
                    .setSortMode(SortMode.timeDesc);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.iconTransform = false,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool iconTransform;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Transform(
        alignment: Alignment.center,
        transform: iconTransform
            ? Matrix4.rotationY(3.14159)
            : Matrix4.identity(),
        child: Icon(
          icon,
          color: isSelected ? AppColors.primary : const Color(0xFF49454F),
          size: 24,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: isSelected ? AppColors.primary : const Color(0xFF1C1B1F),
        ),
      ),
      onTap: onTap,
    );
  }
}
