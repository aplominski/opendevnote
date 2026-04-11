import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 2)
class Note extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String content;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  @HiveField(6)
  int sortOrder;

  @HiveField(7)
  String? linkedTaskId;

  Note({
    required this.id,
    required this.projectId,
    required this.title,
    this.content = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sortOrder = 0,
    this.linkedTaskId,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Note copyWith({
    String? title,
    String? content,
    int? sortOrder,
    String? linkedTaskId,
    bool clearLinkedTask = false,
  }) {
    return Note(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      sortOrder: sortOrder ?? this.sortOrder,
      linkedTaskId: clearLinkedTask
          ? null
          : (linkedTaskId ?? this.linkedTaskId),
    );
  }
}
