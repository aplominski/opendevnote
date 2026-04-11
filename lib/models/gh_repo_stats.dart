class ContributorStat {
  final String login;
  final String avatarUrl;
  final int totalCommits;

  ContributorStat({
    required this.login,
    required this.avatarUrl,
    required this.totalCommits,
  });

  factory ContributorStat.fromJson(Map<String, dynamic> json) {
    String login = '';
    String avatarUrl = '';
    try {
      final author = json['author'];
      if (author != null && author is Map) {
        login = author['login'] as String? ?? '';
        avatarUrl = author['avatar_url'] as String? ?? '';
      }
    } catch (_) {}

    return ContributorStat(
      login: login,
      avatarUrl: avatarUrl,
      totalCommits: json['total'] as int? ?? 0,
    );
  }
}

class CommitActivityWeek {
  final int weekTimestamp;
  final int total;
  final List<int> days;

  CommitActivityWeek({
    required this.weekTimestamp,
    required this.total,
    required this.days,
  });

  DateTime get weekDate =>
      DateTime.fromMillisecondsSinceEpoch(weekTimestamp * 1000);

  factory CommitActivityWeek.fromJson(Map<String, dynamic> json) {
    final daysRaw = json['days'] as List<dynamic>? ?? [0, 0, 0, 0, 0, 0, 0];
    return CommitActivityWeek(
      weekTimestamp: json['week'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      days: daysRaw.map((d) => d as int).toList(),
    );
  }
}

class CodeFrequencyWeek {
  final int weekTimestamp;
  final int additions;
  final int deletions;

  CodeFrequencyWeek({
    required this.weekTimestamp,
    required this.additions,
    required this.deletions,
  });

  DateTime get weekDate =>
      DateTime.fromMillisecondsSinceEpoch(weekTimestamp * 1000);

  factory CodeFrequencyWeek.fromList(List<dynamic> data) {
    if (data.length >= 3) {
      return CodeFrequencyWeek(
        weekTimestamp: data[0] as int,
        additions: data[1] as int,
        deletions: data[2] as int,
      );
    }
    return CodeFrequencyWeek(weekTimestamp: 0, additions: 0, deletions: 0);
  }
}

class PunchCardEntry {
  final int day;
  final int hour;
  final int commits;

  PunchCardEntry({
    required this.day,
    required this.hour,
    required this.commits,
  });

  static const dayNames = ['Ndz', 'Pon', 'Wt', 'Śr', 'Czw', 'Pt', 'Sob'];

  String get dayName => dayNames[day % 7];

  factory PunchCardEntry.fromList(List<dynamic> data) {
    if (data.length >= 3) {
      return PunchCardEntry(
        day: data[0] as int,
        hour: data[1] as int,
        commits: data[2] as int,
      );
    }
    return PunchCardEntry(day: 0, hour: 0, commits: 0);
  }
}

class ParticipationData {
  final List<int> all;
  final List<int> owner;

  ParticipationData({required this.all, required this.owner});

  factory ParticipationData.fromJson(Map<String, dynamic> json) {
    final allRaw = json['all'] as List<dynamic>? ?? [];
    final ownerRaw = json['owner'] as List<dynamic>? ?? [];
    return ParticipationData(
      all: allRaw.map((e) => e as int).toList(),
      owner: ownerRaw.map((e) => e as int).toList(),
    );
  }
}

class GhRepoStats {
  final List<ContributorStat>? contributors;
  final List<CommitActivityWeek>? commitActivity;
  final List<CodeFrequencyWeek>? codeFrequency;
  final List<PunchCardEntry>? punchCard;
  final ParticipationData? participation;
  final bool isLoading;
  final String? error;

  const GhRepoStats({
    this.contributors,
    this.commitActivity,
    this.codeFrequency,
    this.punchCard,
    this.participation,
    this.isLoading = false,
    this.error,
  });

  GhRepoStats copyWith({
    List<ContributorStat>? contributors,
    List<CommitActivityWeek>? commitActivity,
    List<CodeFrequencyWeek>? codeFrequency,
    List<PunchCardEntry>? punchCard,
    ParticipationData? participation,
    bool? isLoading,
    String? error,
  }) {
    return GhRepoStats(
      contributors: contributors ?? this.contributors,
      commitActivity: commitActivity ?? this.commitActivity,
      codeFrequency: codeFrequency ?? this.codeFrequency,
      punchCard: punchCard ?? this.punchCard,
      participation: participation ?? this.participation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
