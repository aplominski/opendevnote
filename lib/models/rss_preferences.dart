import 'package:hive/hive.dart';

part 'rss_preferences.g.dart';

@HiveType(typeId: 13)
class RssPreferences extends HiveObject {
  @HiveField(0)
  bool autoRefreshEnabled;

  @HiveField(1)
  int autoRefreshMinutes;

  @HiveField(2)
  bool autoCleanupEnabled;

  @HiveField(3)
  int cleanupDays;

  @HiveField(4)
  bool splitViewMode;

  RssPreferences({
    this.autoRefreshEnabled = false,
    this.autoRefreshMinutes = 30,
    this.autoCleanupEnabled = false,
    this.cleanupDays = 30,
    this.splitViewMode = true,
  });
}
