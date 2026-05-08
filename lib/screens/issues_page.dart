import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/gh_issue.dart';
import 'package:opendevnote/providers/issues_provider.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';
import 'package:opendevnote/widgets/empty_state.dart';

enum IssueStateFilter { all, open, closed }

class IssuesPage extends ConsumerStatefulWidget {
  const IssuesPage({super.key});

  @override
  ConsumerState<IssuesPage> createState() => _IssuesPageState();
}

class _IssuesPageState extends ConsumerState<IssuesPage> {
  String _searchQuery = '';
  IssueStateFilter _stateFilter = IssueStateFilter.all;
  String? _repoFilter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final issuesState = ref.watch(issuesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var issues = issuesState.allIssues;

    issues = issues.where((i) {
      if (_stateFilter == IssueStateFilter.open && i.state != 'open') {
        return false;
      }
      if (_stateFilter == IssueStateFilter.closed && i.state != 'closed') {
        return false;
      }
      if (_repoFilter != null && !i.htmlUrl.contains(_repoFilter!)) {
        return false;
      }
      if (_searchQuery.isNotEmpty &&
          !i.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();

    issues.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    final repoNames = issuesState.issuesByRepo.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', l10n.navigationIssues],
          onTap: [null, null],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                l10n.navigationIssues,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (issuesState.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: issuesState.isLoading
                    ? null
                    : () => ref.read(issuesProvider.notifier).fetchAll(),
                tooltip: l10n.tooltipRefresh,
              ),
            ],
          ),
        ),
        if (issuesState.error != null)
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
                      issuesState.error!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        _IssueFilterBar(
          searchQuery: _searchQuery,
          onSearchChanged: (q) => setState(() => _searchQuery = q),
          stateFilter: _stateFilter,
          onStateChanged: (f) => setState(() => _stateFilter = f),
          repoFilter: _repoFilter,
          onRepoChanged: (r) => setState(() => _repoFilter = r),
          repoNames: repoNames,
          l10n: l10n,
        ),
        Expanded(
          child: issues.isEmpty && !issuesState.isLoading
              ? EmptyState(
                  title:
                      _searchQuery.isNotEmpty ||
                          _stateFilter != IssueStateFilter.all ||
                          _repoFilter != null
                      ? l10n.emptyStateNoResultsForFilters
                      : l10n.emptyStateNoIssues,
                  subtitle:
                      _searchQuery.isNotEmpty ||
                          _stateFilter != IssueStateFilter.all ||
                          _repoFilter != null
                      ? l10n.emptyStateChangeFilters
                      : l10n.emptyStateAddGitHubAccount,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: issues.length,
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    final repoName = _extractRepoName(issue.htmlUrl);
                    return _IssueCard(
                      issue: issue,
                      repoName: repoName,
                      onTap: () {
                        ref.read(selectedIssueRepoProvider.notifier).state =
                            repoName;
                        ref.read(selectedIssueNumberProvider.notifier).state =
                            issue.number;
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _extractRepoName(String htmlUrl) {
    final uri = Uri.parse(htmlUrl);
    final parts = uri.pathSegments;
    if (parts.length >= 2) {
      return '${parts[0]}/${parts[1]}';
    }
    return '';
  }
}

class _IssueFilterBar extends StatelessWidget {
  final String searchQuery;
  final void Function(String) onSearchChanged;
  final IssueStateFilter stateFilter;
  final void Function(IssueStateFilter) onStateChanged;
  final String? repoFilter;
  final void Function(String?) onRepoChanged;
  final List<String> repoNames;
  final AppLocalizations l10n;

  const _IssueFilterBar({
    required this.searchQuery,
    required this.onSearchChanged,
    required this.stateFilter,
    required this.onStateChanged,
    required this.repoFilter,
    required this.onRepoChanged,
    required this.repoNames,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          TextField(
            onChanged: onSearchChanged,
            controller: TextEditingController(text: searchQuery)
              ..selection = TextSelection.collapsed(offset: searchQuery.length),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.placeholderSearch,
              prefixIcon: const Icon(Icons.search, size: 18),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 0,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant,
                  width: 0.5,
                ),
              ),
            ),
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _FilterChip(
                label: l10n.statusAll,
                selected: stateFilter == IssueStateFilter.all,
                onTap: () => onStateChanged(IssueStateFilter.all),
              ),
              const SizedBox(width: 4),
              _FilterChip(
                label: l10n.statusOpen,
                selected: stateFilter == IssueStateFilter.open,
                onTap: () => onStateChanged(IssueStateFilter.open),
              ),
              const SizedBox(width: 4),
              _FilterChip(
                label: l10n.statusClosed,
                selected: stateFilter == IssueStateFilter.closed,
                onTap: () => onStateChanged(IssueStateFilter.closed),
              ),
              if (repoNames.isNotEmpty) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    if (repoFilter != null) {
                      onRepoChanged(null);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: repoFilter != null
                          ? colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: repoFilter != null
                            ? colorScheme.primary.withValues(alpha: 0.3)
                            : colorScheme.outlineVariant,
                        width: 0.5,
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: repoFilter,
                      hint: Text(
                        l10n.labelRepo,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      underline: const SizedBox.shrink(),
                      isDense: true,
                      padding: EdgeInsets.zero,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      items: repoNames
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r, style: textTheme.bodySmall),
                            ),
                          )
                          .toList(),
                      onChanged: onRepoChanged,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            color: selected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final GhIssue issue;
  final String repoName;
  final VoidCallback onTap;

  const _IssueCard({
    required this.issue,
    required this.repoName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                issue.state == 'open'
                    ? Icons.error_outline
                    : Icons.check_circle_outline,
                size: 18,
                color: issue.state == 'open' ? Colors.green : Colors.purple,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.title,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '#${issue.number}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 11,
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
                        repoName,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                          fontSize: 11,
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
                      if (issue.labels.isNotEmpty)
                        ...issue.labels
                            .take(3)
                            .map(
                              (label) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _parseLabelColor(
                                      label.color,
                                    ).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _parseLabelColor(
                                        label.color,
                                      ).withValues(alpha: 0.4),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    label.name,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: _parseLabelColor(label.color),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      if (issue.comments > 0) ...[
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 12,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${issue.comments}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _timeAgo(l10n, issue.updatedAt),
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
              size: 18,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(AppLocalizations l10n, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return l10n.timeSecondsAgo(diff.inSeconds);
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year.toString().substring(2)}';
  }

  Color _parseLabelColor(String hex) {
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}
