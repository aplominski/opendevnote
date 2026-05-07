import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/gh_pull_request.dart';
import 'package:opendevnote/models/gh_branch.dart';
import 'package:opendevnote/models/gh_issue_comment.dart';
import 'package:opendevnote/models/github_account.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/providers/workflow_provider.dart';
import 'package:opendevnote/services/github_service.dart';

const _prsCacheKey = 'pull_requests_list_v1';

final selectedPrRepoProvider = StateProvider<String?>((ref) => null);
final selectedPrNumberProvider = StateProvider<int?>((ref) => null);

class PullRequestsState {
  final Map<String, List<GhPullRequest>> prsByRepo;
  final bool isLoading;
  final String? error;

  const PullRequestsState({
    this.prsByRepo = const {},
    this.isLoading = false,
    this.error,
  });

  PullRequestsState copyWith({
    Map<String, List<GhPullRequest>>? prsByRepo,
    bool? isLoading,
    String? error,
  }) {
    return PullRequestsState(
      prsByRepo: prsByRepo ?? this.prsByRepo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<GhPullRequest> get allPrs {
    final all = <GhPullRequest>[];
    for (final prs in prsByRepo.values) {
      all.addAll(prs);
    }
    return all;
  }
}

final pullRequestsProvider =
    StateNotifierProvider<PullRequestsNotifier, PullRequestsState>((ref) {
      final service = ref.watch(githubServiceProvider);
      final accounts = ref.watch(githubAccountsProvider);
      return PullRequestsNotifier(service, accounts, ref);
    });

class PullRequestsNotifier extends StateNotifier<PullRequestsState> {
  final GithubService _service;
  final List<GithubAccount> _accounts;
  final Ref _ref;

  PullRequestsNotifier(this._service, this._accounts, this._ref)
    : super(const PullRequestsState()) {
    if (_accounts.isNotEmpty) _loadFromCacheAndSync();
  }

  Future<void> _loadFromCacheAndSync() async {
    final storage = _ref.read(storageServiceProvider);
    final cachedData = storage.loadGithubCacheData(_prsCacheKey);

    if (cachedData != null) {
      try {
        final prsByRepo = <String, List<GhPullRequest>>{};
        final entries = cachedData['prsByRepo'] as Map<String, dynamic>;
        for (final entry in entries.entries) {
          prsByRepo[entry.key] = (entry.value as List)
              .map((e) => GhPullRequest.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        state = PullRequestsState(prsByRepo: prsByRepo, isLoading: true);
      } catch (_) {}
    }

    await fetchAll();
  }

  Future<void> fetchAll() async {
    if (_accounts.isEmpty) return;
    state = state.copyWith(isLoading: true, error: null);

    final allPrs = <String, List<GhPullRequest>>{};
    String? lastError;

    for (final account in _accounts) {
      try {
        final repos = await _service.getUserRepos(account.token);

        final futures = repos.map((repo) async {
          try {
            final prs = await _service.getPullRequests(
              owner: repo.ownerLogin,
              repo: repo.name,
              token: account.token,
              state: 'all',
            );
            if (prs.isNotEmpty) {
              return MapEntry(repo.fullName, prs);
            }
          } catch (_) {}
          return null;
        });

        final results = await Future.wait(futures);
        for (final entry in results) {
          if (entry != null) {
            allPrs[entry.key] = entry.value;
          }
        }
      } catch (e) {
        lastError = '${account.name}: $e';
      }
    }

    final storage = _ref.read(storageServiceProvider);
    final cacheData = <String, dynamic>{};
    allPrs.forEach((repo, prs) {
      cacheData[repo] = prs.map((pr) => pr.toJson()).toList();
    });
    storage.saveGithubCache(_prsCacheKey, {'prsByRepo': cacheData});

    state = PullRequestsState(
      prsByRepo: allPrs,
      isLoading: false,
      error: lastError,
    );
  }
}

class RepoPullRequestsState {
  final List<GhPullRequest> prs;
  final List<GhBranch> branches;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final String? error;

  const RepoPullRequestsState({
    this.prs = const [],
    this.branches = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  RepoPullRequestsState copyWith({
    List<GhPullRequest>? prs,
    List<GhBranch>? branches,
    int? page,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return RepoPullRequestsState(
      prs: prs ?? this.prs,
      branches: branches ?? this.branches,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final repoPullRequestsProvider =
    StateNotifierProvider.family<
      RepoPullRequestsNotifier,
      RepoPullRequestsState,
      String
    >((ref, repoKey) {
      final service = ref.watch(githubServiceProvider);
      final accounts = ref.watch(githubAccountsProvider);
      return RepoPullRequestsNotifier(service, accounts, repoKey);
    });

class RepoPullRequestsNotifier extends StateNotifier<RepoPullRequestsState> {
  final GithubService _service;
  final List<GithubAccount> _accounts;
  final String repoKey;

  RepoPullRequestsNotifier(this._service, this._accounts, this.repoKey)
    : super(const RepoPullRequestsState());

  String? _getToken() {
    return _accounts.isNotEmpty ? _accounts.first.token : null;
  }

  List<String> get _ownerRepo => repoKey.split('/');

  Future<void> loadFirst({String state = 'all'}) async {
    if (_ownerRepo.length != 2) return;
    super.state = const RepoPullRequestsState(isLoading: true);
    final token = _getToken();
    if (token == null) {
      super.state = const RepoPullRequestsState(error: 'Brak konta GitHub');
      return;
    }
    try {
      final prs = await _service.getPullRequests(
        owner: _ownerRepo[0],
        repo: _ownerRepo[1],
        token: token,
        state: state,
        page: 1,
      );
      super.state = RepoPullRequestsState(
        prs: prs,
        branches: super.state.branches,
        page: 1,
        hasMore: prs.length >= 30,
      );
    } catch (e) {
      super.state = RepoPullRequestsState(error: e.toString());
    }
  }

  Future<void> loadBranches() async {
    if (_ownerRepo.length != 2) return;
    final token = _getToken();
    if (token == null) return;
    try {
      final branches = await _service.getBranches(
        token,
        _ownerRepo[0],
        _ownerRepo[1],
      );
      super.state = super.state.copyWith(branches: branches);
    } catch (_) {}
  }

  Future<void> loadMore({String prState = 'all'}) async {
    if (super.state.isLoading || !super.state.hasMore) return;
    final token = _getToken();
    if (token == null) return;
    super.state = super.state.copyWith(isLoading: true);
    try {
      final nextPage = super.state.page + 1;
      final prs = await _service.getPullRequests(
        owner: _ownerRepo[0],
        repo: _ownerRepo[1],
        token: token,
        state: prState,
        page: nextPage,
      );
      super.state = super.state.copyWith(
        prs: [...super.state.prs, ...prs],
        page: nextPage,
        hasMore: prs.length >= 30,
        isLoading: false,
      );
    } catch (e) {
      super.state = super.state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<GhPullRequest> createPullRequest({
    required String title,
    String? body,
    required String head,
    required String base,
    bool draft = false,
  }) async {
    if (_ownerRepo.length != 2) throw Exception('Invalid repo key');
    final token = _getToken();
    if (token == null) throw Exception('Brak konta GitHub');
    final pr = await _service.createPullRequest(
      owner: _ownerRepo[0],
      repo: _ownerRepo[1],
      token: token,
      title: title,
      body: body,
      head: head,
      base: base,
      draft: draft,
    );
    super.state = super.state.copyWith(prs: [pr, ...super.state.prs]);
    return pr;
  }

  Future<GhPullRequest> updatePullRequest({
    required int number,
    String? title,
    String? body,
    String? prState,
  }) async {
    if (_ownerRepo.length != 2) throw Exception('Invalid repo key');
    final token = _getToken();
    if (token == null) throw Exception('Brak konta GitHub');
    final updated = await _service.updatePullRequest(
      owner: _ownerRepo[0],
      repo: _ownerRepo[1],
      number: number,
      token: token,
      title: title,
      body: body,
      state: prState,
    );
    super.state = super.state.copyWith(
      prs: super.state.prs
          .map((pr) => pr.number == number ? updated : pr)
          .toList(),
    );
    return updated;
  }
}

class PrCommentsState {
  final List<GhIssueComment> comments;
  final bool isLoading;
  final String? error;

  const PrCommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  PrCommentsState copyWith({
    List<GhIssueComment>? comments,
    bool? isLoading,
    String? error,
  }) {
    return PrCommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final prCommentsProvider =
    StateNotifierProvider.family<
      PrCommentsNotifier,
      PrCommentsState,
      (String, int)
    >((ref, key) {
      final service = ref.watch(githubServiceProvider);
      final accounts = ref.watch(githubAccountsProvider);
      return PrCommentsNotifier(service, accounts, key.$1, key.$2);
    });

class PrCommentsNotifier extends StateNotifier<PrCommentsState> {
  final GithubService _service;
  final List<GithubAccount> _accounts;
  final String repoKey;
  final int prNumber;

  PrCommentsNotifier(this._service, this._accounts, this.repoKey, this.prNumber)
    : super(const PrCommentsState());

  String? _getToken() {
    return _accounts.isNotEmpty ? _accounts.first.token : null;
  }

  List<String> get _ownerRepo => repoKey.split('/');

  Future<void> load() async {
    if (_ownerRepo.length != 2) return;
    super.state = const PrCommentsState(isLoading: true);
    final token = _getToken();
    if (token == null) {
      super.state = const PrCommentsState(error: 'Brak konta GitHub');
      return;
    }
    try {
      final comments = await _service.getPullRequestComments(
        owner: _ownerRepo[0],
        repo: _ownerRepo[1],
        number: prNumber,
        token: token,
      );
      super.state = PrCommentsState(comments: comments);
    } catch (e) {
      super.state = PrCommentsState(error: e.toString());
    }
  }

  Future<void> addComment(String body) async {
    if (_ownerRepo.length != 2) return;
    final token = _getToken();
    if (token == null) return;
    try {
      final comment = await _service.addComment(
        owner: _ownerRepo[0],
        repo: _ownerRepo[1],
        number: prNumber,
        token: token,
        body: body,
      );
      super.state = super.state.copyWith(
        comments: [...super.state.comments, comment],
      );
    } catch (e) {
      super.state = super.state.copyWith(error: e.toString());
    }
  }
}

final prDetailProvider = FutureProvider.family<GhPullRequest, (String, int)>((
  ref,
  key,
) async {
  final service = ref.watch(githubServiceProvider);
  final accounts = ref.watch(githubAccountsProvider);
  if (accounts.isEmpty) throw Exception('Brak konta GitHub');
  final parts = key.$1.split('/');
  if (parts.length != 2) throw Exception('Invalid repo key');
  return service.getPullRequest(
    owner: parts[0],
    repo: parts[1],
    number: key.$2,
    token: accounts.first.token,
  );
});
