import 'package:hive/hive.dart';

part 'rss_feed.g.dart';

@HiveType(typeId: 11)
class RssFeed extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String url;

  @HiveField(2)
  String title;

  @HiveField(3)
  String? description;

  @HiveField(4)
  String? category;

  @HiveField(5)
  final DateTime addedAt;

  @HiveField(6)
  DateTime? lastFetchedAt;

  @HiveField(7)
  int colorIndex;

  RssFeed({
    required this.id,
    required this.url,
    required this.title,
    this.description,
    this.category,
    DateTime? addedAt,
    this.lastFetchedAt,
    this.colorIndex = 0,
  }) : addedAt = addedAt ?? DateTime.now();
}
