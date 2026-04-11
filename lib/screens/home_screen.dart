import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/project.dart';
import 'package:opendevnote/models/todo_item.dart';
import 'package:opendevnote/providers/code_snippet_provider.dart';
import 'package:opendevnote/providers/note_provider.dart';
import 'package:opendevnote/providers/project_provider.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/providers/todo_provider.dart';
import 'package:opendevnote/providers/workflow_provider.dart';
import 'package:opendevnote/providers/repos_provider.dart';
import 'package:opendevnote/screens/code_snippet_editor_screen.dart';
import 'package:opendevnote/screens/dialogs/add_code_snippet_dialog.dart';
import 'package:opendevnote/screens/dialogs/add_note_dialog.dart';
import 'package:opendevnote/screens/dialogs/add_project_dialog.dart';
import 'package:opendevnote/screens/dialogs/add_todo_dialog.dart';
import 'package:opendevnote/screens/dialogs/edit_code_snippet_dialog.dart';
import 'package:opendevnote/screens/dialogs/edit_project_dialog.dart';
import 'package:opendevnote/screens/dialogs/edit_todo_dialog.dart';
import 'package:opendevnote/screens/dialogs/manage_tags_dialog.dart';
import 'package:opendevnote/screens/note_editor_screen.dart';
import 'package:opendevnote/theme/app_colors.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';
import 'package:opendevnote/widgets/app_search_bar.dart';
import 'package:opendevnote/widgets/app_sidebar.dart';
import 'package:opendevnote/widgets/code_snippet_card.dart';
import 'package:opendevnote/widgets/empty_state.dart';
import 'package:opendevnote/widgets/project_card.dart';
import 'package:opendevnote/widgets/task_card.dart';
import 'package:opendevnote/widgets/keyboard_shortcuts_help.dart';
import 'package:opendevnote/widgets/command_bar.dart';
import 'package:opendevnote/screens/dialogs/add_event_dialog.dart';
import 'package:opendevnote/screens/calendar_page.dart';
import 'package:opendevnote/screens/day_detail_page.dart';
import 'package:opendevnote/screens/workflow_page.dart';
import 'package:opendevnote/screens/workflow_repo_detail_page.dart';
import 'package:opendevnote/screens/repos_page.dart';
import 'package:opendevnote/screens/repos_detail_page.dart';
import 'package:opendevnote/screens/calculator_page.dart';
import 'package:opendevnote/screens/work_time_page.dart';
import 'package:opendevnote/screens/rss_page.dart';
import 'package:opendevnote/screens/settings_page.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 700;
    final navSection = ref.watch(navSectionProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);

    final showFab =
        navSection == NavSection.projects &&
        selectedProjectId != null &&
        !isWide;

    return _HomeScreenWithShortcuts(
      isWide: isWide,
      navSection: navSection,
      selectedProjectId: selectedProjectId,
      showFab: showFab,
    );
  }
}

class _HomeScreenWithShortcuts extends ConsumerWidget {
  final bool isWide;
  final NavSection navSection;
  final String? selectedProjectId;
  final bool showFab;

  const _HomeScreenWithShortcuts({
    required this.isWide,
    required this.navSection,
    required this.selectedProjectId,
    required this.showFab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          if (selectedProjectId != null) {
            showDialog(
              context: context,
              builder: (_) => AddNoteDialog(projectId: selectedProjectId!),
            );
          }
        },
        const SingleActivator(LogicalKeyboardKey.keyT, control: true): () {
          if (selectedProjectId != null) {
            showDialog(
              context: context,
              builder: (_) => AddTodoDialog(projectId: selectedProjectId!),
            );
          }
        },
        const SingleActivator(LogicalKeyboardKey.slash, control: true): () {
          showDialog(
            context: context,
            builder: (_) => const KeyboardShortcutsHelp(),
          );
        },
        const SingleActivator(LogicalKeyboardKey.keyP, control: true): () {
          showDialog(context: context, builder: (_) => const CommandBar());
        },
        const SingleActivator(LogicalKeyboardKey.keyE, control: true): () {
          if (navSection == NavSection.calendar) {
            showDialog(
              context: context,
              builder: (_) => AddEventDialog(initialDate: DateTime.now()),
            );
          }
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: isWide
              ? Row(
                  children: [
                    const AppSidebar(),
                    Expanded(child: _ContentArea()),
                  ],
                )
              : _ContentArea(),
          bottomNavigationBar: isWide ? null : const _MobileBottomNav(),
          floatingActionButton: showFab
              ? FloatingActionButton.small(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          AddTodoDialog(projectId: selectedProjectId!),
                    );
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        ),
      ),
    );
  }
}

class _MobileBottomNav extends ConsumerWidget {
  const _MobileBottomNav();

  static const _sections = [
    NavSection.today,
    NavSection.inbox,
    NavSection.projects,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final navSection = ref.watch(navSectionProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final selectedIndex = _sections.indexOf(navSection).clamp(0, 2);

    return NavigationBar(
      height: 56,
      backgroundColor: colorScheme.surface,
      indicatorColor: colorScheme.primaryContainer,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        ref.read(navSectionProvider.notifier).state = _sections[index];
        if (index != 2) {
          ref.read(selectedProjectIdProvider.notifier).state = null;
        }
        ref.read(selectedSnippetIdProvider.notifier).state = null;
        ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.today_outlined, size: 20),
          selectedIcon: const Icon(Icons.today, size: 20),
          label: l10n.navigationToday,
        ),
        NavigationDestination(
          icon: const Icon(Icons.inbox_outlined, size: 20),
          selectedIcon: const Icon(Icons.inbox, size: 20),
          label: l10n.navigationInbox,
        ),
        NavigationDestination(
          icon: const Icon(Icons.folder_outlined, size: 20),
          selectedIcon: const Icon(Icons.folder, size: 20),
          label: l10n.navigationProjects,
        ),
      ],
    );
  }
}

class _ContentArea extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navSection = ref.watch(navSectionProvider);
    final selectedProjectId = ref.watch(selectedProjectIdProvider);
    final selectedWorkflowRepo = ref.watch(selectedWorkflowRepoProvider);
    final selectedSnippetId = ref.watch(selectedSnippetIdProvider);
    final selectedSnippetProjectId = ref.watch(
      selectedSnippetProjectIdProvider,
    );

    if (selectedSnippetId != null && selectedSnippetProjectId != null) {
      final snippets = ref.watch(snippetsProvider(selectedSnippetProjectId));
      try {
        final snippet = snippets.firstWhere((s) => s.id == selectedSnippetId);
        return CodeSnippetEditorScreen(snippet: snippet);
      } catch (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(selectedSnippetIdProvider.notifier).state = null;
          ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
        });
      }
    }

    switch (navSection) {
      case NavSection.today:
        return const _TodayView();
      case NavSection.inbox:
        return const _UnplannedView();
      case NavSection.calendar:
        return const _CalendarView();
      case NavSection.calculator:
        return const CalculatorPage();
      case NavSection.workTime:
        return const WorkTimePage();
      case NavSection.news:
        return const RssPage();
      case NavSection.repositories:
        final selectedRepo = ref.watch(selectedRepoProvider);
        if (selectedRepo != null) {
          return const ReposDetailPage();
        }
        return const ReposPage();
      case NavSection.workflows:
        if (selectedWorkflowRepo != null) {
          return const WorkflowRepoDetailPage();
        }
        return const WorkflowPage();
      case NavSection.projects:
        if (selectedProjectId != null) {
          return _ProjectDetailView(projectId: selectedProjectId);
        }
        return const _ProjectsListView();
      case NavSection.settings:
        return const SettingsPage();
    }
  }
}

class _TodayView extends ConsumerWidget {
  const _TodayView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final todayTodos = ref.watch(todayTodosProvider);
    final projects = ref.watch(projectsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final filtered = searchQuery.isEmpty
        ? todayTodos
        : todayTodos
              .where(
                (t) =>
                    t.title.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', l10n.timeToday],
          onTap: [null, null],
        ),
        AppSearchBar(
          hintText: l10n.placeholderSearch,
          onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
        ),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  title: l10n.emptyStateNoTasksToday,
                  subtitle: l10n.emptyStatePlanYourDay,
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final todo = filtered[index];
                    final project = projects.firstWhere(
                      (p) => p.id == todo.projectId,
                      orElse: () => projects.first,
                    );
                    return TaskCard(
                      todo: todo,
                      projectName: project.name,
                      onToggle: () => ref
                          .read(todosProvider(todo.projectId).notifier)
                          .toggleComplete(todo.id),
                      onTap: () => _editTodo(context, ref, todo, project),
                      onDismissed: (_) => ref
                          .read(todosProvider(todo.projectId).notifier)
                          .deleteTodo(todo.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _editTodo(
    BuildContext context,
    WidgetRef ref,
    TodoItem todo,
    Project project,
  ) async {
    final updated = await showDialog<TodoItem>(
      context: context,
      builder: (_) => EditTodoDialog(todo: todo, availableTags: project.tags),
    );
    if (updated != null) {
      ref.read(todosProvider(todo.projectId).notifier).updateTodo(updated);
    }
  }
}

class _UnplannedView extends ConsumerWidget {
  const _UnplannedView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final unplannedTodos = ref.watch(inboxTodosProvider);
    final projects = ref.watch(projectsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final filtered = searchQuery.isEmpty
        ? unplannedTodos
        : unplannedTodos
              .where(
                (t) =>
                    t.title.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', l10n.navigationInbox],
          onTap: [null, null],
        ),
        AppSearchBar(
          hintText: l10n.placeholderSearch,
          onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
        ),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  title: l10n.emptyStateUnplannedEmpty,
                  subtitle: l10n.emptyStateUnplannedHint,
                )
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final todo = filtered[index];
                    final project = projects.firstWhere(
                      (p) => p.id == todo.projectId,
                      orElse: () => projects.first,
                    );
                    return TaskCard(
                      todo: todo,
                      projectName: project.name,
                      onToggle: () => ref
                          .read(todosProvider(todo.projectId).notifier)
                          .toggleComplete(todo.id),
                      onTap: () => _editTodo(context, ref, todo, project),
                      onDismissed: (_) => ref
                          .read(todosProvider(todo.projectId).notifier)
                          .deleteTodo(todo.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _editTodo(
    BuildContext context,
    WidgetRef ref,
    TodoItem todo,
    Project project,
  ) async {
    final updated = await showDialog<TodoItem>(
      context: context,
      builder: (_) => EditTodoDialog(todo: todo, availableTags: project.tags),
    );
    if (updated != null) {
      ref.read(todosProvider(todo.projectId).notifier).updateTodo(updated);
    }
  }
}

class _CalendarView extends ConsumerWidget {
  const _CalendarView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CalendarPage();
  }
}

class _ProjectsListView extends ConsumerWidget {
  const _ProjectsListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projects = ref.watch(projectsProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final filtered = searchQuery.isEmpty
        ? projects
        : projects
              .where(
                (p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()),
              )
              .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', l10n.navigationProjects],
          onTap: [null, null],
        ),
        AppSearchBar(
          hintText: l10n.placeholderSearchProjects,
          onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
        ),
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  title: l10n.emptyStateNoProjects,
                  subtitle: l10n.emptyStateCreateFirstProject,
                )
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 0.5,
                    indent: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                  itemBuilder: (context, index) {
                    final project = filtered[index];
                    return ProjectCard(
                      project: project,
                      onTap: () {
                        ref.read(selectedProjectIdProvider.notifier).state =
                            project.id;
                      },
                      onLongPress: () =>
                          _showProjectOptions(context, ref, project),
                    );
                  },
                ),
        ),
        if (MediaQuery.of(context).size.width > 700)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAddProjectDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.tooltipNewProject),
              ),
            ),
          ),
      ],
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const AddProjectDialog());
  }

  void _showProjectOptions(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit_outlined, color: colorScheme.primary),
                title: Text(l10n.menuEdit),
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (_) => EditProjectDialog(project: project),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: Text(
                  l10n.menuDelete,
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(projectsProvider.notifier).deleteProject(project.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectDetailView extends ConsumerStatefulWidget {
  final String projectId;

  const _ProjectDetailView({required this.projectId});

  @override
  ConsumerState<_ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends ConsumerState<_ProjectDetailView> {
  bool _tasksExpanded = true;
  bool _notesExpanded = false;
  bool _snippetsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final projects = ref.watch(projectsProvider);
    final project = projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => projects.isNotEmpty
          ? projects.first
          : Project(id: '', name: 'Unknown'),
    );

    final todos = ref.watch(todosProvider(widget.projectId));
    final notes = ref.watch(notesProvider(widget.projectId));
    final snippets = ref.watch(snippetsProvider(widget.projectId));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final activeTodos = todos.where((t) => !t.isCompleted).toList();
    final completedTodos = todos.where((t) => t.isCompleted).toList();

    final color = AppColors.getColor(project.colorIndex);
    final icon = AppColors.getIcon(project.iconIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', l10n.navigationProjects, project.name],
          onTap: [
            () {
              ref.read(navSectionProvider.notifier).state = NavSection.projects;
              ref.read(selectedProjectIdProvider.notifier).state = null;
              ref.read(selectedSnippetIdProvider.notifier).state = null;
              ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
            },
            () {
              ref.read(navSectionProvider.notifier).state = NavSection.projects;
              ref.read(selectedProjectIdProvider.notifier).state = null;
              ref.read(selectedSnippetIdProvider.notifier).state = null;
              ref.read(selectedSnippetProjectIdProvider.notifier).state = null;
            },
            null,
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(project.name, style: textTheme.titleLarge),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.label_outline, size: 18),
                onPressed: () => _showManageTags(context, project),
                tooltip: l10n.tooltipTags,
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz, size: 18),
                onPressed: () => _showProjectOptions(context, ref, project),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _ExpandableHeader(
                title: l10n.labelTasks,
                count: activeTodos.length,
                isExpanded: _tasksExpanded,
                onToggle: () =>
                    setState(() => _tasksExpanded = !_tasksExpanded),
                onAdd: () => showDialog(
                  context: context,
                  builder: (_) => AddTodoDialog(projectId: widget.projectId),
                ),
                l10n: l10n,
              ),
              if (_tasksExpanded) ...[
                ...activeTodos.map(
                  (todo) => Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: TaskCard(
                      todo: todo,
                      projectName: project.name,
                      showWorkTimer: true,
                      onToggle: () => ref
                          .read(todosProvider(widget.projectId).notifier)
                          .toggleComplete(todo.id),
                      onTap: () => _editTodo(context, ref, todo, project),
                      onDismissed: (_) => ref
                          .read(todosProvider(widget.projectId).notifier)
                          .deleteTodo(todo.id),
                      dragHandle: ReorderableDragStartListener(
                        index: activeTodos.indexOf(todo),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.drag_indicator,
                            size: 16,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (activeTodos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 40,
                      top: 12,
                      bottom: 12,
                    ),
                    child: Text(
                      l10n.emptyStateNoTasks,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ),
                if (completedTodos.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 40,
                      top: 18,
                      bottom: 12,
                    ),
                    child: Text(
                      l10n.labelCompleted(completedTodos.length),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ...completedTodos.map(
                    (todo) => Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: TaskCard(
                        todo: todo,
                        projectName: project.name,
                        onToggle: () => ref
                            .read(todosProvider(widget.projectId).notifier)
                            .toggleComplete(todo.id),
                        onTap: () => _editTodo(context, ref, todo, project),
                        onDismissed: (_) => ref
                            .read(todosProvider(widget.projectId).notifier)
                            .deleteTodo(todo.id),
                      ),
                    ),
                  ),
                ],
                const Divider(height: 1, indent: 40, endIndent: 16),
              ],
              _ExpandableHeader(
                title: l10n.labelNotes,
                count: notes.length,
                isExpanded: _notesExpanded,
                onToggle: () =>
                    setState(() => _notesExpanded = !_notesExpanded),
                onAdd: () => showDialog(
                  context: context,
                  builder: (_) => AddNoteDialog(projectId: widget.projectId),
                ),
                l10n: l10n,
              ),
              if (_notesExpanded) ...[
                if (notes.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 40,
                      top: 30,
                      bottom: 30,
                    ),
                    child: Text(
                      l10n.emptyStateNoNotes,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  )
                else
                  ...notes.map((note) {
                    String? linkedTaskTitle;
                    if (note.linkedTaskId != null) {
                      try {
                        linkedTaskTitle = todos
                            .firstWhere((t) => t.id == note.linkedTaskId)
                            .title;
                      } catch (_) {}
                    }
                    return Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteEditorScreen(note: note),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.3,
                                ),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface,
                                  decoration:
                                      linkedTaskTitle != null &&
                                          completedTodos.any(
                                            (t) => t.id == note.linkedTaskId,
                                          )
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (note.content.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  note.content,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                    decoration:
                                        linkedTaskTitle != null &&
                                            completedTodos.any(
                                              (t) => t.id == note.linkedTaskId,
                                            )
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor:
                                        colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (linkedTaskTitle != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.link,
                                      size: 12,
                                      color:
                                          completedTodos.any(
                                            (t) => t.id == note.linkedTaskId,
                                          )
                                          ? colorScheme.onSurfaceVariant
                                          : colorScheme.primary.withValues(
                                              alpha: 0.5,
                                            ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        linkedTaskTitle,
                                        style: textTheme.bodySmall?.copyWith(
                                          color:
                                              completedTodos.any(
                                                (t) =>
                                                    t.id == note.linkedTaskId,
                                              )
                                              ? colorScheme.onSurfaceVariant
                                              : colorScheme.primary.withValues(
                                                  alpha: 0.6,
                                                ),
                                          fontSize: 11,
                                          decoration:
                                              completedTodos.any(
                                                (t) =>
                                                    t.id == note.linkedTaskId,
                                              )
                                              ? TextDecoration.lineThrough
                                              : null,
                                          decorationColor:
                                              colorScheme.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
              _ExpandableHeader(
                title: l10n.labelCodeSnippets,
                count: snippets.length,
                isExpanded: _snippetsExpanded,
                onToggle: () =>
                    setState(() => _snippetsExpanded = !_snippetsExpanded),
                onAdd: () => showDialog(
                  context: context,
                  builder: (_) =>
                      AddCodeSnippetDialog(projectId: widget.projectId),
                ),
                l10n: l10n,
              ),
              if (_snippetsExpanded) ...[
                if (snippets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 40,
                      top: 30,
                      bottom: 30,
                    ),
                    child: Text(
                      l10n.emptyStateNoCodeSnippets,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  )
                else
                  ...snippets.map((snippet) {
                    String? linkedTaskTitle;
                    if (snippet.linkedTaskId != null) {
                      try {
                        linkedTaskTitle = todos
                            .firstWhere((t) => t.id == snippet.linkedTaskId)
                            .title;
                      } catch (_) {}
                    }
                    return Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: InkWell(
                        onTap: () {
                          ref.read(selectedSnippetIdProvider.notifier).state =
                              snippet.id;
                          ref
                              .read(selectedSnippetProjectIdProvider.notifier)
                              .state = snippet
                              .projectId;
                        },
                        onLongPress: () =>
                            _showSnippetOptions(context, ref, snippet),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.3,
                                ),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LanguageIcons.getIcon(snippet.language),
                                size: 16,
                                color: LanguageColors.getColor(
                                  snippet.language,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snippet.title,
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    if (snippet.code.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        _getCodePreview(snippet.code),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant
                                              .withValues(alpha: 0.5),
                                          fontFamily: 'monospace',
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (linkedTaskTitle != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.link,
                                            size: 12,
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.5),
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              linkedTaskTitle,
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: colorScheme.primary
                                                        .withValues(alpha: 0.6),
                                                    fontSize: 11,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  void _editTodo(
    BuildContext context,
    WidgetRef ref,
    TodoItem todo,
    Project project,
  ) async {
    final updated = await showDialog<TodoItem>(
      context: context,
      builder: (_) => EditTodoDialog(todo: todo, availableTags: project.tags),
    );
    if (updated != null) {
      ref.read(todosProvider(widget.projectId).notifier).updateTodo(updated);
    }
  }

  void _showManageTags(BuildContext context, Project project) {
    showDialog(
      context: context,
      builder: (_) => ManageTagsDialog(project: project),
    );
  }

  void _showSnippetOptions(BuildContext context, WidgetRef ref, snippet) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit_outlined, color: colorScheme.primary),
                title: Text(l10n.menuEdit),
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (_) => EditCodeSnippetDialog(snippet: snippet),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: Text(
                  l10n.menuDelete,
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ref
                      .read(snippetsProvider(widget.projectId).notifier)
                      .deleteSnippet(snippet.id);
                  if (ref.read(selectedSnippetIdProvider) == snippet.id) {
                    ref.read(selectedSnippetIdProvider.notifier).state = null;
                    ref.read(selectedSnippetProjectIdProvider.notifier).state =
                        null;
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCodePreview(String code) {
    final lines = code.split('\n').where((l) => l.trim().isNotEmpty).take(2);
    return lines.join(' ').trim();
  }

  void _showProjectOptions(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit_outlined, color: colorScheme.primary),
                title: Text(l10n.menuEdit),
                onTap: () {
                  Navigator.pop(ctx);
                  showDialog(
                    context: context,
                    builder: (_) => EditProjectDialog(project: project),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: Text(
                  l10n.menuDelete,
                  style: TextStyle(color: colorScheme.error),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(projectsProvider.notifier).deleteProject(project.id);
                  ref.read(selectedProjectIdProvider.notifier).state = null;
                  ref.read(selectedSnippetIdProvider.notifier).state = null;
                  ref.read(selectedSnippetProjectIdProvider.notifier).state =
                      null;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
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
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ExpandableHeader extends StatelessWidget {
  final String title;
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onAdd;
  final AppLocalizations l10n;

  const _ExpandableHeader({
    required this.title,
    required this.count,
    required this.isExpanded,
    required this.onToggle,
    required this.onAdd,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Text(
                '$count',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: onAdd,
              visualDensity: VisualDensity.compact,
              tooltip: title == l10n.labelNotes
                  ? l10n.tooltipNewNote
                  : l10n.tooltipNewTask,
            ),
          ],
        ),
      ),
    );
  }
}
