import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../resonance/application/providers/resonance_providers.dart';
import '../../../resonance/application/services/export_service.dart';
import '../../application/providers/profile_providers.dart';
import '../../domain/models/profile.dart';
import '../widgets/device_activation_dialog.dart';
import '../widgets/glowing_avatar.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final versionAsync = ref.watch(appVersionProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.profileBackgroundGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context, ref, profileAsync),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  children: [
                    ProfileMenuItem(
                      icon: Icons.security_outlined,
                      svgPath: AppIcons.accountSecurity,
                      title: '账号与安全',
                      onTap:
                          () => context.pushNamed(RouteNames.accountSecurity),
                    ),
                    ProfileMenuItem(
                      icon: Icons.devices_other,
                      svgPath: AppIcons.deviceLink,
                      title: '设备验证&激活',
                      onTap: () => DeviceActivationDialog.show(context),
                    ),
                    ProfileMenuItem(
                      icon: Icons.file_download_outlined,
                      svgPath: AppIcons.exportIcon,
                      title: '一键导出本地音声',
                      onTap: () => _exportAll(context, ref),
                    ),
                    ProfileMenuItem(
                      icon: Icons.feedback_outlined,
                      svgPath: AppIcons.notificationSquare,
                      title: '建议反馈',
                      onTap: () => context.pushNamed(RouteNames.feedback),
                    ),
                    ProfileMenuItem(
                      icon: Icons.support_agent_outlined,
                      svgPath: AppIcons.phoneCall,
                      title: '联系我们',
                      onTap: () => context.pushNamed(RouteNames.contact),
                    ),
                    ProfileMenuItem(
                      icon: Icons.description_outlined,
                      svgPath: AppIcons.fileEdit,
                      title: '用户协议',
                      onTap: () => context.pushNamed(RouteNames.userAgreement),
                    ),
                    ProfileMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      svgPath: AppIcons.fileEye,
                      title: '隐私政策',
                      onTap: () => context.pushNamed(RouteNames.privacyPolicy),
                    ),
                    ProfileMenuItem(
                      icon: Icons.system_update_outlined,
                      svgPath: AppIcons.send01,
                      title: '版本信息&检查更新',
                      trailing: versionAsync.when(
                        data:
                            (v) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    v.version,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                if (v.hasUpdate)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(left: 4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.unreadDot,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      showDivider: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Profile> profileAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.pushNamed(RouteNames.profileEdit),
              child: Row(
                children: [
                  Text(
                    profileAsync.whenOrNull(
                          data: (p) {
                            final nickname = p.nickname?.trim();
                            return nickname == null || nickname.isEmpty
                                ? '未设置昵称'
                                : nickname;
                          },
                        ) ??
                        '加载中...',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AppIcons.icon(
                    AppIcons.arrowRight,
                    size: 24,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          GlowingAvatar(
            imageUrl: profileAsync.whenOrNull(data: (p) => p.avatarUrl),
            size: 56,
            onTap: () => context.pushNamed(RouteNames.profileEdit),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAll(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(resonanceRepositoryProvider);
    final exportService = ExportService(repo);

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在打包导出...'),
                  ],
                ),
              ),
            ),
          ),
    );

    try {
      final path = await exportService.exportAll();
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close progress dialog
      if (path != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('导出成功')));
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // close progress dialog
      final message = '$e'.replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? '导出失败' : message)),
      );
    }
  }
}
