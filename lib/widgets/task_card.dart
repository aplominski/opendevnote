import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/todo_item.dart';
import 'package:opendevnote/models/work_session.dart';
import 'package:opendevnote/providers/work_time_provider.dart';

class TaskCard extends ConsumerWidget {
  final TodoItem todo;
  final String projectName;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final DismissDirectionCallback onDismissed;
  final Widget? dragHandle;
  final bool showWorkTimer;

  const TaskCard({
    super.key,
    required this.todo,
    required this.projectName,
    required this.onToggle,
    this.onTap,
    required this.onDismissed,
    this.dragHandle,
    this.showWorkTimer = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final now = DateTime.now();
    Color? bgColor;
    if (todo.dueDate != null && !todo.isCompleted) {
      final diff = todo.dueDate!.difference(now);
      if (diff.isNegative) {
        bgColor = colorScheme.errorContainer.withValues(alpha: 0.35);
      } else if (diff.inMinutes <= 30) {
        bgColor = Colors.orange.withValues(alpha: 0.08);
      }
    }

    WorkSession? activeSession;
    if (showWorkTimer) {
      final sessions = ref.watch(workSessionsProvider);
      activeSession = sessions
          .where((s) => s.isActive && s.taskId == todo.id)
          .firstOrNull;
    }

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: onDismissed,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: colorScheme.errorContainer.withValues(alpha: 0.2),
        child: Icon(Icons.delete_outline, color: colorScheme.error, size: 18),
      ),
      child: MouseRegion(
        child: InkWell(
          onTap: onTap,
          hoverColor: colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 1, right: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: todo.isCompleted
                              ? colorScheme.primary
                              : colorScheme.outline.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                        color: todo.isCompleted
                            ? colorScheme.primary
                            : Colors.transparent,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 100),
                        child: todo.isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 150),
                              style: textTheme.bodyLarge!.copyWith(
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.isCompleted
                                    ? colorScheme.onSurfaceVariant.withValues(
                                        alpha: 0.4,
                                      )
                                    : colorScheme.onSurface,
                              ),
                              child: Text(todo.title),
                            ),
                          ),
                          if (todo.tags.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            ...todo.tags
                                .take(2)
                                .map(
                                  (tag) => Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      '#$tag',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ],
                      ),
                      if (todo.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            todo.description,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Row(
                        children: [
                          Text(
                            projectName,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.4,
                              ),
                              fontSize: 11,
                            ),
                          ),
                          if (todo.dueDate != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(todo.dueDate!),
                              style: textTheme.bodySmall?.copyWith(
                                color: todo.isOverdue
                                    ? colorScheme.error
                                    : colorScheme.onSurfaceVariant.withValues(
                                        alpha: 0.4,
                                      ),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (showWorkTimer && !todo.isCompleted) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      if (activeSession != null) {
                        ref
                            .read(workSessionsProvider.notifier)
                            .stopSession(activeSession.id);
                      } else {
                        ref
                            .read(workSessionsProvider.notifier)
                            .startSession(
                              taskId: todo.id,
                              projectId: todo.projectId,
                            );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        activeSession != null
                            ? Icons.stop_circle
                            : Icons.play_circle_outline,
                        size: 20,
                        color: activeSession != null
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.35,
                              ),
                      ),
                    ),
                  ),
                ],
                if (dragHandle != null) dragHandle!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final timeStr =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (target == today) return 'Dzisiaj $timeStr';
    if (target == today.add(const Duration(days: 1))) return 'Jutro $timeStr';
    return '${date.day}.${date.month.toString().padLeft(2, '0')}';
  }
}
