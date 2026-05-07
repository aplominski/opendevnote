import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/gh_pull_request.dart';
import 'package:opendevnote/providers/pull_requests_provider.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';
import 'package:opendevnote/widgets/empty_state.dart';

enum PrStateFilter { all, open, closed, merged }

class PullRequestsPage extends ConsumerStatefulWidget {
  const PullRequestsPage({super.key});

  @override
  ConsumerState<PullRequestsPage> createState() => _PullRequestsPageState();
}

class _PullRequestsPageState extends ConsumerState<PullRequestsPage> {
  String _searchQuery = '';
  PrStateFilter _stateFilter = PrStateFilter.all;
  String? _repoFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prsState = ref.watch(pullRequestsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var prs = prsState.allPrs;

    prs = prs.where((pr) {
      if (_stateFilter == PrStateFilter.open && pr.state != 'open') {
        return false;
      }
      if (_stateFilter == PrStateFilter.closed &&
          pr.state != 'closed' &&
          !pr.isMerged) {
        return false;
      }
      if (_stateFilter == PrStateFilter.merged && !pr.isMerged) {
        return false;
      }
      if (_repoFilter != null && !pr.htmlUrl.contains(_repoFilter!)) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !pr.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    prs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final repoNames = prsState.prsByRepo.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', l10n.navigationPullRequests],
          onTap: [null, null],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                l10n.navigationPullRequests,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (prsState.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: prsState.isLoading
                    ? null
                    : () => ref.read(pullRequestsProvider.notifier).fetchAll(),
                tooltip: l10n.tooltipRefresh,
              ),
            ],
          ),
        ),
        if (prsState.error != null)
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
                      prsState.error!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.placeholderSearch,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<PrStateFilter>(
                value: _stateFilter,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem(
                    value: PrStateFilter.all,
                    child: Text('All'),
                  ),
                  const DropdownMenuItem(
                    value: PrStateFilter.open,
                    child: Text('Open'),
                  ),
                  const DropdownMenuItem(
                    value: PrStateFilter.closed,
                    child: Text('Closed'),
                  ),
                  const DropdownMenuItem(
                    value: PrStateFilter.merged,
                    child: Text('Merged'),
                  ),
                ],
                onChanged: (v) => setState(() => _stateFilter = v!),
              ),
              const SizedBox(width: 12),
              if (repoNames.isNotEmpty)
                DropdownButton<String?>(
                  value: _repoFilter,
                  hint: const Text('Repo'),
                  underline: const SizedBox(),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...repoNames.map(
                      (r) => DropdownMenuItem(value: r, child: Text(r)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _repoFilter = v),
                ),
            ],
          ),
        ),
        Expanded(
          child: prs.isEmpty
              ? const EmptyState(
                  title: 'No pull requests',
                  subtitle: 'Pull requests will appear here',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: prs.length,
                  itemBuilder: (context, index) {
                    final pr = prs[index];
                    return _PullRequestCard(
                      pr: pr,
                      onTap: () {
                        ref.read(selectedPrRepoProvider.notifier).state = pr
                            .htmlUrl
                            .split('/')
                            .take(5)
                            .join('/')
                            .replaceAll('https://', '')
                            .split('/')
                            .skip(1)
                            .join('/');
                        ref.read(selectedPrNumberProvider.notifier).state =
                            pr.number;
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _PullRequestCard extends StatelessWidget {
  final GhPullRequest pr;
  final VoidCallback onTap;

  const _PullRequestCard({required this.pr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color stateColor;
    IconData stateIcon;
    String stateText;

    if (pr.isMerged) {
      stateColor = Colors.purple;
      stateIcon = Icons.merge;
      stateText = 'Merged';
    } else if (pr.state == 'closed') {
      stateColor = colorScheme.error;
      stateIcon = Icons.cancel_outlined;
      stateText = 'Closed';
    } else {
      stateColor = Colors.green;
      stateIcon = Icons.merge_type;
      stateText = 'Open';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(stateIcon, size: 16, color: stateColor),
                  const SizedBox(width: 6),
                  Text(
                    stateText,
                    style: textTheme.labelSmall?.copyWith(color: stateColor),
                  ),
                  const SizedBox(width: 8),
                  if (pr.isDraft)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Draft',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
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
              const SizedBox(height: 6),
              Text(
                pr.title,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (pr.headRef.isNotEmpty || pr.baseRef.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.call_merge,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${pr.headRef} → ${pr.baseRef}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (pr.userAvatar.isNotEmpty)
                    CircleAvatar(
                      radius: 10,
                      backgroundImage: NetworkImage(pr.userAvatar),
                    ),
                  const SizedBox(width: 6),
                  Text(
                    pr.userLogin,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.comment_outlined,
                    size: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${pr.comments}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatDate(pr.updatedAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
