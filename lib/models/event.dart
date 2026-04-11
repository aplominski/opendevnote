import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 3)
class Event extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? projectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime startDate;

  @HiveField(5)
  DateTime? endDate;

  @HiveField(6)
  int colorIndex;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  int sortOrder;

  Event({
    required this.id,
    this.projectId,
    required this.title,
    this.description = '',
    required this.startDate,
    this.endDate,
    this.colorIndex = 0,
    DateTime? createdAt,
    this.sortOrder = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  Event copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    int? colorIndex,
    int? sortOrder,
    bool clearEndDate = false,
    bool clearProjectId = false,
  }) {
    return Event(
      id: id,
      projectId: clearProjectId ? null : (projectId ?? this.projectId),
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
