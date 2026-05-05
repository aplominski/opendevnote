import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/gh_branch.dart';
import 'package:opendevnote/models/gh_commit.dart';
import 'package:opendevnote/models/gh_issue.dart';
import 'package:opendevnote/models/gh_repo_stats.dart';
import 'package:opendevnote/providers/repos_provider.dart';
import 'package:opendevnote/providers/issues_provider.dart';
import 'package:opendevnote/screens/dialogs/commit_detail_dialog.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';

class ReposDetailPage extends ConsumerStatefulWidget {
  const ReposDetailPage({super.key});

  @override
  ConsumerState<ReposDetailPage> createState() => _ReposDetailPageState();
}

class _ReposDetailPageState extends ConsumerState<ReposDetailPage> {
  bool _statsLoaded = false;
  bool _branchesLoaded = false;
  bool _issuesLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitial();
    });
  }

  void _loadInitial() {
    final repoKey = ref.read(selectedRepoProvider);
    if (repoKey == null) return;
    ref.read(repoCommitsProvider(repoKey).notifier).loadFirst();
  }

  @override
  Widget build(BuildContext context) {
    final repoKey = ref.watch(selectedRepoProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (repoKey == null) return const SizedBox.shrink();

    final commitsState = ref.watch(repoCommitsProvider(repoKey));
    final statsState = ref.watch(repoStatsProvider(repoKey));
    final branchesState = ref.watch(repoBranchesProvider(repoKey));
    final issuesState = ref.watch(repoIssuesProvider(repoKey));

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200 &&
            !commitsState.isLoading &&
            commitsState.hasMore) {
          ref.read(repoCommitsProvider(repoKey).notifier).loadMore();
        }
        return false;
      },
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Breadcrumb
          AppBreadcrumb(
            items: ['OpenDevNote', 'Repozytoria', repoKey],
            onTap: [
              null,
              () => ref.read(selectedRepoProvider.notifier).state = null,
              null,
            ],
          ),
          // Header
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.source_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    repoKey,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () {
                    ref.read(repoCommitsProvider(repoKey).notifier).loadFirst();
                    setState(() {
                      _statsLoaded = false;
                      _branchesLoaded = false;
                    });
                  },
                  tooltip: 'Odśwież',
                ),
              ],
            ),
          ),
          // ── Commits Section ──
          _SectionHeader(title: 'Commity'),
          if (commitsState.isLoading && commitsState.commits.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (commitsState.error != null && commitsState.commits.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                commitsState.error!,
                style: TextStyle(color: colorScheme.error),
              ),
            )
          else ...[
            ...commitsState.commits.map(
              (c) => _CommitTile(
                commit: c,
                onTap: () => showDialog(
                  context: context,
                  builder: (_) =>
                      CommitDetailDialog(repoFullName: repoKey, sha: c.sha),
                ),
              ),
            ),
            if (commitsState.isLoading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (!commitsState.hasMore && commitsState.commits.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    'Wszystkie commity załadowane',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 16),
          // ── Branches Section ──
          _SectionHeader(
            title: 'Gałęzie',
            onExpand: () {
              if (!_branchesLoaded) {
                ref.read(repoBranchesProvider(repoKey).notifier).load();
                setState(() => _branchesLoaded = true);
              }
            },
            isLoaded: _branchesLoaded,
          ),
          if (_branchesLoaded) ...[
            if (branchesState.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (branchesState.branches.isNotEmpty)
              ...branchesState.branches.map(
                (b) => _BranchTile(
                  branch: b,
                  isDefault: b.name == 'main' || b.name == 'master',
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Brak gałęzi'),
              ),
          ],
          const SizedBox(height: 16),
          // ── Graphs Section ──
          _SectionHeader(
            title: 'Wykresy',
            onExpand: () {
              if (!_statsLoaded) {
                ref.read(repoStatsProvider(repoKey).notifier).load();
                setState(() => _statsLoaded = true);
              }
            },
            isLoaded: _statsLoaded,
          ),
          if (_statsLoaded) ...[
            if (statsState.isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (statsState.error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  statsState.error!,
                  style: TextStyle(color: colorScheme.error),
                ),
              )
            else ...[
              // Contributors
              if (statsState.contributors != null &&
                  statsState.contributors!.isNotEmpty)
                _ContributorsChart(contributors: statsState.contributors!),
              // Commit Activity
              if (statsState.commitActivity != null &&
                  statsState.commitActivity!.isNotEmpty)
                _CommitActivityChart(data: statsState.commitActivity!),
              // Code Frequency
              if (statsState.codeFrequency != null &&
                  statsState.codeFrequency!.isNotEmpty)
                _CodeFrequencyChart(data: statsState.codeFrequency!),
              // Punch Card
              if (statsState.punchCard != null &&
                  statsState.punchCard!.isNotEmpty)
                _PunchCardChart(data: statsState.punchCard!),
              // Participation
              if (statsState.participation != null)
                _ParticipationChart(data: statsState.participation!),
            ],
          ],
          // ── Issues Section ──
          _SectionHeader(
            title: 'Issues',
            onExpand: () {
              if (!_issuesLoaded) {
                ref.read(repoIssuesProvider(repoKey).notifier).loadFirst();
                setState(() => _issuesLoaded = true);
              }
            },
            isLoaded: _issuesLoaded,
          ),
          if (_issuesLoaded) ...[
            if (issuesState.isLoading && issuesState.issues.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (issuesState.error != null && issuesState.issues.isEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  issuesState.error!,
                  style: TextStyle(color: colorScheme.error),
                ),
              )
            else if (issuesState.issues.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Brak issues'),
              )
            else ...[
              ...issuesState.issues
                  .take(10)
                  .map(
                    (i) => _IssueTile(
                      issue: i,
                      onTap: () {
                        ref.read(selectedIssueRepoProvider.notifier).state =
                            repoKey;
                        ref.read(selectedIssueNumberProvider.notifier).state =
                            i.number;
                      },
                    ),
                  ),
              if (issuesState.isLoading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ── Section Header ──

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onExpand;
  final bool isLoaded;

  const _SectionHeader({
    required this.title,
    this.onExpand,
    this.isLoaded = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: isLoaded ? null : onExpand,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Text(
              title,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isLoaded) ...[
              const Spacer(),
              Text(
                'Kliknij aby załadować',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Commit Tile ──

class _CommitTile extends StatelessWidget {
  final GhCommit commit;
  final VoidCallback? onTap;

  const _CommitTile({required this.commit, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final messageFirstLine = commit.message.split('\n').first;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            // Avatar
            if (commit.authorAvatar.isNotEmpty)
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(commit.authorAvatar),
              )
            else
              CircleAvatar(
                radius: 12,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  commit.authorName.isNotEmpty
                      ? commit.authorName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            const SizedBox(width: 10),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageFirstLine,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        commit.authorName,
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
                        _timeAgo(commit.date),
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
            // SHA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                commit.shortSha,
                style: textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
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

// ── Branch Tile ──

class _BranchTile extends StatelessWidget {
  final GhBranch branch;
  final bool isDefault;

  const _BranchTile({required this.branch, required this.isDefault});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
          Icon(
            Icons.fork_right,
            size: 16,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                Text(
                  branch.name,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: isDefault ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (isDefault) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'default',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
                if (branch.isProtected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),
          ),
          Text(
            branch.shortSha,
            style: textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 10,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Issue Tile ──

class _IssueTile extends StatelessWidget {
  final GhIssue issue;
  final VoidCallback onTap;

  const _IssueTile({required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            Icon(
              issue.state == 'open'
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              size: 16,
              color: issue.state == 'open' ? Colors.green : Colors.purple,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.title,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
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
                      if (issue.labels.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            issue.labels.first.name,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: _parseLabelColor(issue.labels.first.color),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseLabelColor(String hex) {
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }
}

// ── Contributors Chart ──

class _ContributorsChart extends StatelessWidget {
  final List<ContributorStat> contributors;

  const _ContributorsChart({required this.contributors});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final top10 = contributors.take(10).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contributors (${contributors.length})',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: max(120, top10.length * 28.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: top10.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.totalCommits.toDouble(),
                        color: colorScheme.primary,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < top10.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              top10[i].login.length > 8
                                  ? '${top10[i].login.substring(0, 8)}…'
                                  : top10[i].login,
                              style: TextStyle(
                                fontSize: 9,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Commit Activity Chart ──

class _CommitActivityChart extends StatelessWidget {
  final List<CommitActivityWeek> data;

  const _CommitActivityChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktywność commitów (ostatni rok)',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.total.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: colorScheme.primary,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Code Frequency Chart ──

class _CodeFrequencyChart extends StatelessWidget {
  final List<CodeFrequencyWeek> data;

  const _CodeFrequencyChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final recent = data.length > 26 ? data.sublist(data.length - 26) : data;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Częstotliwość kodu (ostatnie 6 mies.)',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                barGroups: recent.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.additions.toDouble(),
                        color: Colors.green,
                        width: 3,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(2),
                        ),
                      ),
                      BarChartRodData(
                        toY: e.value.deletions.abs().toDouble() * -1,
                        color: Colors.red,
                        width: 3,
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(2),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                groupsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Colors.green, label: 'Dodania'),
              const SizedBox(width: 16),
              _LegendDot(color: Colors.red, label: 'Usunięcia'),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Punch Card Chart ──

class _PunchCardChart extends StatelessWidget {
  final List<PunchCardEntry> data;

  const _PunchCardChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final maxCommits = data.fold<int>(0, (m, e) => max(m, e.commits));
    if (maxCommits == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aktywność (dzień × godzina)',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: GridView.count(
              crossAxisCount: 24,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(7 * 24, (index) {
                final day = index ~/ 24;
                final hour = index % 24;
                final entry = data.firstWhere(
                  (e) => e.day == day && e.hour == hour,
                  orElse: () =>
                      PunchCardEntry(day: day, hour: hour, commits: 0),
                );
                final intensity = entry.commits / maxCommits;
                return Container(
                  margin: const EdgeInsets.all(0.5),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(
                      alpha: 0.1 + intensity * 0.9,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: PunchCardEntry.dayNames
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8,
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Participation Chart ──

class _ParticipationChart extends StatelessWidget {
  final ParticipationData data;

  const _ParticipationChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Udział (ostatnie 52 tygodnie)',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: BarChart(
              BarChartData(
                barGroups: data.all.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        color: colorScheme.primary,
                        width: 2,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(1),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: colorScheme.primary,
                label: 'Wszystkie commity',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
