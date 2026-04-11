import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/todo_item.dart';
import 'package:opendevnote/models/work_session.dart';
import 'package:opendevnote/providers/project_provider.dart';
import 'package:opendevnote/providers/todo_provider.dart';
import 'package:opendevnote/providers/work_time_provider.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';

class WorkTimePage extends ConsumerWidget {
  const WorkTimePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final activeSession = ref.watch(activeSessionProvider);
    final todayTotal = ref.watch(todayTotalProvider);
    final yesterdayTotal = ref.watch(yesterdayTotalProvider);
    final weeklyStats = ref.watch(weeklyStatsProvider);
    final sessions = ref.watch(workSessionsProvider);
    final projects = ref.watch(projectsProvider);

    final diff = todayTotal - yesterdayTotal;
    final diffMinutes = diff.inMinutes;

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    final todaySessions = sessions.where((s) {
      final d = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
      return d == todayKey;
    }).toList();

    String? activeTaskName;
    if (activeSession != null) {
      final allTodos = ref.watch(allTodosProvider);
      try {
        final task = allTodos.firstWhere((t) => t.id == activeSession.taskId);
        activeTaskName = task.title;
      } catch (_) {
        activeTaskName = l10n.labelTask;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', l10n.navigationWorkTime],
          onTap: [null, null],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Today summary header
              _SectionHeader(title: l10n.timeToday),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDuration(todayTotal),
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (diffMinutes != 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: diffMinutes > 0
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.timeVsYesterday(diffMinutes),
                        style: textTheme.bodySmall?.copyWith(
                          color: diffMinutes > 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.timeYesterdayTotal(_formatDuration(yesterdayTotal)),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),

              // Active timer
              if (activeSession != null) ...[
                _SectionHeader(title: l10n.labelActiveTimer),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_filled,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeTaskName ?? l10n.labelTask,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              l10n.timeFrom(
                                _formatTime(activeSession.startedAt),
                              ),
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ElapsedTimer(session: activeSession),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(workSessionsProvider.notifier)
                              .stopSession(activeSession.id);
                        },
                        child: Icon(
                          Icons.stop_circle,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Weekly chart
              _SectionHeader(title: l10n.labelLastWeek),
              SizedBox(height: 140, child: _WeeklyChart(stats: weeklyStats)),
              const SizedBox(height: 24),

              // Today sessions
              if (todaySessions.isNotEmpty) ...[
                _SectionHeader(title: l10n.labelTodaySessions),
                ...todaySessions.map(
                  (s) => _SessionTile(
                    session: s,
                    allTodos: ref.watch(allTodosProvider),
                    projects: projects,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Past days grouped
              _SectionHeader(title: l10n.labelHistory),
              ..._buildDayGroups(
                sessions: sessions,
                projects: projects,
                allTodos: ref.watch(allTodosProvider),
                colorScheme: colorScheme,
                textTheme: textTheme,
                l10n: l10n,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDayGroups({
    required List<WorkSession> sessions,
    required List projects,
    required List<TodoItem> allTodos,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required AppLocalizations l10n,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final dayMap = <DateTime, List<WorkSession>>{};
    for (final s in sessions) {
      final d = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
      if (d == today) continue;
      dayMap.putIfAbsent(d, () => []).add(s);
    }

    final sortedDays = dayMap.keys.toList()..sort((a, b) => b.compareTo(a));

    if (sortedDays.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              l10n.emptyStateNoHistory,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ];
    }

    return sortedDays.take(14).map((day) {
      final daySessions = dayMap[day]!;
      Duration dayTotal = Duration.zero;
      for (final s in daySessions) {
        dayTotal += s.duration;
      }

      final dayName = _getDayName(day, l10n);

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  dayName,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDuration(dayTotal),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ...daySessions.map(
              (s) => _SessionTile(
                session: s,
                allTodos: allTodos,
                projects: projects,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getDayName(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(date).inDays;
    if (diff == 1) return l10n.timeYesterdayCapitalized;
    if (diff == 2) return l10n.timeDayBeforeYesterday;

    final weekdays = [
      l10n.weekdayMonday,
      l10n.weekdayTuesday,
      l10n.weekdayWednesday,
      l10n.weekdayThursday,
      l10n.weekdayFriday,
      l10n.weekdaySaturday,
      l10n.weekdaySunday,
    ];
    return '${weekdays[date.weekday - 1]} ${date.day}.${date.month.toString().padLeft(2, '0')}';
  }

  static String _formatDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}min';
    }
    if (d.inMinutes > 0) {
      return '${d.inMinutes}min';
    }
    return '0min';
  }

  static String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ElapsedTimer extends StatelessWidget {
  final WorkSession session;

  const _ElapsedTimer({required this.session});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final elapsed = DateTime.now().difference(session.startedAt);
        final h = elapsed.inHours;
        final m = elapsed.inMinutes.remainder(60);
        final s = elapsed.inSeconds.remainder(60);
        final text = h > 0
            ? '${h}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s'
            : '${m}m ${s.toString().padLeft(2, '0')}s';
        return Text(
          text,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );
      },
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final Map<DateTime, Duration> stats;

  const _WeeklyChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final sorted = stats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final maxMinutes = sorted.fold<int>(
      0,
      (max, e) => e.value.inMinutes > max ? e.value.inMinutes : max,
    );
    final maxY = maxMinutes > 0 ? (maxMinutes / 60).ceilToDouble() : 1.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final entry = sorted[group.x.toInt()];
              return BarTooltipItem(
                WorkTimePage._formatDuration(entry.value),
                TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= sorted.length) {
                  return const SizedBox.shrink();
                }
                final date = sorted[index].key;
                final dayShort = [
                  l10n.weekdayShortMon,
                  l10n.weekdayShortTue,
                  l10n.weekdayShortWed,
                  l10n.weekdayShortThu,
                  l10n.weekdayShortFri,
                  l10n.weekdayShortSat,
                  l10n.weekdayShortSun,
                ];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    dayShort[date.weekday - 1],
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  '${value.toInt()}h',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(sorted.length, (index) {
          final hours = sorted[index].value.inMinutes / 60.0;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: hours > 0 ? hours : 0.05,
                color: hours > 0
                    ? colorScheme.primary.withValues(alpha: 0.7)
                    : colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final WorkSession session;
  final List<TodoItem> allTodos;
  final List projects;

  const _SessionTile({
    required this.session,
    required this.allTodos,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    String taskTitle = l10n.errorUnknownTask;
    String projectName = '';
    try {
      final task = allTodos.firstWhere((t) => t.id == session.taskId);
      taskTitle = task.title;
      try {
        final project = projects.firstWhere((p) => p.id == session.projectId);
        projectName = project.name;
      } catch (_) {}
    } catch (_) {}

    final startStr =
        '${session.startedAt.hour.toString().padLeft(2, '0')}:${session.startedAt.minute.toString().padLeft(2, '0')}';
    final endStr = session.endedAt != null
        ? '${session.endedAt!.hour.toString().padLeft(2, '0')}:${session.endedAt!.minute.toString().padLeft(2, '0')}'
        : '...';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  taskTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (projectName.isNotEmpty)
                  Text(
                    projectName,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$startStr - $endStr',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            WorkTimePage._formatDuration(session.duration),
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
