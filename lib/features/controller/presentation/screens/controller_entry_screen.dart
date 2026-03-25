import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/controller_providers.dart';
import 'controller_screen.dart';
import 'controller_screen_backup.dart';
import 'first_connection_screen.dart';

class ControllerEntryScreen extends ConsumerWidget {
  const ControllerEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBindingAsync = ref.watch(activeDeviceBindingProvider);

    return activeBindingAsync.when(
      data: (binding) {
        if (binding == null) {
          return const ControllerScreenBackup();
        }
        return const ControllerScreenBackup();
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (_, __) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }
}
