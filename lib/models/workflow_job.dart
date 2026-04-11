class WorkflowStep {
  final String name;
  final String status;
  final String? conclusion;
  final int number;
  final DateTime? startedAt;
  final DateTime? completedAt;

  WorkflowStep({
    required this.name,
    required this.status,
    this.conclusion,
    required this.number,
    this.startedAt,
    this.completedAt,
  });

  factory WorkflowStep.fromJson(Map<String, dynamic> json) {
    return WorkflowStep(
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      conclusion: json['conclusion'] as String?,
      number: json['number'] as int? ?? 0,
      startedAt: DateTime.tryParse(json['started_at'] as String? ?? ''),
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
    );
  }

  bool get isSuccess => conclusion == 'success';
  bool get isFailure =>
      conclusion == 'failure' ||
      conclusion == 'timed_out' ||
      conclusion == 'cancelled';
  bool get isInProgress => status == 'in_progress';
}

class WorkflowJob {
  final int id;
  final String name;
  final String status;
  final String? conclusion;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? runnerName;
  final String? headBranch;
  final List<WorkflowStep> steps;

  WorkflowJob({
    required this.id,
    required this.name,
    required this.status,
    this.conclusion,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.runnerName,
    this.headBranch,
    required this.steps,
  });

  factory WorkflowJob.fromJson(Map<String, dynamic> json) {
    final stepsJson = json['steps'] as List<dynamic>? ?? [];
    return WorkflowJob(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      conclusion: json['conclusion'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      startedAt: DateTime.tryParse(json['started_at'] as String? ?? ''),
      completedAt: DateTime.tryParse(json['completed_at'] as String? ?? ''),
      runnerName: json['runner_name'] as String?,
      headBranch: json['head_branch'] as String?,
      steps: stepsJson
          .map((s) => WorkflowStep.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get isSuccess => conclusion == 'success';
  bool get isFailure =>
      conclusion == 'failure' ||
      conclusion == 'timed_out' ||
      conclusion == 'cancelled';
  bool get isInProgress => status == 'in_progress' || status == 'queued';

  Duration? get duration {
    if (startedAt != null && completedAt != null) {
      return completedAt!.difference(startedAt!);
    }
    return null;
  }
}
