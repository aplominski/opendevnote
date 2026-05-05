class GhIssueComment {
  final int id;
  final String body;
  final String userLogin;
  final String userAvatar;
  final DateTime createdAt;
  final GhIssueCommentReactions reactions;
  final String htmlUrl;

  const GhIssueComment({
    required this.id,
    required this.body,
    required this.userLogin,
    required this.userAvatar,
    required this.createdAt,
    this.reactions = const GhIssueCommentReactions(),
    required this.htmlUrl,
  });

  factory GhIssueComment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    GhIssueCommentReactions reactions = const GhIssueCommentReactions();
    if (json['reactions'] != null && json['reactions'] is Map) {
      reactions = GhIssueCommentReactions.fromJson(
        json['reactions'] as Map<String, dynamic>,
      );
    }

    return GhIssueComment(
      id: json['id'] as int? ?? 0,
      body: json['body'] as String? ?? '',
      userLogin: user?['login'] as String? ?? '',
      userAvatar: user?['avatar_url'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime(2000),
      reactions: reactions,
      htmlUrl: json['html_url'] as String? ?? '',
    );
  }
}

class GhIssueCommentReactions {
  final int total;
  final int plusOne;
  final int minusOne;
  final int laugh;
  final int hooray;
  final int confused;
  final int heart;
  final int rocket;
  final int eyes;

  const GhIssueCommentReactions({
    this.total = 0,
    this.plusOne = 0,
    this.minusOne = 0,
    this.laugh = 0,
    this.hooray = 0,
    this.confused = 0,
    this.heart = 0,
    this.rocket = 0,
    this.eyes = 0,
  });

  factory GhIssueCommentReactions.fromJson(Map<String, dynamic> json) {
    return GhIssueCommentReactions(
      total: json['total_count'] as int? ?? 0,
      plusOne: json['+1'] as int? ?? 0,
      minusOne: json['-1'] as int? ?? 0,
      laugh: json['laugh'] as int? ?? 0,
      hooray: json['hooray'] as int? ?? 0,
      confused: json['confused'] as int? ?? 0,
      heart: json['heart'] as int? ?? 0,
      rocket: json['rocket'] as int? ?? 0,
      eyes: json['eyes'] as int? ?? 0,
    );
  }
}
