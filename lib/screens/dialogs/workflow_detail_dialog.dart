import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/workflow_job.dart';
import 'package:opendevnote/models/workflow_run.dart';
import 'package:opendevnote/providers/workflow_provider.dart';

class WorkflowDetailDialog extends ConsumerStatefulWidget {
  final WorkflowRun run;
  final String owner;
  final String repo;

  const WorkflowDetailDialog({
    super.key,
    required this.run,
    required this.owner,
    required this.repo,
  });

  @override
  ConsumerState<WorkflowDetailDialog> createState() =>
      _WorkflowDetailDialogState();
}

class _WorkflowDetailDialogState extends ConsumerState<WorkflowDetailDialog> {
  List<WorkflowJob>? _jobs;
  bool _isLoading = true;
  String? _error;

  bool get _isOldRun =>
      DateTime.now().difference(widget.run.createdAt).inDays > 90;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      final jobs = await ref
          .read(autoWorkflowProvider.notifier)
          .fetchJobs(widget.owner, widget.repo, widget.run.id);
      if (mounted) {
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final run = widget.run;

    return AlertDialog(
      title: Row(
        children: [
          _StatusIcon(status: run.status, conclusion: run.conclusion, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              run.displayTitle ?? run.name ?? 'Workflow Run',
              style: textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Run info
              _InfoRow(label: 'Repo', value: '${widget.owner}/${widget.repo}'),
              _InfoRow(label: 'Branch', value: run.headBranch ?? '-'),
              _InfoRow(label: 'Workflow', value: run.name ?? '-'),
              _InfoRow(label: 'Run #', value: '${run.runNumber}'),
              _InfoRow(label: 'Status', value: _statusLabel(run)),
              if (run.actorLogin != null)
                _InfoRow(label: 'Actor', value: run.actorLogin!),
              if (run.event != null)
                _InfoRow(label: 'Event', value: run.event!),
              _InfoRow(label: 'Utworzono', value: _formatDate(run.createdAt)),
              if (run.commitMessage != null)
                _InfoRow(
                  label: 'Commit',
                  value: run.commitMessage!.split('\n').first,
                ),
              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              // Jobs
              Text(
                'Joby',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                )
              else if (_jobs != null && _jobs!.isNotEmpty)
                ..._jobs!.map((job) => _JobTile(job: job))
              else
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _isOldRun
                        ? 'GitHub usunął dane jobów po 90 dniach przechowywania.'
                        : 'Brak jobów',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Zamknij'),
        ),
      ],
    );
  }

  String _statusLabel(WorkflowRun run) {
    if (run.isInProgress) return 'W trakcie';
    if (run.isSuccess) return 'Sukces';
    if (run.conclusion == 'failure') return 'Niepowodzenie';
    if (run.conclusion == 'cancelled') return 'Anulowany';
    if (run.conclusion == 'timed_out') return 'Timeout';
    return run.conclusion ?? run.status ?? '-';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobTile extends StatefulWidget {
  final WorkflowJob job;

  const _JobTile({required this.job});

  @override
  State<_JobTile> createState() => _JobTileState();
}

class _JobTileState extends State<_JobTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final job = widget.job;

    final duration = job.duration;
    final durationText = duration != null
        ? '${duration.inMinutes}m ${duration.inSeconds % 60}s'
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _StatusIcon(
                    status: job.status,
                    conclusion: job.conclusion,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.name,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (job.runnerName != null)
                          Text(
                            '${job.runnerName} · $durationText',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 11,
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded && job.steps.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 36, right: 12, bottom: 8),
              child: Column(
                children: job.steps.map((step) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        _StepIcon(step: step),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.name,
                            style: textTheme.bodySmall?.copyWith(
                              color: step.isFailure
                                  ? colorScheme.error
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          if (_expanded && job.steps.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 36, right: 12, bottom: 8),
              child: Text(
                'Brak danych o etapach (GitHub usuwa je po 90 dniach)',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
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

class _StepIcon extends StatelessWidget {
  final WorkflowStep step;

  const _StepIcon({required this.step});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (step.isInProgress) {
      return SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: colorScheme.primary,
        ),
      );
    }

    IconData icon;
    Color color;

    if (step.isSuccess) {
      icon = Icons.check_circle_outline;
      color = Colors.green;
    } else if (step.isFailure) {
      icon = Icons.cancel_outlined;
      color = Colors.red;
    } else {
      icon = Icons.circle_outlined;
      color = colorScheme.onSurfaceVariant.withValues(alpha: 0.4);
    }

    return Icon(icon, size: 14, color: color);
  }
}
