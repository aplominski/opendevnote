import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:opendevnote/models/todo_item.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/providers/project_provider.dart';
import 'package:opendevnote/services/notification_service.dart';

const _uuid = Uuid();
final _notifications = NotificationService();

final todosProvider =
    StateNotifierProvider.family<TodosNotifier, List<TodoItem>, String>((
      ref,
      projectId,
    ) {
      final storage = ref.watch(storageServiceProvider);
      return TodosNotifier(
        projectId,
        storage.getTodosForProject(projectId),
        storage,
      );
    });

class TodosNotifier extends StateNotifier<List<TodoItem>> {
  final String _projectId;
  final dynamic _storage;

  TodosNotifier(this._projectId, super.todos, this._storage);

  Future<void> addTodo({
    required String title,
    String description = '',
    List<String>? tags,
    DateTime? dueDate,
  }) async {
    final todo = TodoItem(
      id: _uuid.v4(),
      projectId: _projectId,
      title: title,
      description: description,
      tags: tags,
      dueDate: dueDate,
      sortOrder: state.length,
    );
    await _storage.saveTodo(todo);
    state = [...state, todo];

    // Schedule notification if due date is set
    if (todo.dueDate != null) {
      await _notifications.scheduleTaskNotification(
        notificationId: NotificationService.idFromTaskId(todo.id),
        taskTitle: todo.title,
        dueDate: todo.dueDate!,
      );
    }
  }

  Future<void> updateTodo(TodoItem todo) async {
    await _storage.saveTodo(todo);
    state = [
      for (final t in state)
        if (t.id == todo.id) todo else t,
    ];

    // Update notification
    await _notifications.cancelNotification(
      NotificationService.idFromTaskId(todo.id),
    );
    if (todo.dueDate != null && !todo.isCompleted) {
      await _notifications.scheduleTaskNotification(
        notificationId: NotificationService.idFromTaskId(todo.id),
        taskTitle: todo.title,
        dueDate: todo.dueDate!,
      );
    }
  }

  Future<void> toggleComplete(String id) async {
    final todo = state.firstWhere((t) => t.id == id);
    final updated = todo.copyWith(isCompleted: !todo.isCompleted);
    await _storage.saveTodo(updated);
    state = [
      for (final t in state)
        if (t.id == id) updated else t,
    ];

    // Cancel notification if completed, reschedule if uncompleted
    final notifId = NotificationService.idFromTaskId(id);
    await _notifications.cancelNotification(notifId);
    if (!updated.isCompleted && updated.dueDate != null) {
      await _notifications.scheduleTaskNotification(
        notificationId: notifId,
        taskTitle: updated.title,
        dueDate: updated.dueDate!,
      );
    }
  }

  Future<void> deleteTodo(String id) async {
    await _storage.deleteTodo(id);
    state = state.where((t) => t.id != id).toList();

    // Cancel notification
    await _notifications.cancelNotification(
      NotificationService.idFromTaskId(id),
    );
  }

  Future<void> reorderTodos(int oldIndex, int newIndex) async {
    final todos = List<TodoItem>.from(state);
    if (newIndex > oldIndex) newIndex--;
    final todo = todos.removeAt(oldIndex);
    todos.insert(newIndex, todo);
    await _storage.updateTodosOrder(todos);
    state = todos;
  }

  List<TodoItem> filterByTag(String? tag) {
    if (tag == null) return state;
    return state.where((t) => t.tags.contains(tag)).toList();
  }

  List<TodoItem> search(String query) {
    final lower = query.toLowerCase();
    return state
        .where(
          (t) =>
              t.title.toLowerCase().contains(lower) ||
              t.description.toLowerCase().contains(lower) ||
              t.tags.any((tag) => tag.toLowerCase().contains(lower)),
        )
        .toList();
  }
}

// Provider for getting project stats
final projectStatsProvider = Provider.family<Map<String, int>, String>((
  ref,
  projectId,
) {
  final todos = ref.watch(todosProvider(projectId));
  final total = todos.length;
  final completed = todos.where((t) => t.isCompleted).length;
  return {'total': total, 'completed': completed};
});

// All todos across all projects (for Today/Unplanned views)
final allTodosProvider = Provider<List<TodoItem>>((ref) {
  final projects = ref.watch(projectsProvider);
  final allTodos = <TodoItem>[];
  for (final project in projects) {
    // Watch each project's todos provider so this re-evaluates on any change
    final todos = ref.watch(todosProvider(project.id));
    allTodos.addAll(todos);
  }
  return allTodos;
});

// Today todos (sorted by dueDate ascending - closest first)
final todayTodosProvider = Provider<List<TodoItem>>((ref) {
  final allTodos = ref.watch(allTodosProvider);
  final todos = allTodos.where((t) => t.isDueToday && !t.isCompleted).toList();
  todos.sort((a, b) {
    final aDate = a.dueDate;
    final bDate = b.dueDate;
    if (aDate == null && bDate == null) return 0;
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return aDate.compareTo(bDate);
  });
  return todos;
});

// Inbox todos (no due date)
final inboxTodosProvider = Provider<List<TodoItem>>((ref) {
  final allTodos = ref.watch(allTodosProvider);
  return allTodos.where((t) => t.isInbox && !t.isCompleted).toList();
});

// Overdue todos
final overdueTodosProvider = Provider<List<TodoItem>>((ref) {
  final allTodos = ref.watch(allTodosProvider);
  return allTodos.where((t) => t.isOverdue).toList();
});
