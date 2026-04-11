import 'package:hive/hive.dart';

part 'github_repo_config.g.dart';

@HiveType(typeId: 5)
class GithubRepoConfig extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String owner;

  @HiveField(2)
  String repo;

  @HiveField(3)
  String accountId;

  @HiveField(4)
  int refreshIntervalSeconds;

  GithubRepoConfig({
    required this.id,
    required this.owner,
    required this.repo,
    required this.accountId,
    this.refreshIntervalSeconds = 0,
  });

  String get displayName => '$owner/$repo';

  GithubRepoConfig copyWith({
    String? owner,
    String? repo,
    String? accountId,
    int? refreshIntervalSeconds,
  }) {
    return GithubRepoConfig(
      id: id,
      owner: owner ?? this.owner,
      repo: repo ?? this.repo,
      accountId: accountId ?? this.accountId,
      refreshIntervalSeconds:
          refreshIntervalSeconds ?? this.refreshIntervalSeconds,
    );
  }
}
