import 'package:hive/hive.dart';

part 'rss_article.g.dart';

@HiveType(typeId: 12)
class RssArticle extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String feedId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String? description;

  @HiveField(4)
  final String link;

  @HiveField(5)
  final DateTime? publishedAt;

  @HiveField(6)
  bool isRead;

  @HiveField(7)
  final String? author;

  @HiveField(8)
  final DateTime fetchedAt;

  RssArticle({
    required this.id,
    required this.feedId,
    required this.title,
    this.description,
    required this.link,
    this.publishedAt,
    this.isRead = false,
    this.author,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();
}
