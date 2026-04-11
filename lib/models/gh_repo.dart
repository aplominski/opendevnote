class GhRepo {
  final int id;
  final String name;
  final String fullName;
  final String? description;
  final String? language;
  final int stargazersCount;
  final int forksCount;
  final int openIssuesCount;
  final DateTime? pushedAt;
  final bool isPrivate;
  final bool isFork;
  final String defaultBranch;
  final String ownerLogin;
  final String ownerAvatar;
  final String htmlUrl;

  GhRepo({
    required this.id,
    required this.name,
    required this.fullName,
    this.description,
    this.language,
    required this.stargazersCount,
    required this.forksCount,
    required this.openIssuesCount,
    this.pushedAt,
    required this.isPrivate,
    required this.isFork,
    required this.defaultBranch,
    required this.ownerLogin,
    required this.ownerAvatar,
    required this.htmlUrl,
  });

  factory GhRepo.fromJson(Map<String, dynamic> json) {
    String ownerLogin = '';
    String ownerAvatar = '';
    try {
      final owner = json['owner'];
      if (owner != null && owner is Map) {
        ownerLogin = owner['login'] as String? ?? '';
        ownerAvatar = owner['avatar_url'] as String? ?? '';
      }
    } catch (_) {}

    return GhRepo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      description: json['description'] as String?,
      language: json['language'] as String?,
      stargazersCount: json['stargazers_count'] as int? ?? 0,
      forksCount: json['forks_count'] as int? ?? 0,
      openIssuesCount: json['open_issues_count'] as int? ?? 0,
      pushedAt: DateTime.tryParse(json['pushed_at'] as String? ?? ''),
      isPrivate: json['private'] as bool? ?? false,
      isFork: json['fork'] as bool? ?? false,
      defaultBranch: json['default_branch'] as String? ?? 'main',
      ownerLogin: ownerLogin,
      ownerAvatar: ownerAvatar,
      htmlUrl: json['html_url'] as String? ?? '',
    );
  }
}
