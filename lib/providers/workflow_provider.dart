import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/github_account.dart';
import 'package:opendevnote/models/workflow_job.dart';
import 'package:opendevnote/models/workflow_run.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/services/github_service.dart';
import 'package:uuid/uuid.dart';

const _workflowCacheKey = 'workflow_runs_v1';

// GitHub service provider
final githubServiceProvider = Provider<GithubService>((ref) {
  return GithubService();
});

// Selected workflow repo key (owner/repo) or null = list
final selectedWorkflowRepoProvider = StateProvider<String?>((ref) => null);

// GitHub accounts provider
final githubAccountsProvider =
    StateNotifierProvider<GithubAccountsNotifier, List<GithubAccount>>((ref) {
      final storage = ref.watch(storageServiceProvider);
      return GithubAccountsNotifier(storage);
    });

class GithubAccountsNotifier extends StateNotifier<List<GithubAccount>> {
  final dynamic _storage;

  GithubAccountsNotifier(this._storage) : super([]) {
    state = _storage.getGithubAccounts();
  }

  GithubAccount? getById(String id) {
    try {
      return state.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addAccount({required String name, required String token}) async {
    final account = GithubAccount(
      id: const Uuid().v4(),
      name: name.trim(),
      token: token.trim(),
    );
    await _storage.saveGithubAccount(account);
    state = [...state, account];
  }

  Future<void> deleteAccount(String id) async {
    await _storage.deleteGithubAccount(id);
    state = state.where((a) => a.id != id).toList();
  }
}

// Auto-discovered workflow runs state
class AutoWorkflowState {
  final Map<String, List<WorkflowRun>> runsByRepo;
  final bool isLoading;
  final String? error;

  const AutoWorkflowState({
    this.runsByRepo = const {},
    this.isLoading = false,
    this.error,
  });

  AutoWorkflowState copyWith({
    Map<String, List<WorkflowRun>>? runsByRepo,
    bool? isLoading,
    String? error,
  }) {
    return AutoWorkflowState(
      runsByRepo: runsByRepo ?? this.runsByRepo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auto-discovery workflow provider
final autoWorkflowProvider =
    StateNotifierProvider<AutoWorkflowNotifier, AutoWorkflowState>((ref) {
      final service = ref.watch(githubServiceProvider);
      final accounts = ref.watch(githubAccountsProvider);
      return AutoWorkflowNotifier(service, accounts, ref);
    });

class AutoWorkflowNotifier extends StateNotifier<AutoWorkflowState> {
  final GithubService _service;
  final List<GithubAccount> _accounts;
  final Ref _ref;
  Timer? _refreshTimer;

  AutoWorkflowNotifier(this._service, this._accounts, this._ref)
    : super(const AutoWorkflowState()) {
    if (_accounts.isNotEmpty) _loadFromCacheAndSync();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => discoverAll(),
    );
  }

  Future<void> _loadFromCacheAndSync() async {
    final storage = _ref.read(storageServiceProvider);
    final cachedData = storage.loadGithubCacheData(_workflowCacheKey);

    if (cachedData != null) {
      try {
        final runsByRepo = <String, List<WorkflowRun>>{};
        final entries = cachedData['runsByRepo'] as Map<String, dynamic>;
        for (final entry in entries.entries) {
          runsByRepo[entry.key] = (entry.value as List)
              .map(
                (e) =>
                    WorkflowRun.fromJson(e as Map<String, dynamic>, entry.key),
              )
              .toList();
        }
        state = AutoWorkflowState(runsByRepo: runsByRepo, isLoading: true);
      } catch (_) {}
    }

    await discoverAll();
  }

  Future<void> discoverAll() async {
    if (_accounts.isEmpty) return;
    state = state.copyWith(isLoading: true, error: null);

    final allRuns = <String, List<WorkflowRun>>{};
    String? lastError;

    for (final account in _accounts) {
      try {
        final repos = await _service.getUserRepos(account.token);

        final futures = repos.map((repo) async {
          try {
            final runs = await _service.getWorkflowRuns(
              owner: repo.ownerLogin,
              repo: repo.name,
              token: account.token,
              repoFullName: repo.fullName,
            );
            if (runs.isNotEmpty) {
              return MapEntry(repo.fullName, runs);
            }
          } catch (_) {}
          return null;
        });

        final results = await Future.wait(futures);
        for (final entry in results) {
          if (entry != null) {
            allRuns[entry.key] = entry.value;
          }
        }
      } catch (e) {
        lastError = '${account.name}: $e';
      }
    }

    final storage = _ref.read(storageServiceProvider);
    final cacheData = <String, dynamic>{};
    allRuns.forEach((repo, runs) {
      cacheData[repo] = runs
          .map(
            (r) => {
              'id': r.id,
              'name': r.name,
              'head_branch': r.headBranch,
              'status': r.status,
              'conclusion': r.conclusion,
              'run_number': r.runNumber,
              'display_title': r.displayTitle,
              'html_url': r.htmlUrl,
              'event': r.event,
              'created_at': r.createdAt.toIso8601String(),
              'updated_at': r.updatedAt.toIso8601String(),
              'actor': {'login': r.actorLogin},
              'head_commit': {'message': r.commitMessage},
            },
          )
          .toList();
    });
    storage.saveGithubCache(_workflowCacheKey, {'runsByRepo': cacheData});

    state = AutoWorkflowState(
      runsByRepo: allRuns,
      isLoading: false,
      error: lastError,
    );
  }

  Future<List<WorkflowJob>> fetchJobs(
    String owner,
    String repo,
    int runId,
  ) async {
    final account = _accounts.isNotEmpty ? _accounts.first : null;
    if (account == null) throw Exception('Brak konta GitHub');

    return _service.getWorkflowJobs(
      owner: owner,
      repo: repo,
      token: account.token,
      runId: runId,
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
