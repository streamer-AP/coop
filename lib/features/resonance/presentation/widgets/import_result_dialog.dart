import 'package:flutter/material.dart';

import '../../domain/models/import_result.dart';

class ImportResultDialog extends StatelessWidget {
  const ImportResultDialog({
    super.key,
    required this.result,
  });

  final ImportResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Import Complete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${result.succeeded.length} track(s) imported successfully.',
            style: theme.textTheme.bodyMedium,
          ),
          if (result.hasFailures) ...[
            const SizedBox(height: 12),
            Text(
              '${result.failed.length} failed:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: result.failed.length,
                itemBuilder: (context, index) {
                  final failure = result.failed[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '${failure.fileName}: ${failure.reason}',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
