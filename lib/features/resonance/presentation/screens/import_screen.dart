import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/providers/import_providers.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _passwordController = TextEditingController();
  bool _usePassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(importProgressNotifierProvider);

    ref.listen(importProgressNotifierProvider, (prev, next) {
      if (next.status == ImportStatus.done && next.result != null) {
        final count = next.result!.succeeded.length;
        if (next.result!.hasFailures) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('格式错误 导入失败'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已成功导入 $count 条音频'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
        ref.read(importProgressNotifierProvider.notifier).reset();
        if (context.mounted) Navigator.of(context).pop();
      }
      if (next.status == ImportStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导入失败: ${next.error}'),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(importProgressNotifierProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('导入')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.file_upload_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              '导入音频文件或压缩包',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '字幕、封面、信号文件将自动匹配',
              style: TextStyle(fontSize: 14, color: Color(0xFF79747E)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SwitchListTile(
              title: const Text('ZIP 密码'),
              value: _usePassword,
              onChanged: (value) => setState(() => _usePassword = value),
              activeThumbColor: AppColors.primary,
            ),
            if (_usePassword)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: '输入 ZIP 密码',
                  ),
                ),
              ),
            const Spacer(),
            if (importState.status == ImportStatus.importing)
              _buildProgressDialog()
            else
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: importState.status == ImportStatus.picking
                      ? null
                      : () {
                          ref
                              .read(importProgressNotifierProvider.notifier)
                              .pickAndImport(
                                zipPassword: _usePassword
                                    ? _passwordController.text
                                    : null,
                              );
                        },
                  icon: const Icon(Icons.folder_open),
                  label: const Text('选择文件'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDialog() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          '解析中...',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF79747E),
          ),
        ),
      ],
    );
  }
}
