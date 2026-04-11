import 'package:hive/hive.dart';

part 'code_snippet.g.dart';

@HiveType(typeId: 4)
class CodeSnippet extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  String title;

  @HiveField(3)
  String code;

  @HiveField(4)
  String language;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  int sortOrder;

  @HiveField(8)
  String? linkedTaskId;

  @HiveField(9)
  String? description;

  CodeSnippet({
    required this.id,
    required this.projectId,
    required this.title,
    this.code = '',
    required this.language,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.sortOrder = 0,
    this.linkedTaskId,
    this.description,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  CodeSnippet copyWith({
    String? title,
    String? code,
    String? language,
    int? sortOrder,
    String? linkedTaskId,
    String? description,
    bool clearLinkedTask = false,
    bool clearDescription = false,
  }) {
    return CodeSnippet(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      code: code ?? this.code,
      language: language ?? this.language,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      sortOrder: sortOrder ?? this.sortOrder,
      linkedTaskId: clearLinkedTask ? null : (linkedTaskId ?? this.linkedTaskId),
      description: clearDescription ? null : (description ?? this.description),
    );
  }
}
