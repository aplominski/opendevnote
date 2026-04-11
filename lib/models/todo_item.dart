import 'package:hive/hive.dart';

part 'todo_item.g.dart';

@HiveType(typeId: 1)
class TodoItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  List<String> tags;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  int sortOrder;

  @HiveField(8)
  DateTime? dueDate;

  TodoItem({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    List<String>? tags,
    DateTime? createdAt,
    this.sortOrder = 0,
    this.dueDate,
  }) : tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now();

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  bool get isInbox => dueDate == null;

  TodoItem copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    List<String>? tags,
    int? sortOrder,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return TodoItem(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      tags: tags ?? List.from(this.tags),
      createdAt: createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    );
  }
}
