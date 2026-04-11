import 'package:flutter/material.dart';
import 'package:opendevnote/models/event.dart';
import 'package:opendevnote/models/todo_item.dart';
import 'package:opendevnote/models/project.dart';
import 'package:opendevnote/theme/app_colors.dart';

class TimeGridColumn extends StatelessWidget {
  final DateTime day;
  final List<Event> events;
  final List<TodoItem> todos;
  final List<Project> projects;
  final void Function(Event event)? onEventTap;
  final double hourHeight;

  const TimeGridColumn({
    super.key,
    required this.day,
    required this.events,
    required this.todos,
    required this.projects,
    required this.hourHeight,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;

    final sortedEvents = List<Event>.from(events)
      ..sort((a, b) {
        final cmp = a.startDate.compareTo(b.startDate);
        if (cmp != 0) return cmp;
        return _getEventHeight(b).compareTo(_getEventHeight(a));
      });

    final sortedTodos = List<TodoItem>.from(todos)
      ..sort((a, b) => (a.dueDate ?? DateTime(2000)).compareTo(
            b.dueDate ?? DateTime(2000),
          ));

    final eventColumns = _assignColumns(sortedEvents);

    return SizedBox(
      height: 24 * hourHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Hour lines
              ...List.generate(24, (hour) {
                return Positioned(
                  top: hour * hourHeight,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: Container(color: colorScheme.outlineVariant),
                );
              }),

              // Half-hour lines
              ...List.generate(24, (hour) {
                return Positioned(
                  top: hour * hourHeight + hourHeight / 2,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: Container(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                );
              }),

              // Now indicator
              if (isToday)
                Positioned(
                  top: now.hour * hourHeight + now.minute.toDouble(),
                  left: 0,
                  right: 0,
                  height: 2,
                  child: Container(color: Colors.red),
                ),

              // Events with column layout
              ...sortedEvents.map((event) {
                final col = eventColumns[event.id]!;
                return _buildEventBlock(
                    event, col.column, col.totalColumns, totalWidth, colorScheme);
              }),

              // Todos
              ...sortedTodos.map((todo) => _buildTodoBlock(todo, colorScheme)),
            ],
          );
        },
      ),
    );
  }

  // --- Overlap algorithm ---

  double _getEventTop(Event event) =>
      event.startDate.hour * hourHeight + event.startDate.minute.toDouble();

  double _getEventHeight(Event event) {
    if (event.endDate == null) return hourHeight;
    final duration = event.endDate!.difference(event.startDate).inMinutes;
    return duration.clamp(30, 1440).toDouble();
  }

  double _getEventEnd(Event event) => _getEventTop(event) + _getEventHeight(event);

  Map<String, _ColumnAssignment> _assignColumns(List<Event> sorted) {
    if (sorted.isEmpty) return {};
    if (sorted.length == 1) return {sorted.first.id: (column: 0, totalColumns: 1)};

    final columnEnds = <double>[];
    final assignments = <String, _ColumnAssignment>{};
    int maxColumns = 1;

    for (final event in sorted) {
      final top = _getEventTop(event);
      final end = _getEventEnd(event);

      int col = 0;
      while (col < columnEnds.length && columnEnds[col] > top) {
        col++;
      }

      if (col < columnEnds.length) {
        columnEnds[col] = end;
      } else {
        columnEnds.add(end);
      }

      maxColumns = maxColumns > columnEnds.length ? maxColumns : columnEnds.length;
      assignments[event.id] = (column: col, totalColumns: 0);
    }

    // Second pass: set totalColumns
    for (final id in assignments.keys.toList()) {
      assignments[id] = (
        column: assignments[id]!.column,
        totalColumns: maxColumns,
      );
    }

    return assignments;
  }

  // --- Event block ---

  Widget _buildEventBlock(Event event, int col, int totalCols,
      double totalWidth, ColorScheme colorScheme) {
    final top = _getEventTop(event);
    final height = _getEventHeight(event);
    final color = AppColors.getColor(event.colorIndex);

    final usableWidth = totalWidth - 4; // 2px padding each side
    final colWidth = usableWidth / totalCols;
    final leftPx = 2 + col * colWidth;
    final blockWidth = colWidth - 1; // 1px gap between columns

    return Positioned(
      top: top,
      height: height,
      left: leftPx,
      width: blockWidth,
      child: GestureDetector(
        onTap: () => onEventTap?.call(event),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(3),
          ),
          child: height > 40
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      maxLines: height > 60 ? 3 : 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (height > 50)
                      Text(
                        _formatEventTime(event),
                        style:
                            const TextStyle(fontSize: 8, color: Colors.white70),
                      ),
                  ],
                )
              : Text(
                  event.title,
                  style: const TextStyle(fontSize: 9, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
        ),
      ),
    );
  }

  String _formatEventTime(Event event) {
    final start =
        '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}';
    if (event.endDate == null) return start;
    final end =
        '${event.endDate!.hour.toString().padLeft(2, '0')}:${event.endDate!.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  // --- Todo block ---

  Widget _buildTodoBlock(TodoItem todo, ColorScheme colorScheme) {
    if (todo.dueDate == null) return const SizedBox.shrink();
    final top = todo.dueDate!.hour * hourHeight + todo.dueDate!.minute.toDouble();
    final color = _getProjectColor(todo.projectId);

    return Positioned(
      top: top,
      left: 2,
      right: 2,
      height: 22,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(3),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            todo.title,
            style: TextStyle(
              fontSize: 10,
              color: todo.isCompleted
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onSurface,
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Color _getProjectColor(String? projectId) {
    if (projectId == null) return Colors.grey;
    final project = projects.where((p) => p.id == projectId).firstOrNull;
    if (project == null) return Colors.grey;
    return AppColors.getColor(project.colorIndex);
  }
}

typedef _ColumnAssignment = ({int column, int totalColumns});
