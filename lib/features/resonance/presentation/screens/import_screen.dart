import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../application/models/import_preview.dart';
import '../../application/providers/import_providers.dart';
import '../../domain/models/import_result.dart';
import '../widgets/import_instruction_sheet.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _passwordController = TextEditingController();
  bool _useZipPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(importProgressNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            height: 300,
            decoration: const BoxDecoration(gradient: AppColors.headerGradient),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.listBackground,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        if (importState.error != null)
                          _ErrorBanner(message: importState.error!),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: _buildBody(importState),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 18),
      child: Row(
        children: [
          _buildCircleButton(
            iconWidget: AppIcons.icon(AppIcons.arrowLeft, size: 24),
            onPressed: () => context.pop(),
          ),
          const Expanded(
            child: Text(
              '资源导入',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildCircleButton(
            iconWidget: AppIcons.icon(AppIcons.search01, size: 24),
            onPressed: () => ImportInstructionSheet.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required Widget iconWidget,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: iconWidget,
      ),
    );
  }

  Widget _buildBody(ImportState importState) {
    if (importState.status == ImportStatus.done && importState.result != null) {
      return _ImportResultView(
        result: importState.result!,
        onImportAgain:
            () => ref.read(importProgressNotifierProvider.notifier).reset(),
        onFinish: () async {
          await ref.read(importProgressNotifierProvider.notifier).reset();
          if (mounted) {
            context.pop();
          }
        },
      );
    }

    if (importState.preview != null) {
      return _ImportPreviewView(
        state: importState,
        onReselect: () async {
          await ref.read(importProgressNotifierProvider.notifier).reset();
        },
        onImport:
            () =>
                ref
                    .read(importProgressNotifierProvider.notifier)
                    .importSelected(),
        onToggle:
            (path) => ref
                .read(importProgressNotifierProvider.notifier)
                .togglePreviewSelection(path),
      );
    }

    return _ImportSourceView(
      isPicking: importState.status == ImportStatus.picking,
      isImporting: importState.status == ImportStatus.importing,
      useZipPassword: _useZipPassword,
      passwordController: _passwordController,
      onPasswordToggle: (value) => setState(() => _useZipPassword = value),
      onPickFiles:
          () =>
              ref
                  .read(importProgressNotifierProvider.notifier)
                  .pickFilesForPreview(),
      onPickZip:
          () => ref
              .read(importProgressNotifierProvider.notifier)
              .pickZipForPreview(
                zipPassword:
                    _useZipPassword ? _passwordController.text.trim() : null,
              ),
    );
  }
}

class _ImportSourceView extends StatelessWidget {
  const _ImportSourceView({
    required this.isPicking,
    required this.isImporting,
    required this.useZipPassword,
    required this.passwordController,
    required this.onPasswordToggle,
    required this.onPickFiles,
    required this.onPickZip,
  });

  final bool isPicking;
  final bool isImporting;
  final bool useZipPassword;
  final TextEditingController passwordController;
  final ValueChanged<bool> onPasswordToggle;
  final VoidCallback onPickFiles;
  final VoidCallback onPickZip;

  @override
  Widget build(BuildContext context) {
    final busy = isPicking || isImporting;

    return SingleChildScrollView(
      key: const ValueKey('source'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择导入来源',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '支持音频、视频、字幕、封面、台本和 ZIP 压缩包。视频会自动提取音频后保存。',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          _SourceCard(
            iconWidget: const Icon(Icons.audio_file_outlined, color: AppColors.primary),
            title: '文件导入',
            subtitle: '从同一级目录选择音频、视频和关联资源',
            onTap: busy ? null : onPickFiles,
          ),
          const SizedBox(height: 14),
          _SourceCard(
            iconWidget: AppIcons.icon(AppIcons.archive, size: 24, color: AppColors.primary),
            title: '压缩包导入',
            subtitle: '先预览 ZIP 内容，再选择要导入的文件',
            onTap: busy ? null : onPickZip,
          ),
          const SizedBox(height: 18),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E0EC)),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: useZipPassword,
                  onChanged: busy ? null : onPasswordToggle,
                  activeThumbColor: AppColors.primary,
                  title: const Text(
                    'ZIP 密码',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('加密压缩包可先输入密码后再预览'),
                ),
                if (useZipPassword)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '输入压缩包密码',
                        filled: true,
                        fillColor: const Color(0xFFF6F2FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (busy) ...[
            const SizedBox(height: 24),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 12),
                  Text(
                    '正在读取文件...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ImportPreviewView extends StatelessWidget {
  const _ImportPreviewView({
    required this.state,
    required this.onReselect,
    required this.onImport,
    required this.onToggle,
  });

  final ImportState state;
  final VoidCallback onReselect;
  final VoidCallback onImport;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final preview = state.preview!;
    final importing = state.status == ImportStatus.importing;

    return Column(
      key: ValueKey('preview-${preview.sourceType.name}'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      preview.sourceType == ImportSourceType.zip
                          ? 'ZIP 文件预览'
                          : '文件预览',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFE8FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '已选 ${preview.selectedCount}/${preview.totalSelectableCount}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '音频/视频 ${preview.selectedMediaCount} 条，资源文件会按名称自动匹配到对应条目。',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              if (importing) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value:
                      state.current < 0 || state.total == 0
                          ? null
                          : state.current / state.total,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.primary,
                  backgroundColor: const Color(0xFFE2D8F1),
                ),
                const SizedBox(height: 8),
                Text(
                  state.current < 0
                      ? '正在解压...'
                      : state.total == 0
                      ? '准备中...'
                      : '正在导入 ${state.current}/${state.total}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: preview.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = preview.items[index];
              return _PreviewFileTile(
                item: item,
                enabled: !importing,
                onChanged: item.selectable ? (_) => onToggle(item.path) : null,
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: importing ? null : onReselect,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    side: const BorderSide(color: Color(0xFFD6CCE4)),
                  ),
                  child: const Text('重新选择'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleButtonGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        importing || !preview.hasSelectedMedia
                            ? null
                            : onImport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      disabledForegroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('开始导入'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImportResultView extends StatelessWidget {
  const _ImportResultView({
    required this.result,
    required this.onImportAgain,
    required this.onFinish,
  });

  final ImportResult result;
  final VoidCallback onImportAgain;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7FF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: result.hasFailures
                    ? AppIcons.icon(AppIcons.infoCircle, size: 28, color: AppColors.primary)
                    : AppIcons.icon(AppIcons.circleCheck, size: 28, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  result.hasFailures ? '导入完成，存在部分失败' : '导入完成',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _ResultStatCard(
                label: '成功',
                value: result.succeeded.length.toString(),
              ),
              const SizedBox(width: 12),
              _ResultStatCard(
                label: '失败',
                value: result.failed.length.toString(),
                accent: AppColors.error,
              ),
            ],
          ),
          if (result.failed.isNotEmpty) ...[
            const SizedBox(height: 22),
            const Text(
              '失败原因',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            ...result.failed.map(
              (failure) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF0D7D7)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      failure.fileName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      failure.reason,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onImportAgain,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    side: const BorderSide(color: Color(0xFFD6CCE4)),
                  ),
                  child: const Text('继续导入'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleButtonGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ElevatedButton(
                    onPressed: onFinish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('返回全部'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.iconWidget,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Widget iconWidget;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EBFA),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: iconWidget,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              AppIcons.icon(AppIcons.arrowRight, size: 24, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewFileTile extends StatelessWidget {
  const _PreviewFileTile({
    required this.item,
    required this.enabled,
    this.onChanged,
  });

  final ImportPreviewItem item;
  final bool enabled;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: CheckboxListTile(
        value: item.selectable ? item.selected : false,
        onChanged: enabled ? onChanged : null,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppColors.primary,
        title: Text(
          item.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: item.selectable ? AppColors.textPrimary : AppColors.textHint,
          ),
        ),
        subtitle: Text(
          item.matchedTo != null
              ? '${_typeLabel(item.type)} → ${item.matchedTo}'
              : _typeLabel(item.type),
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  static String _typeLabel(ImportPreviewItemType type) {
    switch (type) {
      case ImportPreviewItemType.audio:
        return '音频';
      case ImportPreviewItemType.video:
        return '视频，导入后会提取音频';
      case ImportPreviewItemType.subtitle:
        return '字幕';
      case ImportPreviewItemType.cover:
        return '封面';
      case ImportPreviewItemType.script:
        return '台本';
      case ImportPreviewItemType.signal:
        return '蓝牙信号';
      case ImportPreviewItemType.unsupported:
        return '暂不支持的文件类型';
    }
  }
}

class _ResultStatCard extends StatelessWidget {
  const _ResultStatCard({
    required this.label,
    required this.value,
    this.accent = AppColors.primary,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF4C7C3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
