import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/gh_issue.dart';
import 'package:opendevnote/models/gh_issue_comment.dart';
import 'package:opendevnote/providers/issues_provider.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';

class IssueDetailPage extends ConsumerStatefulWidget {
  final String repoKey;
  final int issueNumber;

  const IssueDetailPage({
    super.key,
    required this.repoKey,
    required this.issueNumber,
  });

  @override
  ConsumerState<IssueDetailPage> createState() => _IssueDetailPageState();
}

class _IssueDetailPageState extends ConsumerState<IssueDetailPage> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(
            issueCommentsProvider((
              widget.repoKey,
              widget.issueNumber,
            )).notifier,
          )
          .load();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final issueAsync = ref.watch(
      issueDetailProvider((widget.repoKey, widget.issueNumber)),
    );
    final commentsState = ref.watch(
      issueCommentsProvider((widget.repoKey, widget.issueNumber)),
    );

    return issueAsync.when(
      data: (issue) => _buildIssueDetail(
        context,
        issue,
        commentsState,
        l10n,
        colorScheme,
        textTheme,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildIssueDetail(
    BuildContext context,
    GhIssue issue,
    IssueCommentsState commentsState,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        AppBreadcrumb(
          items: [
            'OpenDevNote',
            l10n.navigationIssues,
            '${widget.repoKey} #${issue.number}',
          ],
          onTap: [
            null,
            () {
              ref.read(selectedIssueRepoProvider.notifier).state = null;
              ref.read(selectedIssueNumberProvider.notifier).state = null;
            },
            null,
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                issue.state == 'open'
                    ? Icons.error_outline
                    : Icons.check_circle_outline,
                size: 20,
                color: issue.state == 'open' ? Colors.green : Colors.purple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  issue.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                tooltip: l10n.buttonEdit,
                onPressed: () => _editIssue(context, issue),
              ),
              IconButton(
                icon: Icon(
                  issue.state == 'open' ? Icons.check : Icons.refresh,
                  size: 20,
                ),
                tooltip: issue.state == 'open'
                    ? l10n.buttonCloseIssue
                    : l10n.buttonReopen,
                onPressed: () => _toggleIssueState(context, issue),
              ),
            ],
          ),
        ),
        if (issue.body != null && issue.body!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(issue.body!, style: textTheme.bodyMedium),
          ),
        _buildMetadataRow(issue, l10n, colorScheme, textTheme),
        const Divider(height: 24),
        _SectionHeader(title: l10n.labelComments),
        if (commentsState.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (commentsState.error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              commentsState.error!,
              style: TextStyle(color: colorScheme.error),
            ),
          )
        else ...[
          ...commentsState.comments.map(
            (c) => _CommentTile(
              comment: c,
              l10n: l10n,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: l10n.placeholderEnterComment,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.send),
                onPressed: () => _addComment(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildMetadataRow(
    GhIssue issue,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _MetadataChip(icon: Icons.person_outline, label: issue.userLogin),
        _MetadataChip(
          icon: Icons.calendar_today_outlined,
          label:
              '${issue.createdAt.day.toString().padLeft(2, '0')}.${issue.createdAt.month.toString().padLeft(2, '0')}.${issue.createdAt.year}',
        ),
        if (issue.labels.isNotEmpty)
          ...issue.labels.map(
            (label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _parseLabelColor(label.color).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label.name,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: _parseLabelColor(label.color),
                ),
              ),
            ),
          ),
        if (issue.assignees.isNotEmpty)
          _MetadataChip(
            icon: Icons.person_add_outlined,
            label: issue.assignees.map((a) => a.login).join(', '),
          ),
        if (issue.milestone != null)
          _MetadataChip(
            icon: Icons.flag_outlined,
            label: issue.milestone!.title,
          ),
      ],
    );
  }

  void _editIssue(BuildContext context, GhIssue issue) async {
    showDialog(
      context: context,
      builder: (_) => _EditIssueDialog(repoKey: widget.repoKey, issue: issue),
    );
  }

  void _toggleIssueState(BuildContext context, GhIssue issue) async {
    final newState = issue.state == 'open' ? 'closed' : 'open';
    try {
      await ref
          .read(repoIssuesProvider(widget.repoKey).notifier)
          .updateIssue(number: issue.number, issueState: newState);
      ref.invalidate(issueDetailProvider((widget.repoKey, widget.issueNumber)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _addComment(BuildContext context) async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;
    try {
      await ref
          .read(
            issueCommentsProvider((
              widget.repoKey,
              widget.issueNumber,
            )).notifier,
          )
          .addComment(body);
      _commentController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Color _parseLabelColor(String hex) {
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetadataChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  final GhIssueComment comment;
  final AppLocalizations l10n;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _CommentTile({
    required this.comment,
    required this.l10n,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: comment.userAvatar.isNotEmpty
                    ? NetworkImage(comment.userAvatar)
                    : null,
                child: comment.userAvatar.isEmpty
                    ? Text(
                        comment.userLogin[0].toUpperCase(),
                        style: const TextStyle(fontSize: 10),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                comment.userLogin,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _timeAgo(comment.createdAt),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.body, style: textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}

class _EditIssueDialog extends ConsumerStatefulWidget {
  final String repoKey;
  final GhIssue issue;

  const _EditIssueDialog({required this.repoKey, required this.issue});

  @override
  ConsumerState<_EditIssueDialog> createState() => _EditIssueDialogState();
}

class _EditIssueDialogState extends ConsumerState<_EditIssueDialog> {
  late final _titleController = TextEditingController(text: widget.issue.title);
  late final _bodyController = TextEditingController(
    text: widget.issue.body ?? '',
  );

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.dialogEditIssue),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: l10n.placeholderIssueTitle),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(hintText: l10n.placeholderIssueBody),
              maxLines: 5,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: () => _save(context),
          child: Text(l10n.buttonSave),
        ),
      ],
    );
  }

  void _save(BuildContext context) async {
    try {
      await ref
          .read(repoIssuesProvider(widget.repoKey).notifier)
          .updateIssue(
            number: widget.issue.number,
            title: _titleController.text,
            body: _bodyController.text.isEmpty ? null : _bodyController.text,
          );
      ref.invalidate(
        issueDetailProvider((widget.repoKey, widget.issue.number)),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
