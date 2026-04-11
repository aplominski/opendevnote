import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:opendevnote/models/work_session.dart';
import 'package:opendevnote/providers/providers.dart';

const _uuid = Uuid();

final workSessionsProvider =
    StateNotifierProvider<WorkSessionsNotifier, List<WorkSession>>((ref) {
      final storage = ref.watch(storageServiceProvider);
      final sessions = storage.getAllWorkSessions();

      final active = sessions.where((s) => s.isActive).toList();
      if (active.isNotEmpty) {
        final now = DateTime.now();
        for (final s in active) {
          s.endedAt = now;
          storage.saveWorkSession(s);
        }
      }

      return WorkSessionsNotifier(storage.getAllWorkSessions(), storage);
    });

class WorkSessionsNotifier extends StateNotifier<List<WorkSession>> {
  final dynamic _storage;

  WorkSessionsNotifier(super.sessions, this._storage);

  Future<void> startSession({
    required String taskId,
    required String projectId,
  }) async {
    final session = WorkSession(
      id: _uuid.v4(),
      taskId: taskId,
      projectId: projectId,
      startedAt: DateTime.now(),
    );
    await _storage.saveWorkSession(session);
    state = [session, ...state];
  }

  Future<void> stopSession(String sessionId) async {
    final session = state.firstWhere((s) => s.id == sessionId);
    session.endedAt = DateTime.now();
    await _storage.saveWorkSession(session);
    state = [...state];
  }

  List<WorkSession> get activeSessions =>
      state.where((s) => s.isActive).toList();

  WorkSession? getActiveSessionForTask(String taskId) {
    try {
      return state.firstWhere((s) => s.isActive && s.taskId == taskId);
    } catch (_) {
      return null;
    }
  }

  Duration getTotalForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final daySessions = state.where((s) {
      final sDate = DateTime(
        s.startedAt.year,
        s.startedAt.month,
        s.startedAt.day,
      );
      return sDate == dateOnly;
    });
    Duration total = Duration.zero;
    for (final s in daySessions) {
      total += s.duration;
    }
    return total;
  }

  List<WorkSession> getSessionsForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return state.where((s) {
      final sDate = DateTime(
        s.startedAt.year,
        s.startedAt.month,
        s.startedAt.day,
      );
      return sDate == dateOnly;
    }).toList();
  }

  Map<DateTime, Duration> getDailyStats(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <DateTime, Duration>{};

    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      result[date] = getTotalForDate(date);
    }

    return result;
  }
}

final activeSessionProvider = Provider<WorkSession?>((ref) {
  final sessions = ref.watch(workSessionsProvider);
  try {
    return sessions.firstWhere((s) => s.isActive);
  } catch (_) {
    return null;
  }
});

final todayTotalProvider = Provider<Duration>((ref) {
  final sessions = ref.watch(workSessionsProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  Duration total = Duration.zero;
  for (final s in sessions) {
    final sDate = DateTime(
      s.startedAt.year,
      s.startedAt.month,
      s.startedAt.day,
    );
    if (sDate == today) {
      total += s.duration;
    }
  }
  return total;
});

final yesterdayTotalProvider = Provider<Duration>((ref) {
  final sessions = ref.watch(workSessionsProvider);
  final now = DateTime.now();
  final yesterday = DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(const Duration(days: 1));
  Duration total = Duration.zero;
  for (final s in sessions) {
    final sDate = DateTime(
      s.startedAt.year,
      s.startedAt.month,
      s.startedAt.day,
    );
    if (sDate == yesterday) {
      total += s.duration;
    }
  }
  return total;
});

final elapsedSecondsProvider = StreamProvider<int>((ref) {
  final active = ref.watch(activeSessionProvider);
  if (active == null) return Stream.value(0);
  return Stream.periodic(const Duration(seconds: 1), (_) {
    return DateTime.now().difference(active.startedAt).inSeconds;
  });
});

final weeklyStatsProvider = Provider<Map<DateTime, Duration>>((ref) {
  final sessions = ref.watch(workSessionsProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final result = <DateTime, Duration>{};

  for (int i = 6; i >= 0; i--) {
    final date = today.subtract(Duration(days: i));
    Duration total = Duration.zero;
    for (final s in sessions) {
      final sDate = DateTime(
        s.startedAt.year,
        s.startedAt.month,
        s.startedAt.day,
      );
      if (sDate == date) {
        total += s.duration;
      }
    }
    result[date] = total;
  }
  return result;
});
