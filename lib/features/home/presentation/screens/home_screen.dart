import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/omao_tab_bar.dart';
import '../../../message/application/providers/message_providers.dart';
import '../../../message/presentation/screens/message_list_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../widgets/home_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadMessageCountProvider).valueOrNull ?? 0;

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              const HomePage(),
              MessageListScreen(isActive: _currentIndex == 1),
              const ProfileScreen(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: OmaoTabBar(
              currentIndex: _currentIndex,
              unreadCount: unreadCount,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
