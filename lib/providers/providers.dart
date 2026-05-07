import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/event.dart';
import 'package:opendevnote/models/todo_item.dart';
import 'package:opendevnote/providers/project_provider.dart';
import 'package:opendevnote/providers/todo_provider.dart';
import 'package:opendevnote/services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Locale provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  final storage = ref.watch(storageServiceProvider);
  final savedLocale = storage.getLocale();
  return LocaleNotifier(
    savedLocale != null ? Locale(savedLocale) : null,
    storage,
  );
});

class LocaleNotifier extends StateNotifier<Locale?> {
  final StorageService _storage;

  LocaleNotifier(super.locale, this._storage);

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    await _storage.saveLocale(locale?.languageCode);
  }
}

// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Active tag filter
final activeTagFilterProvider = StateProvider<String?>((ref) => null);

// Navigation state
enum NavSection {
  today,
  inbox,
  calendar,
  calculator,
  repositories,
  issues,
  pullRequests,
  workflows,
  projects,
  workTime,
  news,
  settings,
}

final navSectionProvider = StateProvider<NavSection>(
  (ref) => NavSection.projects,
);

// Selected project ID (null = projects list)
final selectedProjectIdProvider = StateProvider<String?>((ref) => null);

// Selected snippet (null = no snippet editor open)
final selectedSnippetIdProvider = StateProvider<String?>((ref) => null);
final selectedSnippetProjectIdProvider = StateProvider<String?>((ref) => null);

// Filter mode for project detail
enum TaskFilter { all, today, inbox }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

// Calendar state
final selectedCalendarDateProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

enum CalendarViewMode { day, week, month }

final calendarViewModeProvider = StateProvider<CalendarViewMode>(
  (ref) => CalendarViewMode.month,
);
final previousViewModeProvider = StateProvider<CalendarViewMode>(
  (ref) => CalendarViewMode.month,
);

// All events provider
final allEventsProvider = StateNotifierProvider<EventsNotifier, List<Event>>((
  ref,
) {
  final storage = ref.watch(storageServiceProvider);
  return EventsNotifier(storage.getAllEvents(), storage);
});

class EventsNotifier extends StateNotifier<List<Event>> {
  final dynamic _storage;

  EventsNotifier(super.events, this._storage);

  Future<void> addEvent(Event event) async {
    await _storage.saveEvent(event);
    state = [...state, event];
  }

  Future<void> updateEvent(Event event) async {
    await _storage.saveEvent(event);
    state = [
      for (final e in state)
        if (e.id == event.id) event else e,
    ];
  }

  Future<void> deleteEvent(String id) async {
    await _storage.deleteEvent(id);
    state = state.where((e) => e.id != id).toList();
  }
}

// Todos with due dates for calendar
final todosWithDueDateProvider = Provider<List<TodoItem>>((ref) {
  final projects = ref.watch(projectsProvider);
  final allTodos = <TodoItem>[];
  for (final project in projects) {
    final todos = ref.watch(todosProvider(project.id));
    allTodos.addAll(todos.where((t) => t.dueDate != null));
  }
  return allTodos;
});

// Starred repos (local, stored as Set<String> of fullName)
final starredReposProvider =
    StateNotifierProvider<StarredReposNotifier, Set<String>>((ref) {
      final storage = ref.watch(storageServiceProvider);
      return StarredReposNotifier(storage);
    });

class StarredReposNotifier extends StateNotifier<Set<String>> {
  final dynamic _storage;

  StarredReposNotifier(this._storage)
    : super(_storage.getStarredRepos().toSet());

  void toggle(String fullName) {
    if (state.contains(fullName)) {
      state = state.where((r) => r != fullName).toSet();
    } else {
      state = {...state, fullName};
    }
    _storage.saveStarredRepos(state.toList());
  }

  bool isStarred(String fullName) => state.contains(fullName);
}
