import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/import_providers.dart';
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
                    child: const Icon(
                      Icons.help_outline,
                      color: Color(0xFF79747E),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _SourceOption(
              icon: Icons.folder_outlined,
              label: '文件',
              onTap: () {
                Navigator.of(context).pop();
                ref
                    .read(importProgressNotifierProvider.notifier)
                    .pickAndImport();
              },
            ),
            _SourceOption(
              icon: Icons.archive_outlined,
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
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
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
                Icon(icon, color: const Color(0xFF49454F), size: 24),
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
