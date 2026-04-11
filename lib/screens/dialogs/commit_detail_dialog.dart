import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/gh_commit_detail.dart';
import 'package:opendevnote/providers/workflow_provider.dart';
import 'package:opendevnote/screens/file_diff_page.dart';
import 'package:opendevnote/services/github_service.dart';

class CommitDetailDialog extends ConsumerStatefulWidget {
  final String repoFullName;
  final String sha;

  const CommitDetailDialog({
    super.key,
    required this.repoFullName,
    required this.sha,
  });

  @override
  ConsumerState<CommitDetailDialog> createState() => _CommitDetailDialogState();
}

class _CommitDetailDialogState extends ConsumerState<CommitDetailDialog> {
  GhCommitDetail? _detail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final accounts = ref.read(githubAccountsProvider);
    if (accounts.isEmpty) {
      setState(() {
        _error = 'Brak konta GitHub';
        _isLoading = false;
      });
      return;
    }
    final parts = widget.repoFullName.split('/');
    if (parts.length != 2) {
      setState(() {
        _error = 'Nieprawidłowa nazwa repo';
        _isLoading = false;
      });
      return;
    }
    try {
      final service = GithubService();
      final detail = await service.getCommitDetail(
        accounts.first.token,
        parts[0],
        parts[1],
        widget.sha,
      );
      if (mounted) {
        setState(() {
          _detail = detail;
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

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.sha.substring(0, 7),
              style: textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Szczegóły commita', style: textTheme.titleMedium),
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            : _error != null
            ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: TextStyle(color: colorScheme.error),
                ),
              )
            : _detail != null
            ? _buildContent(context, _detail!)
            : const SizedBox.shrink(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Zamknij'),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, GhCommitDetail detail) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              if (detail.authorAvatar.isNotEmpty)
                CircleAvatar(
                  radius: 14,
                  backgroundImage: NetworkImage(detail.authorAvatar),
                )
              else
                CircleAvatar(
                  radius: 14,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    detail.authorName.isNotEmpty
                        ? detail.authorName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.authorName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatDate(detail.date),
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
          const SizedBox(height: 12),
          // Message
          if (detail.message.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(detail.message, style: textTheme.bodySmall),
            ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              Text(
                '+${detail.additions}',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '-${detail.deletions}',
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${detail.totalFiles} plik(ów)',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          // Files list
          Text(
            'Zmodyfikowane pliki',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...detail.files.map(
            (file) => _FileTile(
              file: file,
              onTap: file.patch != null
                  ? () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FileDiffPage(
                            filename: file.filename,
                            patch: file.patch!,
                            status: file.status,
                            additions: file.additions,
                            deletions: file.deletions,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _FileTile extends StatelessWidget {
  final GhFileChange file;
  final VoidCallback? onTap;

  const _FileTile({required this.file, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color statusColor;
    IconData statusIcon;
    switch (file.status) {
      case 'added':
        statusColor = Colors.green;
        statusIcon = Icons.add_circle_outline;
        break;
      case 'removed':
        statusColor = Colors.red;
        statusIcon = Icons.remove_circle_outline;
        break;
      case 'modified':
        statusColor = Colors.orange;
        statusIcon = Icons.edit_outlined;
        break;
      case 'renamed':
        statusColor = Colors.blue;
        statusIcon = Icons.drive_file_rename_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.circle_outlined;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: onTap != null
              ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
              : null,
        ),
        child: Row(
          children: [
            Icon(statusIcon, size: 14, color: statusColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                file.filename,
                style: textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '+${file.additions}',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '-${file.deletions}',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.red,
                fontSize: 10,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 14,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
