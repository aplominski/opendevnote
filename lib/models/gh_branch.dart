class GhBranch {
  final String name;
  final String sha;
  final bool isProtected;

  GhBranch({required this.name, required this.sha, required this.isProtected});

  String get shortSha => sha.length > 7 ? sha.substring(0, 7) : sha;

  factory GhBranch.fromJson(Map<String, dynamic> json) {
    String sha = '';
    try {
      final commit = json['commit'];
      if (commit != null && commit is Map) {
        sha = commit['sha'] as String? ?? '';
      }
    } catch (_) {}

    return GhBranch(
      name: json['name'] as String? ?? '',
      sha: sha,
      isProtected: json['protected'] as bool? ?? false,
    );
  }
}
