import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/import_providers.dart';
import '../../../../core/theme/app_icons.dart';
import 'import_instruction_sheet.dart';

/// Bottom sheet for choosing import source: files or zip archive.
/// Matches Figma design: 初始进入状态 - 点击导入按钮.png
class ImportSourceSheet extends ConsumerWidget {
  const ImportSourceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => const ImportSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    '导入',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF79747E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();
                      await ImportInstructionSheet.show(context);
                    },
                    child: AppIcons.icon(AppIcons.search01, size: 22, color: const Color(0xFF79747E)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _SourceOption(
              svgPath: AppIcons.file,
              label: '文件',
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(importProgressNotifierProvider.notifier)
                    .pickAndImport();
              },
            ),
            _SourceOption(
              svgPath: AppIcons.archive,
              label: '压缩包',
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(importProgressNotifierProvider.notifier)
                    .pickZipAndImport();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.svgPath,
    required this.label,
    required this.onTap,
  });

  final String svgPath;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                AppIcons.icon(svgPath, size: 24, color: const Color(0xFF49454F)),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1C1B1F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
