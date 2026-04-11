import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/workflow_run.dart';
import 'package:opendevnote/providers/workflow_provider.dart';
import 'package:opendevnote/screens/dialogs/workflow_detail_dialog.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';
import 'package:opendevnote/widgets/empty_state.dart';

class WorkflowRepoDetailPage extends ConsumerWidget {
  const WorkflowRepoDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repoKey = ref.watch(selectedWorkflowRepoProvider);
    final autoState = ref.watch(autoWorkflowProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (repoKey == null) return const SizedBox.shrink();

    final runs = autoState.runsByRepo[repoKey] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', 'CI/CD Workflows', repoKey],
          onTap: [
            null,
            () => ref.read(selectedWorkflowRepoProvider.notifier).state = null,
            null,
          ],
        ),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                Icons.source_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                repoKey,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (autoState.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () =>
                    ref.read(autoWorkflowProvider.notifier).discoverAll(),
                tooltip: 'Odśwież',
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Runs list
        Expanded(
          child: runs.isEmpty && !autoState.isLoading
              ? const EmptyState(
                  title: 'Brak workflow runs',
                  subtitle: 'Nie znaleziono żadnych wdrożeń',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: runs.length,
                  itemBuilder: (context, index) {
                    final run = runs[index];
                    final parts = repoKey.split('/');
                    return _WorkflowRunCard(
                      run: run,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => WorkflowDetailDialog(
                          run: run,
                          owner: parts[0],
                          repo: parts[1],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _WorkflowRunCard extends StatelessWidget {
  final WorkflowRun run;
  final VoidCallback onTap;

  const _WorkflowRunCard({required this.run, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            _StatusIcon(
              status: run.status,
              conclusion: run.conclusion,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    run.displayTitle ?? run.name ?? 'Run #${run.runNumber}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.fork_right,
                        size: 12,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          run.headBranch ?? '-',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '·',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        _timeAgo(run.createdAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 16,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s temu';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m temu';
    if (diff.inHours < 24) return '${diff.inHours}h temu';
    if (diff.inDays < 7) return '${diff.inDays}d temu';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year.toString().substring(2)}';
  }
}

class _StatusIcon extends StatelessWidget {
  final String? status;
  final String? conclusion;
  final double size;

  const _StatusIcon({required this.status, this.conclusion, this.size = 16});

  @override
  Widget build(BuildContext context) {
    if (status == 'in_progress' || status == 'queued') {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    IconData icon;
    Color color;

    switch (conclusion) {
      case 'success':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'failure':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 'cancelled':
        icon = Icons.remove_circle_outline;
        color = Colors.orange;
        break;
      case 'timed_out':
        icon = Icons.timer_off;
        color = Colors.orange;
        break;
      case 'skipped':
        icon = Icons.skip_next;
        color = Colors.grey;
        break;
      default:
        icon = Icons.circle_outlined;
        color = Colors.grey;
    }

    return Icon(icon, size: size, color: color);
  }
}
