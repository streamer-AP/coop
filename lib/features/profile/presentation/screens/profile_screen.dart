import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/providers/profile_providers.dart';
import '../../domain/models/profile.dart';
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
                decoration: const BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  children: [
                    ProfileMenuItem(
                      icon: Icons.security_outlined,
                      title: '账号与安全',
                      onTap: () =>
                          context.pushNamed(RouteNames.accountSecurity),
                    ),
                    ProfileMenuItem(
                      icon: Icons.devices_other,
                      title: '设备验证&激活',
                      onTap: () {},
                    ),
                    ProfileMenuItem(
                      icon: Icons.feedback_outlined,
                      title: '建议反馈',
                      onTap: () => context.pushNamed(RouteNames.feedback),
                    ),
                    ProfileMenuItem(
                      icon: Icons.support_agent_outlined,
                      title: '联系我们',
                      onTap: () => context.pushNamed(RouteNames.contact),
                      showDivider: false,
                    ),
                    const Divider(height: 8, thickness: 8, color: AppColors.listBackground),
                    ProfileMenuItem(
                      icon: Icons.description_outlined,
                      title: '用户协议',
                      onTap: () =>
                          context.pushNamed(RouteNames.userAgreement),
                    ),
                    ProfileMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      title: '隐私政策',
                      onTap: () =>
                          context.pushNamed(RouteNames.privacyPolicy),
                    ),
                    ProfileMenuItem(
                      icon: Icons.info_outline,
                      title: 'app信息和备案信息',
                      onTap: () => context.pushNamed(RouteNames.appInfo),
                    ),
                    ProfileMenuItem(
                      icon: Icons.system_update_outlined,
                      title: '版本信息&检查更新',
                      trailing: versionAsync.when(
                        data: (v) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                v.version,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            if (v.hasUpdate)
                              Container(
                                width: 8,
                                height: 8,
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
                          data: (p) => p.nickname ?? '未设置昵称',
                        ) ??
                        '加载中...',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          GlowingAvatar(
            imageUrl: profileAsync.whenOrNull(
              data: (p) => p.avatarUrl,
            ),
            size: 56,
            onTap: () => context.pushNamed(RouteNames.profileEdit),
          ),
        ],
      ),
    );
  }
}
