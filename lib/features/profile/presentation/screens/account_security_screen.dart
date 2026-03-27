import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../application/providers/profile_providers.dart';
import '../widgets/profile_menu_item.dart';

class AccountSecurityScreen extends ConsumerWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final maskedPhone = profileAsync.valueOrNull?.phone ?? '';

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.profileBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('账号与安全'),
          leading: IconButton(
            icon: AppIcons.icon(AppIcons.arrowLeft, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            ProfileMenuItem(
              icon: Icons.smartphone,
              svgPath: AppIcons.phoneCall,
              title: '手机号',
              trailing: Text(
                maskedPhone,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textHint,
                ),
              ),
              onTap: () => context.pushNamed(RouteNames.changePhone),
            ),
            ProfileMenuItem(
              icon: Icons.lock_outline,
              svgPath: AppIcons.lock,
              title: '修改密码',
              onTap: () => context.pushNamed(RouteNames.changePassword),
              showDivider: false,
            ),
            const Divider(height: 24, thickness: 1, color: Color(0xFFE8E8E8)),
            ProfileMenuItem(
              icon: Icons.exit_to_app,
              svgPath: AppIcons.logout,
              title: '退出登录',
              onTap: () => _showLogoutDialog(context, ref),
            ),
            ProfileMenuItem(
              icon: Icons.person_off_outlined,
              title: '注销账号',
              onTap: () => context.pushNamed(RouteNames.deactivateAccount),
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authNotifierProvider.notifier).logout();
              context.goNamed(RouteNames.login);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
