import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../shared/widgets/omao_page_background.dart';
import '../../../auth/application/providers/auth_providers.dart';
import '../../application/providers/profile_providers.dart';
import '../widgets/profile_menu_item.dart';

class AccountSecurityScreen extends ConsumerWidget {
  const AccountSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final maskedPhone = profileAsync.valueOrNull?.phone ?? '';

    return OmaoPageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            '账号与安全',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.8,
              color: Color(0xFF000000),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcons.icon(
                      AppIcons.arrowLeft,
                      size: 20,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
              ),
            ),
          ),
          leadingWidth: 56,
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF000000).withValues(alpha: 0.5),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                height: 1,
                thickness: 0.5,
                color: Color(0x668988AB),
              ),
            ),
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
