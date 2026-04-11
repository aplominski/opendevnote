import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/event.dart';
import 'package:opendevnote/models/todo_item.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/providers/project_provider.dart';
import 'package:opendevnote/providers/todo_provider.dart';
import 'package:opendevnote/theme/app_colors.dart';
import 'package:opendevnote/widgets/time_grid_column.dart';
import 'package:opendevnote/screens/day_detail_page.dart';
import 'package:opendevnote/screens/dialogs/add_event_dialog.dart';
import 'package:opendevnote/l10n/app_localizations.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _currentMonth;
  late final TransformationController _weekController;
  static const double _hourHeight = 60.0;
  bool _weekInitialized = false;

  @override
  void initState() {
    super.initState();
    final selected = ref.read(selectedCalendarDateProvider);
    _currentMonth = DateTime(selected.year, selected.month);
    _weekController = TransformationController();
  }

  @override
  void dispose() {
    _weekController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _previousDay() {
    final currentDate = ref.read(selectedCalendarDateProvider);
    final newDate = currentDate.subtract(const Duration(days: 1));
    ref.read(selectedCalendarDateProvider.notifier).state = newDate;
    setState(() {
      _currentMonth = DateTime(newDate.year, newDate.month);
    });
  }

  void _nextDay() {
    final currentDate = ref.read(selectedCalendarDateProvider);
    final newDate = currentDate.add(const Duration(days: 1));
    ref.read(selectedCalendarDateProvider.notifier).state = newDate;
    setState(() {
      _currentMonth = DateTime(newDate.year, newDate.month);
    });
  }

  void _goToToday() {
    setState(() {
      _currentMonth = DateTime.now();
    });
    ref.read(selectedCalendarDateProvider.notifier).state = DateTime.now();
  }

  void _onDayTap(DateTime day) {
    ref.read(previousViewModeProvider.notifier).state = ref.read(
      calendarViewModeProvider,
    );
    ref.read(selectedCalendarDateProvider.notifier).state = day;
    ref.read(calendarViewModeProvider.notifier).state = CalendarViewMode.day;
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DayDetailPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final selectedDate = ref.read(selectedCalendarDateProvider);
    showDialog(
      context: context,
      builder: (_) => AddEventDialog(initialDate: selectedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(calendarViewModeProvider);
    final isMonthView = viewMode == CalendarViewMode.month;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            if (HardwareKeyboard.instance.isControlPressed) {
              _previousDay();
              return KeyEventResult.handled;
            } else if (viewMode == CalendarViewMode.week) {
              ref.read(selectedCalendarDateProvider.notifier).state = ref
                  .read(selectedCalendarDateProvider)
                  .subtract(const Duration(days: 7));
              return KeyEventResult.handled;
            } else {
              _previousMonth();
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            if (HardwareKeyboard.instance.isControlPressed) {
              _nextDay();
              return KeyEventResult.handled;
            } else if (viewMode == CalendarViewMode.week) {
              ref.read(selectedCalendarDateProvider.notifier).state = ref
                  .read(selectedCalendarDateProvider)
                  .add(const Duration(days: 7));
              return KeyEventResult.handled;
            } else {
              _nextMonth();
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final viewMode = ref.watch(calendarViewModeProvider);

    switch (viewMode) {
      case CalendarViewMode.week:
        return _buildWeekView(context);
      case CalendarViewMode.day:
        return _buildDayView(context);
      case CalendarViewMode.month:
        return _buildMonthView(context);
    }
  }

  Widget _buildMonthView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final todos = ref.watch(todosWithDueDateProvider);
    final events = ref.watch(allEventsProvider);
    final projects = ref.watch(projectsProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday;

    final monthNames = [
      l10n.monthJanuary,
      l10n.monthFebruary,
      l10n.monthMarch,
      l10n.monthApril,
      l10n.monthMay,
      l10n.monthJune,
      l10n.monthJuly,
      l10n.monthAugust,
      l10n.monthSeptember,
      l10n.monthOctober,
      l10n.monthNovember,
      l10n.monthDecember,
    ];

    final weekdayNames = [
      l10n.weekdayShortAltMon,
      l10n.weekdayShortAltTue,
      l10n.weekdayShortAltWed,
      l10n.weekdayShortAltThu,
      l10n.weekdayShortAltFri,
      l10n.weekdayShortAltSat,
      l10n.weekdayShortAltSun,
    ];

    final allDays = <DateTime>[];

    final prevMonth = DateTime(_currentMonth.year, _currentMonth.month, 0);
    final daysInPrevMonth = prevMonth.day;
    for (int i = firstWeekday - 1; i > 0; i--) {
      allDays.add(
        DateTime(
          _currentMonth.year,
          _currentMonth.month - 1,
          daysInPrevMonth - i + 1,
        ),
      );
    }

    for (int i = 1; i <= daysInMonth; i++) {
      allDays.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }

    final remainingDays = 42 - allDays.length;
    for (int i = 1; i <= remainingDays; i++) {
      allDays.add(DateTime(_currentMonth.year, _currentMonth.month + 1, i));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousMonth,
        ),
        title: Text(
          '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
          ),
          IconButton(
            icon: const Icon(Icons.view_day),
            onPressed: () => ref.read(calendarViewModeProvider.notifier).state =
                CalendarViewMode.day,
            tooltip: l10n.tooltipDayView,
          ),
          IconButton(
            icon: const Icon(Icons.view_week),
            onPressed: () => ref.read(calendarViewModeProvider.notifier).state =
                CalendarViewMode.week,
            tooltip: l10n.tooltipWeekView,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_view_month),
            onPressed: () => ref.read(calendarViewModeProvider.notifier).state =
                CalendarViewMode.month,
            tooltip: l10n.tooltipMonthView,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEventDialog(context),
            tooltip: l10n.tooltipNewEvent,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
              top: 8,
              bottom: 4,
            ),
            child: Row(
              children: weekdayNames.map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final padding = 8.0;
                final cellHeight = (constraints.maxHeight - 5 * 2) / 6;
                final cellWidth =
                    (constraints.maxWidth - padding * 2 - 6 * 2) / 7;
                final cellSize = cellHeight < cellWidth
                    ? cellHeight
                    : cellWidth;

                return Container(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 4,
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisExtent: cellSize,
                      childAspectRatio: 1,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                    ),
                    itemCount: 42,
                    itemBuilder: (context, index) {
                      final day = allDays[index];
                      final isCurrentMonth = day.month == _currentMonth.month;
                      final isToday =
                          day.year == today.year &&
                          day.month == today.month &&
                          day.day == today.day;

                      final dayTodos = todos
                          .where((t) => _isSameDay(t.dueDate!, day))
                          .toList();
                      final dayEvents = events
                          .where((e) => _isEventOnDay(e, day))
                          .toList();

                      final todoColors = <int>[];
                      for (final todo in dayTodos) {
                        final project = projects
                            .where((p) => p.id == todo.projectId)
                            .firstOrNull;
                        if (project != null) {
                          todoColors.add(project.colorIndex);
                        }
                      }

                      final eventColors = <int>[];
                      for (final event in dayEvents) {
                        eventColors.add(event.colorIndex);
                      }

                      return GestureDetector(
                        key: ValueKey(day),
                        onTap: () => _onDayTap(day),
                        onLongPress: () => _showEventPopup(context, day),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isToday
                                ? colorScheme.primaryContainer
                                : null,
                            borderRadius: BorderRadius.circular(4),
                            border: isToday
                                ? Border.all(
                                    color: colorScheme.primary,
                                    width: 1.5,
                                    strokeAlign: BorderSide.strokeAlignInside,
                                  )
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isToday
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isToday
                                          ? colorScheme.primary
                                          : (isCurrentMonth
                                                ? colorScheme.onSurface
                                                : colorScheme.onSurfaceVariant
                                                      .withValues(alpha: 0.4)),
                                    ),
                                  ),
                                  if (todoColors.isNotEmpty && isCurrentMonth)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: todoColors.take(3).map((
                                          colorIndex,
                                        ) {
                                          return Container(
                                            width: 5,
                                            height: 5,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 0.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.getColor(
                                                colorIndex,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                ],
                              ),
                              if (eventColors.isNotEmpty && isCurrentMonth)
                                Positioned(
                                  bottom: 4,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: AppColors.getColor(
                                        eventColors.first,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final todos = ref.watch(todosWithDueDateProvider);
    final events = ref.watch(allEventsProvider);
    final projects = ref.watch(projectsProvider);

    final selectedDate = ref.watch(selectedCalendarDateProvider);
    final weekStart = selectedDate.subtract(
      Duration(days: selectedDate.weekday - 1),
    );
    final weekDays = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    final weekdayNames = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final newDate = selectedDate.subtract(const Duration(days: 7));
            ref.read(selectedCalendarDateProvider.notifier).state = newDate;
            setState(() {
              _currentMonth = DateTime(newDate.year, newDate.month);
            });
          },
        ),
        title: Text(
          '${weekDays.first.day.toString().padLeft(2, '0')}.${weekDays.first.month.toString().padLeft(2, '0')} - ${weekDays.last.day.toString().padLeft(2, '0')}.${weekDays.last.month.toString().padLeft(2, '0')}.${weekDays.last.year}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newDate = selectedDate.add(const Duration(days: 7));
              ref.read(selectedCalendarDateProvider.notifier).state = newDate;
              setState(() {
                _currentMonth = DateTime(newDate.year, newDate.month);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_day),
            onPressed: () => ref.read(calendarViewModeProvider.notifier).state =
                CalendarViewMode.day,
            tooltip: 'Widok dnia',
          ),
          IconButton(
            icon: const Icon(Icons.view_week),
            onPressed: () => ref.read(calendarViewModeProvider.notifier).state =
                CalendarViewMode.week,
            tooltip: 'Widok tygodnia',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_view_month),
            onPressed: () => ref.read(calendarViewModeProvider.notifier).state =
                CalendarViewMode.month,
            tooltip: 'Widok miesiąca',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEventDialog(context),
            tooltip: 'Dodaj wydarzenie (Ctrl+E)',
          ),
        ],
      ),
      body: Column(
        children: [
          // Day headers
          Row(
            children: [
              const SizedBox(width: 48),
              ...weekDays.map((day) {
                final isToday = _isSameDay(day, DateTime.now());
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onDayTap(day),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Text(
                            [
                              'Pn',
                              'Wt',
                              'Śr',
                              'Cz',
                              'Pt',
                              'So',
                              'Nd',
                            ][day.weekday - 1],
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: isToday
                                ? BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  )
                                : null,
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isToday
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isToday
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          // Time grid: InteractiveViewer for native scroll
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalHeight = 24 * _hourHeight;
                final viewportHeight = constraints.maxHeight;
                final maxScroll = (totalHeight - viewportHeight).clamp(
                  0.0,
                  double.infinity,
                );
                final now = DateTime.now();
                final initialOffset = ((now.hour - 1) * _hourHeight).clamp(
                  0.0,
                  maxScroll,
                );

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_weekInitialized) {
                    _weekInitialized = true;
                    _weekController.value = Matrix4.identity()
                      ..translate(0.0, -initialOffset);
                  }
                });

                return InteractiveViewer(
                  transformationController: _weekController,
                  panAxis: PanAxis.vertical,
                  constrained: false,
                  alignment: Alignment.topLeft,
                  minScale: 1.0,
                  maxScale: 1.0,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: totalHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hour labels
                        SizedBox(
                          width: 48,
                          child: Column(
                            children: List.generate(24, (hour) {
                              return SizedBox(
                                height: _hourHeight,
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Text(
                                      '${hour.toString().padLeft(2, '0')}:00',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        // Day columns
                        Expanded(
                          child: Row(
                            children: weekDays.map((day) {
                              final dayTodos = todos
                                  .where((t) => _isSameDay(t.dueDate!, day))
                                  .toList();
                              final dayEvents = events
                                  .where((e) => _isEventOnDay(e, day))
                                  .toList();

                              return Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: colorScheme.outlineVariant,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: InkWell(
                                    onTap: () => _onDayTap(day),
                                    onLongPress: () =>
                                        _showEventPopup(context, day),
                                    child: TimeGridColumn(
                                      day: day,
                                      events: dayEvents,
                                      todos: dayTodos,
                                      projects: projects,
                                      hourHeight: _hourHeight,
                                      onEventTap: (event) {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (ctx) {
                                            final cs = Theme.of(
                                              ctx,
                                            ).colorScheme;
                                            return SafeArea(
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      event.title,
                                                      style: Theme.of(
                                                        ctx,
                                                      ).textTheme.titleMedium,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}${event.endDate != null ? ' - ${event.endDate!.hour.toString().padLeft(2, '0')}:${event.endDate!.minute.toString().padLeft(2, '0')}' : ''}',
                                                      style: Theme.of(
                                                        ctx,
                                                      ).textTheme.bodySmall,
                                                    ),
                                                    if (event
                                                        .description
                                                        .isNotEmpty) ...[
                                                      const SizedBox(height: 8),
                                                      Text(event.description),
                                                    ],
                                                    const SizedBox(height: 16),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                      ),
                                                      color: cs.error,
                                                      onPressed: () {
                                                        ref
                                                            .read(
                                                              allEventsProvider
                                                                  .notifier,
                                                            )
                                                            .deleteEvent(
                                                              event.id,
                                                            );
                                                        Navigator.pop(ctx);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView(BuildContext context) {
    return const DayDetailPage();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isEventOnDay(Event event, DateTime day) {
    final eventStart = DateTime(
      event.startDate.year,
      event.startDate.month,
      event.startDate.day,
    );
    final checkDay = DateTime(day.year, day.month, day.day);

    if (event.endDate != null) {
      final eventEnd = DateTime(
        event.endDate!.year,
        event.endDate!.month,
        event.endDate!.day,
      );
      return !checkDay.isBefore(eventStart) && !checkDay.isAfter(eventEnd);
    }
    return _isSameDay(event.startDate, day);
  }

  void _showEventPopup(BuildContext context, DateTime day) {
    final todos = ref.read(todosWithDueDateProvider);
    final events = ref.read(allEventsProvider);
    final projects = ref.read(projectsProvider);

    final dayTodos = todos.where((t) => _isSameDay(t.dueDate!, day)).toList();
    final dayEvents = events.where((e) => _isEventOnDay(e, day)).toList();

    if (dayTodos.isEmpty && dayEvents.isEmpty) {
      _onDayTap(day);
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}.${day.year}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (dayTodos.isNotEmpty) ...[
                ...dayTodos.map((todo) {
                  final project = projects
                      .where((p) => p.id == todo.projectId)
                      .firstOrNull;
                  return ListTile(
                    key: ValueKey('popup_todo_${todo.id}'),
                    leading: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (value) {
                        ref
                            .read(todosProvider(todo.projectId).notifier)
                            .toggleComplete(todo.id);
                      },
                    ),
                    title: Text(todo.title),
                    subtitle: project != null ? Text(project.name) : null,
                    onTap: () {
                      Navigator.pop(context);
                      _onDayTap(day);
                    },
                  );
                }),
                if (dayEvents.isNotEmpty) const Divider(),
              ],
              ...dayEvents.map((event) {
                final timeStr =
                    '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}';
                return ListTile(
                  key: ValueKey('popup_event_${event.id}'),
                  leading: Icon(
                    Icons.event,
                    color: AppColors.getColor(event.colorIndex),
                  ),
                  title: Text(event.title),
                  subtitle: Text(timeStr),
                  onTap: () {
                    Navigator.pop(context);
                    _onDayTap(day);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
