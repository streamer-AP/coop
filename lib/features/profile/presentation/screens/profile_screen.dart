import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/top_banner_toast.dart';
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

    return Stack(
      children: [
        const _ProfileBackdrop(),
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context, ref, profileAsync),
              const SizedBox(height: 20),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        border: const Border(
                          top: BorderSide(
                            color: Color(0x19000000),
                            width: 0.5,
                          ),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFFCCCCF0).withValues(alpha: 0.2),
                            Colors.white,
                          ],
                          stops: const [0.0, 1.0],
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
                            showDivider: false,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(
                              height: 24,
                              thickness: 0.5,
                              color: Color(0x668988AB),
                            ),
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
                            icon: Icons.info_outline,
                            svgPath: AppIcons.infoCircle,
                            title: 'app信息和备案信息',
                            onTap: () {},
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
                                      Text(
                                        v.version,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF000000),
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
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<Profile> profileAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      fontWeight: FontWeight.w500,
                      height: 1.0,
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
            size: 80,
            onTap: () => context.pushNamed(RouteNames.profileEdit),
          ),
        ],
      ),
    );
  }

  Future<void> _exportAll(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(resonanceRepositoryProvider);
    final exportService = ExportService(repo);

    final progressNotifier = ValueNotifier<(int, int)>((0, 0));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => Center(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ValueListenableBuilder<(int, int)>(
                  valueListenable: progressNotifier,
                  builder: (_, progress, __) {
                    final current = progress.$1;
                    final total = progress.$2;
                    final ratio = total > 0 ? current / total : 0.0;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '正在打包导出...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: total > 0 ? ratio : null,
                          backgroundColor: const Color(0xFFE0E0E0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6A53A7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          total > 0
                              ? '$current / $total'
                              : '准备中...',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF797979),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
    );

    try {
      final path = await exportService.exportAll(
        onProgress: (current, total) {
          progressNotifier.value = (current, total);
        },
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (path != null) {
        TopBannerToast.show(
          context,
          message: '导出成功：$path',
          isError: false,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      final message = '$e'.replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.isEmpty ? '导出失败' : message)),
      );
    } finally {
      progressNotifier.dispose();
    }
  }
}

class _ProfileAssets {
  const _ProfileAssets._();

  static const background = 'assets/figma/home/home_bg.png';
}

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final contentWidth = math.min(393.0, constraints.maxWidth);
        final scale = contentWidth / 393.0;
        final backgroundHeight = math.max(
          874 * scale,
          constraints.maxHeight + 24 * scale,
        );
        final overlayHeight = math.max(
          857 * scale,
          constraints.maxHeight + 2 * scale,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.background),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                height: constraints.maxHeight,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: -48 * scale,
                      top: -10 * scale,
                      width: 490 * scale,
                      height: backgroundHeight,
                      child: Image.asset(
                        _ProfileAssets.background,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: -1 * scale,
                      width: contentWidth,
                      height: overlayHeight,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(
                            sigmaX: 0.5 * scale,
                            sigmaY: 0.5 * scale,
                          ),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF28307C).withValues(alpha: 0.36),
                                  const Color(0xFFE7EAFF).withValues(alpha: 0.36),
                                ],
                                stops: const [0.10659, 0.69387],
                              ),
                            ),
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.08),
                              Colors.white.withValues(alpha: 0.18),
                            ],
                            stops: const [0.0, 0.68, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
