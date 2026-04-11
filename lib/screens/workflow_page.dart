import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/repo_filter.dart';
import 'package:opendevnote/models/workflow_run.dart';
import 'package:opendevnote/providers/workflow_provider.dart';
import 'package:opendevnote/screens/dialogs/workflow_config_dialog.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';
import 'package:opendevnote/widgets/empty_state.dart';
import 'package:opendevnote/widgets/repo_filter_bar.dart';

class WorkflowPage extends ConsumerStatefulWidget {
  const WorkflowPage({super.key});

  @override
  ConsumerState<WorkflowPage> createState() => _WorkflowPageState();
}

class _WorkflowPageState extends ConsumerState<WorkflowPage> {
  RepoFilter _filter = const RepoFilter();

  @override
  Widget build(BuildContext context) {
    final autoState = ref.watch(autoWorkflowProvider);
    final accounts = ref.watch(githubAccountsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Build sorted list of repos with latest run
    var entries = autoState.runsByRepo.entries.toList();
    entries.sort((a, b) {
      final aLatest = a.value.isNotEmpty
          ? a.value.first.createdAt
          : DateTime(2000);
      final bLatest = b.value.isNotEmpty
          ? b.value.first.createdAt
          : DateTime(2000);
      return bLatest.compareTo(aLatest);
    });

    // Apply filters
    entries = entries.where((e) {
      final parts = e.key.split('/');
      final owner = parts.isNotEmpty ? parts[0] : '';
      final name = parts.length > 1 ? parts[1] : e.key;
      if (!matchesRegex(owner, _filter.ownerPattern)) return false;
      if (!matchesRegex(name, _filter.namePattern)) return false;
      if (_filter.status != null && e.value.isNotEmpty) {
        final run = e.value.first;
        if (_filter.status == 'success' && !run.isSuccess) return false;
        if (_filter.status == 'failure' && !run.isFailure) return false;
        if (_filter.status == 'in_progress' && !run.isInProgress) return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', 'CI/CD Workflows'],
          onTap: [null, null],
        ),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Wdrożenia',
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
                onPressed: accounts.isEmpty
                    ? null
                    : () =>
                          ref.read(autoWorkflowProvider.notifier).discoverAll(),
                tooltip: 'Odśwież',
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 20),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const GithubSettingsDialog(),
                ),
                tooltip: 'Ustawienia',
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Error
        if (autoState.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, size: 16, color: colorScheme.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      autoState.error!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Filter bar
        RepoFilterBar(
          filter: _filter,
          onChanged: (f) => setState(() => _filter = f),
          showStatus: true,
        ),
        // Content
        Expanded(
          child: accounts.isEmpty
              ? EmptyState(
                  title: 'Brak kont GitHub',
                  subtitle: 'Dodaj konto GitHub w ustawieniach',
                )
              : entries.isEmpty && !autoState.isLoading
              ? EmptyState(
                  title: _filter.hasActiveFilters
                      ? 'Brak wyników dla filtrów'
                      : 'Brak repozytoriów z workflows',
                  subtitle: _filter.hasActiveFilters
                      ? 'Zmień filtry, aby zobaczyć repozytoria'
                      : 'Nie znaleziono żadnych repozytoriów z GitHub Actions',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final runs = entry.value;
                    final latestRun = runs.isNotEmpty ? runs.first : null;
                    return _RepoCard(
                      fullName: entry.key,
                      isLoading: autoState.isLoading && runs.isEmpty,
                      latestRun: latestRun,
                      onTap: () {
                        ref.read(selectedWorkflowRepoProvider.notifier).state =
                            entry.key;
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RepoCard extends StatelessWidget {
  final String fullName;
  final bool isLoading;
  final WorkflowRun? latestRun;
  final VoidCallback onTap;

  const _RepoCard({
    required this.fullName,
    required this.isLoading,
    this.latestRun,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.source_outlined,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (latestRun != null)
                    Row(
                      children: [
                        _StatusDot(run: latestRun!),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            latestRun!.displayTitle ??
                                latestRun!.name ??
                                'Run #${latestRun!.runNumber}',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.7,
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
                          _timeAgo(latestRun!.createdAt),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    )
                  else if (isLoading)
                    Text(
                      'Ładowanie...',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 11,
                      ),
                    )
                  else
                    Text(
                      'Brak wdrożeń',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (latestRun != null && !isLoading)
              _BigStatusIcon(run: latestRun!),
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 18,
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

class _StatusDot extends StatelessWidget {
  final WorkflowRun run;

  const _StatusDot({required this.run});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (run.isInProgress) {
      color = Colors.blue;
    } else if (run.isSuccess) {
      color = Colors.green;
    } else if (run.isFailure) {
      color = Colors.red;
    } else {
      color = Colors.grey;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _BigStatusIcon extends StatelessWidget {
  final WorkflowRun run;

  const _BigStatusIcon({required this.run});

  @override
  Widget build(BuildContext context) {
    if (run.isInProgress) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    IconData icon;
    Color color;

    if (run.isSuccess) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (run.conclusion == 'failure') {
      icon = Icons.cancel;
      color = Colors.red;
    } else if (run.conclusion == 'cancelled') {
      icon = Icons.remove_circle_outline;
      color = Colors.orange;
    } else {
      icon = Icons.circle_outlined;
      color = Colors.grey;
    }

    return Icon(icon, size: 22, color: color);
  }
}
