import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/domain/models/store.model.dart';
import 'package:immich_mobile/entities/store.entity.dart';
import 'package:immich_mobile/extensions/build_context_extensions.dart';
import 'package:immich_mobile/providers/backup/backup.provider.dart';

/// Reports the current state of Immich's backup engine without changing it.
class KakiBackupHealthCard extends ConsumerWidget {
  const KakiBackupHealthCard({super.key});

  String _status(BackupState state, int uploading) {
    if (state.error == BackupError.syncFailed) {
      return 'Sync failed';
    }
    if (state.isSyncing) {
      return 'Syncing library';
    }
    if (uploading > 0) {
      return 'Uploading';
    }
    if (state.remainderCount > 0) {
      return 'Waiting for backup';
    }
    if (state.totalCount == 0) {
      return 'No backup count available';
    }
    return 'Up to date';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupProvider);
    final uploading = state.uploadItems.values.where((item) => item.isFailed != true).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Backup health', style: context.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Backed up: ${state.backupCount}  ·  Remaining: ${state.remainderCount}'),
            Text('Uploading now: $uploading  ·  Failed in this session: ${state.errorCount}'),
            Text('Status: ${_status(state, uploading)}'),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final user = Store.tryGet(StoreKey.currentUser);
                  if (user != null) {
                    await ref.read(backupProvider.notifier).getBackupStatus(user.id);
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh counts'),
              ),
            ),
            const Text(
              'Upload details and failure messages are below. Use the existing backup controls to retry.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
