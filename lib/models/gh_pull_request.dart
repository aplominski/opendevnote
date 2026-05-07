class GhPullRequestLabel {
  final int id;
  final String name;
  final String color;
  final String? description;

  const GhPullRequestLabel({
    required this.id,
    required this.name,
    required this.color,
    this.description,
  });

  factory GhPullRequestLabel.fromJson(Map<String, dynamic> json) {
    return GhPullRequestLabel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '000000',
      description: json['description'] as String?,
    );
  }
}

class GhPullRequestAssignee {
  final String login;
  final String avatarUrl;

  const GhPullRequestAssignee({required this.login, required this.avatarUrl});

  factory GhPullRequestAssignee.fromJson(Map<String, dynamic> json) {
    return GhPullRequestAssignee(
      login: json['login'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
  }
}

class GhPullRequestMilestone {
  final int number;
  final String title;
  final String state;

  const GhPullRequestMilestone({
    required this.number,
    required this.title,
    required this.state,
  });

  factory GhPullRequestMilestone.fromJson(Map<String, dynamic> json) {
    return GhPullRequestMilestone(
      number: json['number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      state: json['state'] as String? ?? 'open',
    );
  }
}

class GhPullRequest {
  final int number;
  final String title;
  final String? body;
  final String state;
  final String userLogin;
  final String userAvatar;
  final List<GhPullRequestLabel> labels;
  final List<GhPullRequestAssignee> assignees;
  final GhPullRequestMilestone? milestone;
  final int comments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String htmlUrl;
  final String headRef;
  final String baseRef;
  final bool isDraft;
  final bool isMerged;
  final String? mergedAt;
  final DateTime? closedAt;

  const GhPullRequest({
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
    this.headRef = '',
    this.baseRef = '',
    this.isDraft = false,
    this.isMerged = false,
    this.mergedAt,
    this.closedAt,
  });

  String get stateDisplay {
    if (isMerged) return 'merged';
    return state;
  }

  factory GhPullRequest.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;

    List<GhPullRequestLabel> labels = [];
    if (json['labels'] != null) {
      labels = (json['labels'] as List)
          .map((l) => GhPullRequestLabel.fromJson(l as Map<String, dynamic>))
          .toList();
    }

    List<GhPullRequestAssignee> assignees = [];
    if (json['assignees'] != null) {
      assignees = (json['assignees'] as List)
          .map((a) => GhPullRequestAssignee.fromJson(a as Map<String, dynamic>))
          .toList();
    }

    GhPullRequestMilestone? milestone;
    if (json['milestone'] != null && json['milestone'] is Map) {
      milestone = GhPullRequestMilestone.fromJson(
        json['milestone'] as Map<String, dynamic>,
      );
    }

    String headRef = '';
    String baseRef = '';
    if (json['head'] != null && json['head'] is Map) {
      headRef = (json['head'] as Map<String, dynamic>)['ref'] as String? ?? '';
    }
    if (json['base'] != null && json['base'] is Map) {
      baseRef = (json['base'] as Map<String, dynamic>)['ref'] as String? ?? '';
    }

    return GhPullRequest(
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
      headRef: headRef,
      baseRef: baseRef,
      isDraft: json['draft'] as bool? ?? false,
      isMerged: json['merged'] as bool? ?? false,
      mergedAt: json['merged_at'] as String?,
      closedAt: json['closed_at'] != null
          ? DateTime.tryParse(json['closed_at'] as String)
          : null,
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
      'head': {'ref': headRef},
      'base': {'ref': baseRef},
      'draft': isDraft,
      'merged': isMerged,
      'merged_at': mergedAt,
      'closed_at': closedAt?.toIso8601String(),
    };
  }
}
