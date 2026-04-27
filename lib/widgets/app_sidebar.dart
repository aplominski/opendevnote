import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/project_provider.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/providers/todo_provider.dart';
import 'package:opendevnote/screens/dialogs/add_code_snippet_dialog.dart';
import 'package:opendevnote/screens/dialogs/add_note_dialog.dart';
import 'package:opendevnote/screens/dialogs/add_project_dialog.dart';
import 'package:opendevnote/screens/dialogs/add_todo_dialog.dart';
import 'package:opendevnote/theme/app_colors.dart';

class AppSidebar extends ConsumerWidget {
  final VoidCallback? onNavigate;

  const AppSidebar({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final navSection = ref.watch(navSectionProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final projects = ref.watch(projectsProvider);
    final todayTodos = ref.watch(todayTodosProvider);
    final unplannedTodos = ref.watch(inboxTodosProvider);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
        _SidebarItem(
          icon: Icons.today_outlined,
          label: l10n.navigationToday,
          count: todayTodos.length,
          isSelected: navSection == NavSection.today,
          onTap: () {
            ref.read(navSectionProvider.notifier).state = NavSection.today;
            ref.read(selectedProjectIdProvider.notifier).state = null;
            ref.read(selectedSnippetIdProvider.notifier).state = null;
            ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
            onNavigate?.call();
          },
        ),
        _SidebarItem(
          icon: Icons.inbox_outlined,
          label: l10n.navigationInbox,
          count: unplannedTodos.length,
          isSelected: navSection == NavSection.inbox,
          onTap: () {
            ref.read(navSectionProvider.notifier).state = NavSection.inbox;
            ref.read(selectedProjectIdProvider.notifier).state = null;
            ref.read(selectedSnippetIdProvider.notifier).state = null;
            ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
            onNavigate?.call();
          },
        ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(
              height: 0.5,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        _SidebarItem(
          icon: Icons.calendar_today_outlined,
          label: l10n.navigationCalendar,
          isSelected: navSection == NavSection.calendar,
          onTap: () {
            ref.read(navSectionProvider.notifier).state = NavSection.calendar;
            ref.read(selectedProjectIdProvider.notifier).state = null;
            ref.read(selectedSnippetIdProvider.notifier).state = null;
            ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
            onNavigate?.call();
          },
        ),
        _SidebarItem(
          icon: Icons.calculate_outlined,
          label: l10n.navigationCalculator,
          isSelected: navSection == NavSection.calculator,
          onTap: () {
            ref.read(navSectionProvider.notifier).state =
                NavSection.calculator;
            ref.read(selectedProjectIdProvider.notifier).state = null;
            ref.read(selectedSnippetIdProvider.notifier).state = null;
            ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
            onNavigate?.call();
          },
        ),
        _SidebarItem(
          icon: Icons.timer_outlined,
          label: l10n.navigationWorkTime,
          isSelected: navSection == NavSection.workTime,
          onTap: () {
            ref.read(navSectionProvider.notifier).state = NavSection.workTime;
            ref.read(selectedProjectIdProvider.notifier).state = null;
            ref.read(selectedSnippetIdProvider.notifier).state = null;
            ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
            onNavigate?.call();
          },
        ),
        _SidebarItem(
          icon: Icons.rss_feed_outlined,
          label: l10n.navigationNews,
          isSelected: navSection == NavSection.news,
          onTap: () {
            ref.read(navSectionProvider.notifier).state = NavSection.news;
            ref.read(selectedProjectIdProvider.notifier).state = null;
            ref.read(selectedSnippetIdProvider.notifier).state = null;
            ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
            onNavigate?.call();
          },
        ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(
              height: 0.5,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        _SidebarItem(
          icon: Icons.source_outlined,
          label: l10n.navigationRepos,
          isSelected: navSection == NavSection.repositories,
          onTap: () {
            ref.read(navSectionProvider.notifier).state =
                NavSection.repositories;
            ref.read(selectedProjectIdProvider.notifier).state = null;
            ref.read(selectedSnippetIdProvider.notifier).state = null;
            ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
            onNavigate?.call();
          },
        ),
        _SidebarItem(
          icon: Icons.rocket_launch_outlined,
          label: 'CI/CD Workflows',
          isSelected: navSection == NavSection.workflows,
          onTap: () {
            ref.read(navSectionProvider.notifier).state =
                NavSection.workflows;
            ref.read(selectedProjectIdProvider.notifier).state = null;
            ref.read(selectedSnippetIdProvider.notifier).state = null;
            ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
            onNavigate?.call();
          },
        ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Divider(
              height: 0.5,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              l10n.navigationProjects,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                final stats = ref.watch(projectStatsProvider(project.id));
                final total = stats['total']!;
                final completed = stats['completed']!;
              return _SidebarItem(
                icon: AppColors.getIcon(project.iconIndex),
                iconColor: AppColors.getColor(project.colorIndex),
                label: project.name,
                count: total - completed,
                isSelected:
                    navSection == NavSection.projects &&
                    selectedProjectId == project.id,
                onTap: () {
                  ref.read(navSectionProvider.notifier).state =
                      NavSection.projects;
                  ref.read(selectedProjectIdProvider.notifier).state =
                      project.id;
                  ref.read(selectedSnippetIdProvider.notifier).state = null;
                  ref.read(selectedSnippetProjectIdProvider.notifier).state =
                      null;
                  onNavigate?.call();
                },
              );
              },
            ),
          ),
          if (selectedProjectId != null) ...[
            _SidebarItem(
              icon: Icons.note_add_outlined,
              label: l10n.tooltipNewNote,
              isSelected: false,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AddNoteDialog(projectId: selectedProjectId),
                );
              },
            ),
            _SidebarItem(
              icon: Icons.add_task,
              label: l10n.tooltipNewTask,
              isSelected: false,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AddTodoDialog(projectId: selectedProjectId),
                );
              },
            ),
            _SidebarItem(
              icon: Icons.code_outlined,
              label: l10n.tooltipNewCodeSnippet,
              isSelected: false,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) =>
                      AddCodeSnippetDialog(projectId: selectedProjectId),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(
                height: 1,
                thickness: 1,
                color: colorScheme.outline,
              ),
            ),
          ],
          _SidebarItem(
            icon: Icons.add,
            label: l10n.tooltipNewProject,
            isSelected: false,
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const AddProjectDialog(),
              );
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
        _SidebarItem(
          icon: Icons.settings_outlined,
          label: l10n.tooltipSettings,
          isSelected: navSection == NavSection.settings,
          onTap: () {
            ref.read(navSectionProvider.notifier).state = NavSection.settings;
            ref.read(selectedProjectIdProvider.notifier).state = null;
            ref.read(selectedSnippetIdProvider.notifier).state = null;
            ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
            onNavigate?.call();
          },
        ),
          const SizedBox(height: 8),
        ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    this.iconColor,
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: isSelected
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  iconColor ??
                  (isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count != null && count! > 0)
              Text(
                '$count',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
