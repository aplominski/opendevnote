import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/event.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/providers/project_provider.dart';
import 'package:opendevnote/providers/todo_provider.dart';
import 'package:opendevnote/theme/app_colors.dart';
import 'package:opendevnote/widgets/time_grid_column.dart';
import 'package:opendevnote/screens/dialogs/add_event_dialog.dart';

class DayDetailPage extends ConsumerWidget {
  const DayDetailPage({super.key});

  String _formatDate(DateTime date) {
    final weekdays = ['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela'];
    final months = ['stycznia', 'lutego', 'marca', 'kwietnia', 'maja', 'czerwca', 'lipca', 'sierpnia', 'września', 'października', 'listopada', 'grudnia'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final selectedDate = ref.watch(selectedCalendarDateProvider);
    final todos = ref.watch(todosWithDueDateProvider);
    final events = ref.watch(allEventsProvider);
    final projects = ref.watch(projectsProvider);

    final dayTodos = todos.where((t) => _isSameDay(t.dueDate!, selectedDate)).toList();
    final dayEvents = events.where((e) => _isEventOnDay(e, selectedDate)).toList();

    return Focus(
    autofocus: true,
    onKeyEvent: (node, event) {
      if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
        ref.read(calendarViewModeProvider.notifier).state = ref.read(previousViewModeProvider);
        Navigator.pop(context);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final newDate = selectedDate.subtract(const Duration(days: 1));
            ref.read(selectedCalendarDateProvider.notifier).state = newDate;
          },
        ),
        title: Text(_formatDate(selectedDate)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final newDate = selectedDate.add(const Duration(days: 1));
              ref.read(selectedCalendarDateProvider.notifier).state = newDate;
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_day),
            onPressed: () {},
            tooltip: 'Widok dnia',
          ),
          IconButton(
            icon: const Icon(Icons.view_week),
            onPressed: () {
              ref.read(calendarViewModeProvider.notifier).state = CalendarViewMode.week;
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            tooltip: 'Widok tygodnia',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_view_month),
            onPressed: () {
              ref.read(calendarViewModeProvider.notifier).state = CalendarViewMode.month;
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            tooltip: 'Widok miesiąca',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AddEventDialog(initialDate: selectedDate),
              );
            },
          ),
        ],
      ),
      body: _DayTimeGridBody(
        selectedDate: selectedDate,
        dayEvents: dayEvents,
        dayTodos: dayTodos,
        projects: projects,
        colorScheme: colorScheme,
        onEventDelete: (event) {
          ref.read(allEventsProvider.notifier).deleteEvent(event.id);
        },
        onSwipeLeft: () {
          final newDate = selectedDate.add(const Duration(days: 1));
          ref.read(selectedCalendarDateProvider.notifier).state = newDate;
        },
        onSwipeRight: () {
          final newDate = selectedDate.subtract(const Duration(days: 1));
          ref.read(selectedCalendarDateProvider.notifier).state = newDate;
        },
      ),
    ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isEventOnDay(Event event, DateTime day) {
    final eventStart = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
    final checkDay = DateTime(day.year, day.month, day.day);

    if (event.endDate != null) {
      final eventEnd = DateTime(event.endDate!.year, event.endDate!.month, event.endDate!.day);
      return !checkDay.isBefore(eventStart) && !checkDay.isAfter(eventEnd);
    }
    return _isSameDay(event.startDate, day);
  }
}

class _DayTimeGridBody extends StatefulWidget {
  final DateTime selectedDate;
  final List<Event> dayEvents;
  final List<dynamic> dayTodos;
  final List<dynamic> projects;
  final ColorScheme colorScheme;
  final void Function(Event event) onEventDelete;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;

  const _DayTimeGridBody({
    required this.selectedDate,
    required this.dayEvents,
    required this.dayTodos,
    required this.projects,
    required this.colorScheme,
    required this.onEventDelete,
    this.onSwipeLeft,
    this.onSwipeRight,
  });

  @override
  State<_DayTimeGridBody> createState() => _DayTimeGridBodyState();
}

class _DayTimeGridBodyState extends State<_DayTimeGridBody> {
  late final TransformationController _controller;
  static const double _hourHeight = 60.0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = 24 * _hourHeight;
        final viewportHeight = constraints.maxHeight;
        final maxScroll = (totalHeight - viewportHeight).clamp(0.0, double.infinity);
        final now = DateTime.now();
        final initialOffset = ((now.hour - 1) * _hourHeight).clamp(0.0, maxScroll);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_initialized) {
            _initialized = true;
            _controller.value = Matrix4.identity()..translate(0.0, -initialOffset);
          }
        });

        return InteractiveViewer(
          transformationController: _controller,
          panAxis: PanAxis.vertical,
          constrained: false,
          alignment: Alignment.topLeft,
          minScale: 1.0,
          maxScale: 1.0,
          boundaryMargin: EdgeInsets.only(top: 0, bottom: 0),
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! > 500) {
                  widget.onSwipeRight?.call();
                } else if (details.primaryVelocity! < -500) {
                  widget.onSwipeLeft?.call();
                }
              }
            },
            child: SizedBox(
            width: constraints.maxWidth,
            height: totalHeight,
            child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
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
                          color: widget.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TimeGridColumn(
              day: widget.selectedDate,
              events: widget.dayEvents,
              todos: widget.dayTodos.cast(),
              projects: widget.projects.cast(),
              hourHeight: _hourHeight,
              onEventTap: (event) {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) {
                    final cs = Theme.of(ctx).colorScheme;
                    return SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: Theme.of(ctx).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}${event.endDate != null ? ' - ${event.endDate!.hour.toString().padLeft(2, '0')}:${event.endDate!.minute.toString().padLeft(2, '0')}' : ''}',
                              style: Theme.of(ctx).textTheme.bodySmall,
                            ),
                            if (event.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(event.description),
                            ],
                            const SizedBox(height: 16),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: cs.error,
                              onPressed: () {
                                widget.onEventDelete(event);
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
          ],
        ),
          ),
          ),
        );
      },
    );
  }
}
