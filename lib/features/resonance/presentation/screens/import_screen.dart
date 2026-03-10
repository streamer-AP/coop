import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/import_providers.dart';
import '../widgets/import_result_dialog.dart';

class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _passwordController = TextEditingController();
  bool _usePassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final importState = ref.watch(importProgressNotifierProvider);
    final theme = Theme.of(context);

    ref.listen(importProgressNotifierProvider, (prev, next) {
      if (next.status == ImportStatus.done && next.result != null) {
        showDialog(
          context: context,
          builder: (_) => ImportResultDialog(result: next.result!),
        ).then((_) {
          ref.read(importProgressNotifierProvider.notifier).reset();
          if (context.mounted) Navigator.of(context).pop();
        });
      }
      if (next.status == ImportStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: ${next.error}')),
        );
        ref.read(importProgressNotifierProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Import')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.file_upload_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Import audio files or ZIP archives',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Subtitles, covers, and signal files will be auto-matched.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SwitchListTile(
              title: const Text('ZIP password'),
              value: _usePassword,
              onChanged: (value) => setState(() => _usePassword = value),
            ),
            if (_usePassword)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter ZIP password',
                  ),
                ),
              ),
            const Spacer(),
            if (importState.status == ImportStatus.importing)
              const Center(child: CircularProgressIndicator())
            else
              FilledButton.icon(
                onPressed: importState.status == ImportStatus.picking
                    ? null
                    : () {
                        ref
                            .read(importProgressNotifierProvider.notifier)
                            .pickAndImport(
                              zipPassword: _usePassword
                                  ? _passwordController.text
                                  : null,
                            );
                      },
                icon: const Icon(Icons.folder_open),
                label: const Text('Select Files'),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
