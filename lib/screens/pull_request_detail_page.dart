import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/gh_pull_request.dart';
import 'package:opendevnote/providers/pull_requests_provider.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';

class PullRequestDetailPage extends ConsumerStatefulWidget {
  final String repoKey;
  final int prNumber;

  const PullRequestDetailPage({
    super.key,
    required this.repoKey,
    required this.prNumber,
  });

  @override
  ConsumerState<PullRequestDetailPage> createState() =>
      _PullRequestDetailPageState();
}

class _PullRequestDetailPageState extends ConsumerState<PullRequestDetailPage> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(prCommentsProvider((widget.repoKey, widget.prNumber)).notifier)
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

    final prAsync = ref.watch(
      prDetailProvider((widget.repoKey, widget.prNumber)),
    );
    final commentsState = ref.watch(
      prCommentsProvider((widget.repoKey, widget.prNumber)),
    );

    return prAsync.when(
      data: (pr) => _buildPrDetail(
        context,
        pr,
        commentsState,
        l10n,
        colorScheme,
        textTheme,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildPrDetail(
    BuildContext context,
    GhPullRequest pr,
    PrCommentsState commentsState,
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
            l10n.navigationPullRequests,
            '${widget.repoKey} #${pr.number}',
          ],
          onTap: [
            null,
            () {
              ref.read(selectedPrRepoProvider.notifier).state = null;
              ref.read(selectedPrNumberProvider.notifier).state = null;
            },
            null,
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStateIcon(pr, colorScheme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pr.title,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${pr.userLogin} wants to merge ${pr.headRef} into ${pr.baseRef}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '#${pr.number}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildStateChip(pr, colorScheme),
            ],
          ),
        ),
        if (pr.body != null && pr.body!.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(pr.body!, style: textTheme.bodyMedium),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              l10n.labelComments,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${commentsState.comments.length})',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (commentsState.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (commentsState.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No comments yet',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...commentsState.comments.map(
            (comment) => _buildComment(comment, colorScheme, textTheme),
          ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, size: 20),
                onPressed: () {
                  if (_commentController.text.trim().isNotEmpty) {
                    ref
                        .read(
                          prCommentsProvider((
                            widget.repoKey,
                            widget.prNumber,
                          )).notifier,
                        )
                        .addComment(_commentController.text.trim());
                    _commentController.clear();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStateIcon(GhPullRequest pr, ColorScheme colorScheme) {
    Color stateColor;
    IconData stateIcon;

    if (pr.isMerged) {
      stateColor = Colors.purple;
      stateIcon = Icons.merge;
    } else if (pr.state == 'closed') {
      stateColor = colorScheme.error;
      stateIcon = Icons.cancel_outlined;
    } else {
      stateColor = Colors.green;
      stateIcon = Icons.merge_type;
    }

    return Icon(stateIcon, color: stateColor, size: 32);
  }

  Widget _buildStateChip(GhPullRequest pr, ColorScheme colorScheme) {
    Color stateColor;
    String stateText;

    if (pr.isMerged) {
      stateColor = Colors.purple;
      stateText = 'Merged';
    } else if (pr.state == 'closed') {
      stateColor = colorScheme.error;
      stateText = 'Closed';
    } else {
      stateColor = Colors.green;
      stateText = 'Open';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: stateColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        stateText,
        style: TextStyle(color: stateColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildComment(
    dynamic comment,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (comment.userAvatar.isNotEmpty)
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(comment.userAvatar),
                ),
              const SizedBox(width: 8),
              Text(
                comment.userLogin,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(comment.createdAt),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(comment.body, style: textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'today';
    } else if (diff.inDays == 1) {
      return 'yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else {
      return '${(diff.inDays / 30).floor()}mo ago';
    }
  }
}
