class GhIssueLabel {
  final int id;
  final String name;
  final String color;
  final String? description;

  const GhIssueLabel({
    required this.id,
    required this.name,
    required this.color,
    this.description,
  });

  factory GhIssueLabel.fromJson(Map<String, dynamic> json) {
    return GhIssueLabel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '000000',
      description: json['description'] as String?,
    );
  }
}

class GhIssueAssignee {
  final String login;
  final String avatarUrl;

  const GhIssueAssignee({required this.login, required this.avatarUrl});

  factory GhIssueAssignee.fromJson(Map<String, dynamic> json) {
    return GhIssueAssignee(
      login: json['login'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
  }
}

class GhIssueMilestone {
  final int number;
  final String title;
  final String state;

  const GhIssueMilestone({
    required this.number,
    required this.title,
    required this.state,
  });

  factory GhIssueMilestone.fromJson(Map<String, dynamic> json) {
    return GhIssueMilestone(
      number: json['number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      state: json['state'] as String? ?? 'open',
    );
  }
}

class GhIssueReactions {
  final int total;
  final int plusOne;
  final int minusOne;
  final int laugh;
  final int hooray;
  final int confused;
  final int heart;
  final int rocket;
  final int eyes;

  const GhIssueReactions({
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

  factory GhIssueReactions.fromJson(Map<String, dynamic> json) {
    return GhIssueReactions(
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

class GhIssue {
  final int number;
  final String title;
  final String? body;
  final String state;
  final String userLogin;
  final String userAvatar;
  final List<GhIssueLabel> labels;
  final List<GhIssueAssignee> assignees;
  final GhIssueMilestone? milestone;
  final int comments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String htmlUrl;
  final GhIssueReactions reactions;
  final String? pullRequestUrl;

  const GhIssue({
    required this.number,
    required this.title,
    this.body,
    required this.state,
    required this.userLogin,
    required this.userAvatar,
    this.labels = const [],
    this.assignees = const [],
    this.milestone,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
    required this.htmlUrl,
    this.reactions = const GhIssueReactions(),
    this.pullRequestUrl,
  });

  bool get isPullRequest => pullRequestUrl != null;

  factory GhIssue.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    List<GhIssueLabel> labels = [];
    if (json['labels'] != null) {
      labels = (json['labels'] as List)
          .map((l) => GhIssueLabel.fromJson(l as Map<String, dynamic>))
          .toList();
    }

    List<GhIssueAssignee> assignees = [];
    if (json['assignees'] != null) {
      assignees = (json['assignees'] as List)
          .map((a) => GhIssueAssignee.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    GhIssueMilestone? milestone;
    if (json['milestone'] != null && json['milestone'] is Map) {
      milestone = GhIssueMilestone.fromJson(
        json['milestone'] as Map<String, dynamic>,
      );
    }

    GhIssueReactions reactions = const GhIssueReactions();
    if (json['reactions'] != null && json['reactions'] is Map) {
      reactions = GhIssueReactions.fromJson(
        json['reactions'] as Map<String, dynamic>,
      );
    }

    String? pullRequestUrl;
    if (json['pull_request'] != null && json['pull_request'] is Map) {
      pullRequestUrl =
          (json['pull_request'] as Map<String, dynamic>)['url'] as String?;
    }

    return GhIssue(
      number: json['number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      state: json['state'] as String? ?? 'open',
      userLogin: user?['login'] as String? ?? '',
      userAvatar: user?['avatar_url'] as String? ?? '',
      labels: labels,
      assignees: assignees,
      milestone: milestone,
      comments: json['comments'] as int? ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime(2000),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime(2000),
      htmlUrl: json['html_url'] as String? ?? '',
      reactions: reactions,
      pullRequestUrl: pullRequestUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'body': body,
      'state': state,
      'user': {'login': userLogin, 'avatar_url': userAvatar},
      'labels': labels
          .map(
            (l) => {
              'id': l.id,
              'name': l.name,
              'color': l.color,
              'description': l.description,
            },
          )
          .toList(),
      'assignees': assignees
          .map((a) => {'login': a.login, 'avatar_url': a.avatarUrl})
          .toList(),
      'milestone': milestone != null
          ? {
              'number': milestone!.number,
              'title': milestone!.title,
              'state': milestone!.state,
            }
          : null,
      'comments': comments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'html_url': htmlUrl,
      'reactions': {
        'total_count': reactions.total,
        '+1': reactions.plusOne,
        '-1': reactions.minusOne,
        'laugh': reactions.laugh,
        'hooray': reactions.hooray,
        'confused': reactions.confused,
        'heart': reactions.heart,
        'rocket': reactions.rocket,
        'eyes': reactions.eyes,
      },
      'pull_request': pullRequestUrl != null ? {'url': pullRequestUrl} : null,
    };
  }
}
