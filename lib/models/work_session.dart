import 'package:hive/hive.dart';

part 'work_session.g.dart';

@HiveType(typeId: 10)
class WorkSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final String projectId;

  @HiveField(3)
  final DateTime startedAt;

  @HiveField(4)
  DateTime? endedAt;

  WorkSession({
    required this.id,
    required this.taskId,
    required this.projectId,
    required this.startedAt,
    this.endedAt,
  });

  bool get isActive => endedAt == null;

  Duration get duration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  String get dateKey {
    final d = startedAt;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  DateTime get dateOnly {
    final d = startedAt;
    return DateTime(d.year, d.month, d.day);
  }
}
