import 'package:hive/hive.dart';

part 'cached_github_data.g.dart';

@HiveType(typeId: 14)
class CachedGithubData extends HiveObject {
  @HiveField(0)
  final String key;

  @HiveField(1)
  final String data;

  @HiveField(2)
  final DateTime cachedAt;

  @HiveField(3)
  final int version;

  CachedGithubData({
    required this.key,
    required this.data,
    required this.cachedAt,
    this.version = 1,
  });

  bool get isExpired {
    final age = DateTime.now().difference(cachedAt);
    return age.inHours > 24;
  }

  bool get isStale {
    final age = DateTime.now().difference(cachedAt);
    return age.inMinutes > 5;
  }
}
