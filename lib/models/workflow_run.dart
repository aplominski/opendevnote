class WorkflowRun {
  final int id;
  final String? name;
  final String? headBranch;
  final String? status;
  final String? conclusion;
  final int runNumber;
  final String? displayTitle;
  final String? htmlUrl;
  final String? event;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? actorLogin;
  final String? commitMessage;
  final String repoFullName;

  WorkflowRun({
    required this.id,
    this.name,
    this.headBranch,
    this.status,
    this.conclusion,
    required this.runNumber,
    this.displayTitle,
    this.htmlUrl,
    this.event,
    required this.createdAt,
    required this.updatedAt,
    this.actorLogin,
    this.commitMessage,
    required this.repoFullName,
  });

  factory WorkflowRun.fromJson(Map<String, dynamic> json, String repoFullName) {
    String? commitMsg;
    try {
      final headCommit = json['head_commit'];
      if (headCommit != null && headCommit is Map) {
        commitMsg = headCommit['message'] as String?;
      }
    } catch (_) {}

    String? actor;
    try {
      final actorJson = json['actor'];
      if (actorJson != null && actorJson is Map) {
        actor = actorJson['login'] as String?;
      }
    } catch (_) {}

    return WorkflowRun(
      id: json['id'] as int,
      name: json['name'] as String?,
      headBranch: json['head_branch'] as String?,
      status: json['status'] as String?,
      conclusion: json['conclusion'] as String?,
      runNumber: json['run_number'] as int? ?? 0,
      displayTitle: json['display_title'] as String?,
      htmlUrl: json['html_url'] as String?,
      event: json['event'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      actorLogin: actor,
      commitMessage: commitMsg,
      repoFullName: repoFullName,
    );
  }

  bool get isInProgress => status == 'in_progress' || status == 'queued';
  bool get isSuccess => conclusion == 'success';
  bool get isFailure =>
      conclusion == 'failure' ||
      conclusion == 'timed_out' ||
      conclusion == 'cancelled';
}
