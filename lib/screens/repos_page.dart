import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/gh_repo.dart';
import 'package:opendevnote/models/repo_filter.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/providers/repos_provider.dart';
import 'package:opendevnote/screens/dialogs/workflow_config_dialog.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';
import 'package:opendevnote/widgets/empty_state.dart';
import 'package:opendevnote/widgets/repo_filter_bar.dart';

class ReposPage extends ConsumerStatefulWidget {
  const ReposPage({super.key});

  @override
  ConsumerState<ReposPage> createState() => _ReposPageState();
}

class _ReposPageState extends ConsumerState<ReposPage> {
  RepoFilter _filter = const RepoFilter();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final reposState = ref.watch(reposProvider);
    final starred = ref.watch(starredReposProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    var repos = List<GhRepo>.from(reposState.repos);

    repos = repos.where((r) {
      if (!matchesRegex(r.ownerLogin, _filter.ownerPattern)) return false;
      if (!matchesRegex(r.name, _filter.namePattern)) return false;
      if (_filter.language != null && r.language != _filter.language)
        return false;
      if (_filter.visibility == 'public' && r.isPrivate) return false;
      if (_filter.visibility == 'private' && !r.isPrivate) return false;
      return true;
    }).toList();

    repos.sort((a, b) {
      final aStar = starred.contains(a.fullName);
      final bStar = starred.contains(b.fullName);
      if (aStar != bStar) return aStar ? -1 : 1;
      final aDate = a.pushedAt ?? DateTime(2000);
      final bDate = b.pushedAt ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    final languages =
        reposState.repos
            .where((r) => r.language != null)
            .map((r) => r.language!)
            .toSet()
            .toList()
          ..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', l10n.navigationRepos],
          onTap: [null, null],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                l10n.navigationRepos,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (reposState.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: reposState.isLoading
                    ? null
                    : () => ref.read(reposProvider.notifier).fetchAll(),
                tooltip: l10n.tooltipRefresh,
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 20),
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const GithubSettingsDialog(),
                ),
                tooltip: l10n.tooltipSettings,
              ),
            ],
          ),
        ),
        if (reposState.error != null)
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
                      reposState.error!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        RepoFilterBar(
          filter: _filter,
          onChanged: (f) => setState(() => _filter = f),
          showLanguage: true,
          showVisibility: true,
          availableLanguages: languages,
        ),
        Expanded(
          child: repos.isEmpty && !reposState.isLoading
              ? EmptyState(
                  title: _filter.hasActiveFilters
                      ? l10n.emptyStateNoResultsForFilters
                      : l10n.emptyStateNoReposWithWorkflows,
                  subtitle: _filter.hasActiveFilters
                      ? l10n.emptyStateChangeFilters
                      : l10n.emptyStateAddGitHubAccount,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: repos.length,
                  itemBuilder: (context, index) {
                    final repo = repos[index];
                    final isStarred = starred.contains(repo.fullName);
                    return _RepoCard(
                      repo: repo,
                      isStarred: isStarred,
                      onStarToggle: () => ref
                          .read(starredReposProvider.notifier)
                          .toggle(repo.fullName),
                      onTap: () {
                        ref.read(selectedRepoProvider.notifier).state =
                            repo.fullName;
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
  final GhRepo repo;
  final bool isStarred;
  final VoidCallback onStarToggle;
  final VoidCallback onTap;

  const _RepoCard({
    required this.repo,
    required this.isStarred,
    required this.onStarToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            IconButton(
              onPressed: onStarToggle,
              icon: Icon(
                isStarred ? Icons.star : Icons.star_border,
                size: 22,
                color: isStarred
                    ? Colors.amber
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: isStarred
                  ? l10n.tooltipRemoveFromFavorites
                  : l10n.tooltipAddToFavorites,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repo.fullName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (repo.description != null &&
                      repo.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      repo.description!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (repo.language != null) ...[
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _languageColor(repo.language!),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          repo.language!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (repo.stargazersCount > 0) ...[
                        Icon(
                          Icons.star_outline,
                          size: 12,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${repo.stargazersCount}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (repo.forksCount > 0) ...[
                        Icon(
                          Icons.fork_right,
                          size: 12,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${repo.forksCount}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (repo.pushedAt != null)
                        Text(
                          _timeAgo(context, repo.pushedAt!),
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

  String _timeAgo(BuildContext context, DateTime dt) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return l10n.timeSecondsAgo(diff.inSeconds);
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year.toString().substring(2)}';
  }

  Color _languageColor(String language) {
    const colors = {
      'Dart': Colors.blue,
      'JavaScript': Color(0xFFF7DF1E),
      'TypeScript': Color(0xFF3178C6),
      'Python': Color(0xFF3776AB),
      'Java': Color(0xFFED8B00),
      'Kotlin': Color(0xFF7F52FF),
      'Swift': Color(0xFFFA7343),
      'Rust': Color(0xFFDEA584),
      'Go': Color(0xFF00ADD8),
      'C': Color(0xFF555555),
      'C++': Color(0xFF00599C),
      'C#': Color(0xFF239120),
      'Ruby': Color(0xFFCC342D),
      'PHP': Color(0xFF777BB4),
      'Shell': Color(0xFF89E051),
      'HTML': Color(0xFFE34C26),
      'CSS': Color(0xFF1572B6),
    };
    return colors[language] ?? Colors.grey;
  }
}
