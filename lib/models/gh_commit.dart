class GhCommit {
  final String sha;
  final String message;
  final String authorName;
  final String authorAvatar;
  final DateTime date;
  final String htmlUrl;

  GhCommit({
    required this.sha,
    required this.message,
    required this.authorName,
    required this.authorAvatar,
    required this.date,
    required this.htmlUrl,
  });

  String get shortSha => sha.length > 7 ? sha.substring(0, 7) : sha;

  factory GhCommit.fromJson(Map<String, dynamic> json) {
    String authorName = '';
    String authorAvatar = '';
    DateTime date = DateTime.now();

    try {
      final commit = json['commit'];
      if (commit != null && commit is Map) {
        final author = commit['author'];
        if (author != null && author is Map) {
          authorName = author['name'] as String? ?? '';
          date =
              DateTime.tryParse(author['date'] as String? ?? '') ??
              DateTime.now();
        }
      }
      final author = json['author'];
      if (author != null && author is Map) {
        authorName = author['login'] as String? ?? authorName;
        authorAvatar = author['avatar_url'] as String? ?? '';
      }
    } catch (_) {}

    String message = '';
    try {
      final commit = json['commit'];
      if (commit != null && commit is Map) {
        message = commit['message'] as String? ?? '';
      }
    } catch (_) {}

    return GhCommit(
      sha: json['sha'] as String? ?? '',
      message: message,
      authorName: authorName,
      authorAvatar: authorAvatar,
      date: date,
      htmlUrl: json['html_url'] as String? ?? '',
    );
  }
}
