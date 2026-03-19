import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ImportInstructionSheet extends StatelessWidget {
  const ImportInstructionSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ImportInstructionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '导入说明',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF79747E),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 20),
            const Text(
              '当前支持导入的类型包括媒体文件（音频、视频、字幕/歌词、封面、台本）以及压缩包。压缩包会先进入预览，再导入用户勾选的文件。',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              '当前支持导入的视频，实际上为提取视频中的音频，并在app中存为音频格式',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              '字幕/歌词、封面、台本会按名称自动匹配到对应的音频，匹配不到的资源不会单独导入。',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              '导入的资源中必须至少包含一个音频或视频；普通文件导入仅支持选择同一级目录内的文件。',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  '我已知悉',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
