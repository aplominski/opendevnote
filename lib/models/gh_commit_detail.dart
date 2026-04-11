class GhFileChange {
  final String filename;
  final String status;
  final int additions;
  final int deletions;
  final int changes;
  final String? patch;

  GhFileChange({
    required this.filename,
    required this.status,
    required this.additions,
    required this.deletions,
    required this.changes,
    this.patch,
  });

  factory GhFileChange.fromJson(Map<String, dynamic> json) {
    return GhFileChange(
      filename: json['filename'] as String? ?? '',
      status: json['status'] as String? ?? '',
      additions: json['additions'] as int? ?? 0,
      deletions: json['deletions'] as int? ?? 0,
      changes: json['changes'] as int? ?? 0,
      patch: json['patch'] as String?,
    );
  }
}

class GhCommitDetail {
  final String sha;
  final String message;
  final String authorName;
  final String authorAvatar;
  final DateTime date;
  final String htmlUrl;
  final int additions;
  final int deletions;
  final int totalFiles;
  final List<GhFileChange> files;

  GhCommitDetail({
    required this.sha,
    required this.message,
    required this.authorName,
    required this.authorAvatar,
    required this.date,
    required this.htmlUrl,
    required this.additions,
    required this.deletions,
    required this.totalFiles,
    required this.files,
  });

  String get shortSha => sha.length > 7 ? sha.substring(0, 7) : sha;

  factory GhCommitDetail.fromJson(Map<String, dynamic> json) {
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

    int additions = 0;
    int deletions = 0;
    try {
      final stats = json['stats'];
      if (stats != null && stats is Map) {
        additions = stats['additions'] as int? ?? 0;
        deletions = stats['deletions'] as int? ?? 0;
      }
    } catch (_) {}

    final filesJson = json['files'] as List<dynamic>? ?? [];
    final files = filesJson
        .map((f) => GhFileChange.fromJson(f as Map<String, dynamic>))
        .toList();

    return GhCommitDetail(
      sha: json['sha'] as String? ?? '',
      message: message,
      authorName: authorName,
      authorAvatar: authorAvatar,
      date: date,
      htmlUrl: json['html_url'] as String? ?? '',
      additions: additions,
      deletions: deletions,
      totalFiles: files.length,
      files: files,
    );
  }
}
