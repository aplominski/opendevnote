import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/gh_branch.dart';
import 'package:opendevnote/models/gh_commit.dart';
import 'package:opendevnote/models/gh_repo.dart';
import 'package:opendevnote/models/gh_repo_stats.dart';
import 'package:opendevnote/models/github_account.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/providers/workflow_provider.dart';
import 'package:opendevnote/services/github_service.dart';

const _reposCacheKey = 'repos_list_v1';

// Selected repo key "owner/repo" (null = repo list)
final selectedRepoProvider = StateProvider<String?>((ref) => null);

// Repos list state
class ReposState {
  final List<GhRepo> repos;
  final bool isLoading;
  final String? error;

  const ReposState({this.repos = const [], this.isLoading = false, this.error});

  ReposState copyWith({List<GhRepo>? repos, bool? isLoading, String? error}) {
    return ReposState(
      repos: repos ?? this.repos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// All repos from all accounts
final reposProvider = StateNotifierProvider<ReposNotifier, ReposState>((ref) {
  final service = ref.watch(githubServiceProvider);
  final accounts = ref.watch(githubAccountsProvider);
  return ReposNotifier(service, accounts, ref);
});

class ReposNotifier extends StateNotifier<ReposState> {
  final GithubService _service;
  final List<GithubAccount> _accounts;
  final Ref _ref;

  ReposNotifier(this._service, this._accounts, this._ref)
    : super(const ReposState()) {
    if (_accounts.isNotEmpty) _loadFromCacheAndSync();
  }

  Future<void> _loadFromCacheAndSync() async {
    final storage = _ref.read(storageServiceProvider);
    final cachedData = storage.loadGithubCacheData(_reposCacheKey);

    if (cachedData != null) {
      try {
        final repos = (cachedData['repos'] as List)
            .map((e) => GhRepo.fromJson(e as Map<String, dynamic>))
            .toList();
        state = ReposState(repos: repos, isLoading: true);
      } catch (_) {}
    }

    await fetchAll();
  }

  Future<void> fetchAll() async {
    state = state.copyWith(isLoading: true, error: null);
    final allRepos = <GhRepo>[];
    String? error;

    for (final account in _accounts) {
      try {
        final repos = await _service.getUserRepos(account.token);
        allRepos.addAll(repos);
      } catch (e) {
        error = '${account.name}: $e';
      }
    }

    final seen = <String>{};
    allRepos.retainWhere((r) => seen.add(r.fullName));

    final storage = _ref.read(storageServiceProvider);
    storage.saveGithubCache(_reposCacheKey, {
      'repos': allRepos
          .map(
            (r) => {
              'id': r.id,
              'name': r.name,
              'full_name': r.fullName,
              'description': r.description,
              'language': r.language,
              'stargazers_count': r.stargazersCount,
              'forks_count': r.forksCount,
              'open_issues_count': r.openIssuesCount,
              'pushed_at': r.pushedAt?.toIso8601String(),
              'private': r.isPrivate,
              'fork': r.isFork,
              'default_branch': r.defaultBranch,
              'owner': {'login': r.ownerLogin, 'avatar_url': r.ownerAvatar},
              'html_url': r.htmlUrl,
            },
          )
          .toList(),
    });

    state = ReposState(repos: allRepos, isLoading: false, error: error);
  }
}

// Commits state for a repo
class CommitsState {
  final List<GhCommit> commits;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final String? error;

  const CommitsState({
    this.commits = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  CommitsState copyWith({
    List<GhCommit>? commits,
    int? page,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return CommitsState(
      commits: commits ?? this.commits,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Commits provider per repo
final repoCommitsProvider =
    StateNotifierProvider.family<CommitsNotifier, CommitsState, String>((
      ref,
      repoKey,
    ) {
      final service = ref.watch(githubServiceProvider);
      final accounts = ref.watch(githubAccountsProvider);
      return CommitsNotifier(service, accounts, repoKey);
    });

class CommitsNotifier extends StateNotifier<CommitsState> {
  final GithubService _service;
  final List<GithubAccount> _accounts;
  final String repoKey;

  CommitsNotifier(this._service, this._accounts, this.repoKey)
    : super(const CommitsState());

  String? _getToken() {
    // Use first available account token
    return _accounts.isNotEmpty ? _accounts.first.token : null;
  }

  List<String> get _ownerRepo => repoKey.split('/');

  Future<void> loadFirst() async {
    if (_ownerRepo.length != 2) return;
    state = const CommitsState(isLoading: true);
    final token = _getToken();
    if (token == null) {
      state = const CommitsState(error: 'Brak konta GitHub');
      return;
    }
    try {
      final commits = await _service.getCommits(
        token,
        _ownerRepo[0],
        _ownerRepo[1],
        1,
      );
      state = CommitsState(
        commits: commits,
        page: 1,
        hasMore: commits.length >= 30,
      );
    } catch (e) {
      state = CommitsState(error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final nextPage = state.page + 1;
      final commits = await _service.getCommits(
        token,
        _ownerRepo[0],
        _ownerRepo[1],
        nextPage,
      );
      state = state.copyWith(
        commits: [...state.commits, ...commits],
        page: nextPage,
        hasMore: commits.length >= 30,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// Branches provider per repo
final repoBranchesProvider =
    StateNotifierProvider.family<BranchesNotifier, BranchesState, String>((
      ref,
      repoKey,
    ) {
      final service = ref.watch(githubServiceProvider);
      final accounts = ref.watch(githubAccountsProvider);
      return BranchesNotifier(service, accounts, repoKey);
    });

class BranchesState {
  final List<GhBranch> branches;
  final bool isLoading;
  final String? error;

  const BranchesState({
    this.branches = const [],
    this.isLoading = false,
    this.error,
  });
}

class BranchesNotifier extends StateNotifier<BranchesState> {
  final GithubService _service;
  final List<GithubAccount> _accounts;
  final String repoKey;

  BranchesNotifier(this._service, this._accounts, this.repoKey)
    : super(const BranchesState());

  Future<void> load() async {
    final parts = repoKey.split('/');
    if (parts.length != 2) return;
    final token = _accounts.isNotEmpty ? _accounts.first.token : null;
    if (token == null) return;
    state = const BranchesState(isLoading: true);
    try {
      final branches = await _service.getBranches(token, parts[0], parts[1]);
      state = BranchesState(branches: branches);
    } catch (e) {
      state = BranchesState(error: e.toString());
    }
  }
}

// Stats provider per repo
final repoStatsProvider =
    StateNotifierProvider.family<StatsNotifier, GhRepoStats, String>((
      ref,
      repoKey,
    ) {
      final service = ref.watch(githubServiceProvider);
      final accounts = ref.watch(githubAccountsProvider);
      return StatsNotifier(service, accounts, repoKey);
    });

class StatsNotifier extends StateNotifier<GhRepoStats> {
  final GithubService _service;
  final List<GithubAccount> _accounts;
  final String repoKey;

  StatsNotifier(this._service, this._accounts, this.repoKey)
    : super(const GhRepoStats());

  Future<void> load() async {
    final parts = repoKey.split('/');
    if (parts.length != 2) return;
    final token = _accounts.isNotEmpty ? _accounts.first.token : null;
    if (token == null) return;

    state = const GhRepoStats(isLoading: true);

    try {
      final results = await Future.wait([
        _service.getContributors(token, parts[0], parts[1]),
        _service.getCommitActivity(token, parts[0], parts[1]),
        _service.getCodeFrequency(token, parts[0], parts[1]),
        _service.getPunchCard(token, parts[0], parts[1]),
        _service.getParticipation(token, parts[0], parts[1]),
      ]);

      state = GhRepoStats(
        contributors: results[0] as List<ContributorStat>,
        commitActivity: results[1] as List<CommitActivityWeek>,
        codeFrequency: results[2] as List<CodeFrequencyWeek>,
        punchCard: results[3] as List<PunchCardEntry>,
        participation: results[4] as ParticipationData?,
      );
    } catch (e) {
      state = GhRepoStats(error: e.toString());
    }
  }
}
