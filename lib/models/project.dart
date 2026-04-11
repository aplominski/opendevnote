import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorIndex;

  @HiveField(3)
  int iconIndex;

  @HiveField(4)
  List<String> tags;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  int sortOrder;

  Project({
    required this.id,
    required this.name,
    this.colorIndex = 0,
    this.iconIndex = 0,
    List<String>? tags,
    DateTime? createdAt,
    this.sortOrder = 0,
  }) : tags = tags ?? [],
       createdAt = createdAt ?? DateTime.now();

  Project copyWith({
    String? name,
    int? colorIndex,
    int? iconIndex,
    List<String>? tags,
    int? sortOrder,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
      iconIndex: iconIndex ?? this.iconIndex,
      tags: tags ?? List.from(this.tags),
      createdAt: createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
