import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/signal_providers.dart';
import '../../domain/models/player_state.dart';

class SignalModeToggle extends ConsumerWidget {
  const SignalModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signalMode = ref.watch(signalModeNotifierProvider);

    return SegmentedButton<SignalMode>(
      segments: const [
        ButtonSegment(
          value: SignalMode.off,
          label: Text('Off'),
          icon: Icon(Icons.bluetooth_disabled),
        ),
        ButtonSegment(
          value: SignalMode.resonance,
          label: Text('Sync'),
          icon: Icon(Icons.sync),
        ),
        ButtonSegment(
          value: SignalMode.preset,
          label: Text('Preset'),
          icon: Icon(Icons.tune),
        ),
      ],
      selected: {signalMode},
      onSelectionChanged: (selected) {
        ref
            .read(signalModeNotifierProvider.notifier)
            .setMode(selected.first);
      },
    );
  }
}
