import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/signal_providers.dart';
import '../../domain/models/player_state.dart';

class SignalModeToggle extends ConsumerWidget {
  const SignalModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signalMode = ref.watch(signalModeNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(
            icon: Icons.bluetooth_disabled,
            label: '关闭',
            isSelected: signalMode == SignalMode.off,
            onTap: () => ref
                .read(signalModeNotifierProvider.notifier)
                .setMode(SignalMode.off),
          ),
          _buildSegment(
            icon: Icons.sync,
            label: '同步',
            isSelected: signalMode == SignalMode.resonance,
            onTap: () => ref
                .read(signalModeNotifierProvider.notifier)
                .setMode(SignalMode.resonance),
          ),
          _buildSegment(
            icon: Icons.tune,
            label: '预设',
            isSelected: signalMode == SignalMode.preset,
            onTap: () => ref
                .read(signalModeNotifierProvider.notifier)
                .setMode(SignalMode.preset),
          ),
        ],
      ),
    );
  }

  Widget _buildSegment({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
