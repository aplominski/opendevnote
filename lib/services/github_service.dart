import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:opendevnote/models/gh_branch.dart';
import 'package:opendevnote/models/gh_commit.dart';
import 'package:opendevnote/models/gh_commit_detail.dart';
import 'package:opendevnote/models/gh_repo.dart';
import 'package:opendevnote/models/gh_repo_stats.dart';
import 'package:opendevnote/models/workflow_job.dart';
import 'package:opendevnote/models/workflow_run.dart';

class GithubService {
  static const _baseUrl = 'https://api.github.com';
  static const _apiVersion = '2026-03-10';

  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/vnd.github+json',
    'X-GitHub-Api-Version': _apiVersion,
  };

  Future<List<WorkflowRun>> getWorkflowRuns({
    required String owner,
    required String repo,
    required String token,
    required String repoFullName,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/actions/runs',
    ).replace(queryParameters: {'per_page': '20'});

    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final runs = data['workflow_runs'] as List<dynamic>? ?? [];
      return runs
          .map(
            (r) =>
                WorkflowRun.fromJson(r as Map<String, dynamic>, repoFullName),
          )
          .toList();
    } else if (response.statusCode == 401) {
      throw GithubApiException('Nieprawidłowy token GitHub', 401);
    } else if (response.statusCode == 403) {
      throw GithubApiException('Brak uprawnień do repozytorium', 403);
    } else if (response.statusCode == 404) {
      throw GithubApiException('Repozytorium nie znalezione', 404);
    } else {
      throw GithubApiException(
        'Błąd API GitHub: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  Future<List<WorkflowJob>> getWorkflowJobs({
    required String owner,
    required String repo,
    required String token,
    required int runId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/actions/runs/$runId/jobs',
    ).replace(queryParameters: {'steps': 'true', 'per_page': '100'});

    final response = await http.get(uri, headers: _headers(token));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final jobs = data['jobs'] as List<dynamic>? ?? [];
      return jobs
          .map((j) => WorkflowJob.fromJson(j as Map<String, dynamic>))
          .toList();
    } else {
      throw GithubApiException(
        'Błąd ładowania jobów: ${response.statusCode}',
        response.statusCode,
      );
    }
  }

  // ── Repositories ──

  Future<List<GhRepo>> getUserRepos(String token) async {
    final uri = Uri.parse(
      '$_baseUrl/user/repos',
    ).replace(queryParameters: {'sort': 'pushed', 'per_page': '100'});

    final response = await http.get(uri, headers: _headers(token));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((r) => GhRepo.fromJson(r as Map<String, dynamic>))
          .toList();
    }
    throw GithubApiException(
      'Błąd ładowania repo: ${response.statusCode}',
      response.statusCode,
    );
  }

  // ── Commits ──

  Future<List<GhCommit>> getCommits(
    String token,
    String owner,
    String repo,
    int page,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/commits',
    ).replace(queryParameters: {'per_page': '30', 'page': '$page'});

    final response = await http.get(uri, headers: _headers(token));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((c) => GhCommit.fromJson(c as Map<String, dynamic>))
          .toList();
    }
    throw GithubApiException(
      'Błąd ładowania commitów: ${response.statusCode}',
      response.statusCode,
    );
  }

  Future<GhCommitDetail> getCommitDetail(
    String token,
    String owner,
    String repo,
    String sha,
  ) async {
    final uri = Uri.parse('$_baseUrl/repos/$owner/$repo/commits/$sha');
    final response = await http.get(uri, headers: _headers(token));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return GhCommitDetail.fromJson(data);
    }
    throw GithubApiException(
      'Błąd ładowania commita: ${response.statusCode}',
      response.statusCode,
    );
  }

  // ── Branches ──

  Future<List<GhBranch>> getBranches(
    String token,
    String owner,
    String repo,
  ) async {
    final uri = Uri.parse(
      '$_baseUrl/repos/$owner/$repo/branches',
    ).replace(queryParameters: {'per_page': '100'});

    final response = await http.get(uri, headers: _headers(token));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((b) => GhBranch.fromJson(b as Map<String, dynamic>))
          .toList();
    }
    throw GithubApiException(
      'Błąd ładowania gałęzi: ${response.statusCode}',
      response.statusCode,
    );
  }

  // ── Stats (with retry on 202) ──

  Future<dynamic> _getStats(
    String token,
    String owner,
    String repo,
    String stat,
  ) async {
    final uri = Uri.parse('$_baseUrl/repos/$owner/$repo/stats/$stat');

    for (var attempt = 0; attempt < 3; attempt++) {
      final response = await http.get(uri, headers: _headers(token));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      if (response.statusCode == 202) {
        await Future.delayed(const Duration(seconds: 2));
        continue;
      }
      if (response.statusCode == 204) return null;
      throw GithubApiException(
        'Błąd ładowania statystyk: ${response.statusCode}',
        response.statusCode,
      );
    }
    return null;
  }

  Future<List<ContributorStat>> getContributors(
    String token,
    String owner,
    String repo,
  ) async {
    final data = await _getStats(token, owner, repo, 'contributors');
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((c) => ContributorStat.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<List<CommitActivityWeek>> getCommitActivity(
    String token,
    String owner,
    String repo,
  ) async {
    final data = await _getStats(token, owner, repo, 'commit_activity');
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((w) => CommitActivityWeek.fromJson(w as Map<String, dynamic>))
        .toList();
  }

  Future<List<CodeFrequencyWeek>> getCodeFrequency(
    String token,
    String owner,
    String repo,
  ) async {
    final data = await _getStats(token, owner, repo, 'code_frequency');
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((w) => CodeFrequencyWeek.fromList(w as List<dynamic>))
        .toList();
  }

  Future<List<PunchCardEntry>> getPunchCard(
    String token,
    String owner,
    String repo,
  ) async {
    final data = await _getStats(token, owner, repo, 'punch_card');
    if (data == null) return [];
    return (data as List<dynamic>)
        .map((e) => PunchCardEntry.fromList(e as List<dynamic>))
        .toList();
  }

  Future<ParticipationData?> getParticipation(
    String token,
    String owner,
    String repo,
  ) async {
    final data = await _getStats(token, owner, repo, 'participation');
    if (data == null) return null;
    return ParticipationData.fromJson(data as Map<String, dynamic>);
  }
}

class GithubApiException implements Exception {
  final String message;
  final int statusCode;

  GithubApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
