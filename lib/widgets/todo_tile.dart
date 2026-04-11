import 'package:flutter/material.dart';
import 'package:opendevnote/models/todo_item.dart';

class TodoTile extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback? onTap;
  final DismissDirectionCallback onDismissed;
  final Widget? dragHandle;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    this.onTap,
    required this.onDismissed,
    this.dragHandle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: onDismissed,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: colorScheme.errorContainer.withValues(alpha: 0.3),
        child: Icon(Icons.delete_outline, color: colorScheme.error, size: 18),
      ),
      child: InkWell(
        onTap: onTap,
        hoverColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dragHandle != null) dragHandle!,
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(top: 2, right: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: todo.isCompleted
                            ? colorScheme.primary
                            : colorScheme.outline,
                        width: 1.5,
                      ),
                      color: todo.isCompleted
                          ? colorScheme.primary
                          : Colors.transparent,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 100),
                      child: todo.isCompleted
                          ? Icon(
                              Icons.check_rounded,
                              size: 12,
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
                    AnimatedDefaultTextStyle(
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
                    if (todo.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          todo.tags.map((t) => '#$t').join(' '),
                          style: textTheme.bodySmall?.copyWith(
                            fontFamily: 'Inter',
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
