import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/gh_issue.dart';
import 'package:opendevnote/models/gh_issue_comment.dart';
import 'package:opendevnote/models/github_account.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/providers/workflow_provider.dart';
import 'package:opendevnote/services/github_service.dart';

const _issuesCacheKey = 'issues_list_v1';

final selectedIssueRepoProvider = StateProvider<String?>((ref) => null);
final selectedIssueNumberProvider = StateProvider<int?>((ref) => null);

class IssuesState {
  final Map<String, List<GhIssue>> issuesByRepo;
  final bool isLoading;
  final String? error;

  const IssuesState({
    this.issuesByRepo = const {},
    this.isLoading = false,
    this.error,
  });

  IssuesState copyWith({
    Map<String, List<GhIssue>>? issuesByRepo,
    bool? isLoading,
    String? error,
  }) {
    return IssuesState(
      issuesByRepo: issuesByRepo ?? this.issuesByRepo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<GhIssue> get allIssues {
    final all = <GhIssue>[];
    for (final issues in issuesByRepo.values) {
      all.addAll(issues);
    }
    return all;
  }
}

final issuesProvider = StateNotifierProvider<IssuesNotifier, IssuesState>((
  ref,
) {
  final service = ref.watch(githubServiceProvider);
  final accounts = ref.watch(githubAccountsProvider);
  return IssuesNotifier(service, accounts, ref);
});

class IssuesNotifier extends StateNotifier<IssuesState> {
  final GithubService _service;
  final List<GithubAccount> _accounts;
  final Ref _ref;

  IssuesNotifier(this._service, this._accounts, this._ref)
    : super(const IssuesState()) {
    if (_accounts.isNotEmpty) _loadFromCacheAndSync();
  }

  Future<void> _loadFromCacheAndSync() async {
    final storage = _ref.read(storageServiceProvider);
    final cachedData = storage.loadGithubCacheData(_issuesCacheKey);

    if (cachedData != null) {
      try {
        final issuesByRepo = <String, List<GhIssue>>{};
        final entries = cachedData['issuesByRepo'] as Map<String, dynamic>;
        for (final entry in entries.entries) {
          issuesByRepo[entry.key] = (entry.value as List)
              .map((e) => GhIssue.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        state = IssuesState(issuesByRepo: issuesByRepo, isLoading: true);
      } catch (_) {}
    }

    await fetchAll();
  }

  Future<void> fetchAll() async {
    if (_accounts.isEmpty) return;
    state = state.copyWith(isLoading: true, error: null);

    final allIssues = <String, List<GhIssue>>{};
    String? lastError;

    for (final account in _accounts) {
      try {
        final repos = await _service.getUserRepos(account.token);

        final futures = repos.map((repo) async {
          try {
            final issues = await _service.getIssues(
              owner: repo.ownerLogin,
              repo: repo.name,
              token: account.token,
              state: 'all',
            );
            final nonPrIssues = issues.where((i) => !i.isPullRequest).toList();
            if (nonPrIssues.isNotEmpty) {
              return MapEntry(repo.fullName, nonPrIssues);
            }
          } catch (_) {}
          return null;
        });

        final results = await Future.wait(futures);
        for (final entry in results) {
          if (entry != null) {
            allIssues[entry.key] = entry.value;
          }
        }
      } catch (e) {
        lastError = '${account.name}: $e';
      }
    }

    final storage = _ref.read(storageServiceProvider);
    final cacheData = <String, dynamic>{};
    allIssues.forEach((repo, issues) {
      cacheData[repo] = issues.map((i) => i.toJson()).toList();
    });
    storage.saveGithubCache(_issuesCacheKey, {'issuesByRepo': cacheData});

    state = IssuesState(
      issuesByRepo: allIssues,
      isLoading: false,
      error: lastError,
    );
  }
}

class RepoIssuesState {
  final List<GhIssue> issues;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final String? error;

  const RepoIssuesState({
    this.issues = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.error,
  });

  RepoIssuesState copyWith({
    List<GhIssue>? issues,
    int? page,
    bool? hasMore,
    bool? isLoading,
    String? error,
  }) {
    return RepoIssuesState(
      issues: issues ?? this.issues,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final repoIssuesProvider =
    StateNotifierProvider.family<RepoIssuesNotifier, RepoIssuesState, String>((
      ref,
      repoKey,
    ) {
      final service = ref.watch(githubServiceProvider);
      final accounts = ref.watch(githubAccountsProvider);
      return RepoIssuesNotifier(service, accounts, repoKey);
    });

class RepoIssuesNotifier extends StateNotifier<RepoIssuesState> {
  final GithubService _service;
  final List<GithubAccount> _accounts;
  final String repoKey;

  RepoIssuesNotifier(this._service, this._accounts, this.repoKey)
    : super(const RepoIssuesState());

  String? _getToken() {
    return _accounts.isNotEmpty ? _accounts.first.token : null;
  }

  List<String> get _ownerRepo => repoKey.split('/');

  Future<void> loadFirst({String state = 'all'}) async {
    if (_ownerRepo.length != 2) return;
    super.state = const RepoIssuesState(isLoading: true);
    final token = _getToken();
    if (token == null) {
      super.state = const RepoIssuesState(error: 'Brak konta GitHub');
      return;
    }
    try {
      final issues = await _service.getIssues(
        owner: _ownerRepo[0],
        repo: _ownerRepo[1],
        token: token,
        state: state,
        page: 1,
      );
      final nonPrIssues = issues.where((i) => !i.isPullRequest).toList();
      super.state = RepoIssuesState(
        issues: nonPrIssues,
        page: 1,
        hasMore: nonPrIssues.length >= 30,
      );
    } catch (e) {
      super.state = RepoIssuesState(error: e.toString());
    }
  }

  Future<void> loadMore({String issueState = 'all'}) async {
    if (super.state.isLoading || !super.state.hasMore) return;
    final token = _getToken();
    if (token == null) return;
    super.state = super.state.copyWith(isLoading: true);
    try {
      final nextPage = super.state.page + 1;
      final issues = await _service.getIssues(
        owner: _ownerRepo[0],
        repo: _ownerRepo[1],
        token: token,
        state: issueState,
        page: nextPage,
      );
      final nonPrIssues = issues.where((i) => !i.isPullRequest).toList();
      super.state = super.state.copyWith(
        issues: [...super.state.issues, ...nonPrIssues],
        page: nextPage,
        hasMore: nonPrIssues.length >= 30,
        isLoading: false,
      );
    } catch (e) {
      super.state = super.state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<GhIssue> createIssue({
    required String title,
    String? body,
    List<String>? labels,
  }) async {
    if (_ownerRepo.length != 2) throw Exception('Invalid repo key');
    final token = _getToken();
    if (token == null) throw Exception('Brak konta GitHub');
    final issue = await _service.createIssue(
      owner: _ownerRepo[0],
      repo: _ownerRepo[1],
      token: token,
      title: title,
      body: body,
      labels: labels,
    );
    super.state = super.state.copyWith(issues: [issue, ...super.state.issues]);
    return issue;
  }

  Future<GhIssue> updateIssue({
    required int number,
    String? title,
    String? body,
    String? issueState,
  }) async {
    if (_ownerRepo.length != 2) throw Exception('Invalid repo key');
    final token = _getToken();
    if (token == null) throw Exception('Brak konta GitHub');
    final updated = await _service.updateIssue(
      owner: _ownerRepo[0],
      repo: _ownerRepo[1],
      number: number,
      token: token,
      title: title,
      body: body,
      state: issueState,
    );
    super.state = super.state.copyWith(
      issues: super.state.issues
          .map((i) => i.number == number ? updated : i)
          .toList(),
    );
    return updated;
  }
}

class IssueCommentsState {
  final List<GhIssueComment> comments;
  final bool isLoading;
  final String? error;

  const IssueCommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  IssueCommentsState copyWith({
    List<GhIssueComment>? comments,
    bool? isLoading,
    String? error,
  }) {
    return IssueCommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final issueCommentsProvider =
    StateNotifierProvider.family<
      IssueCommentsNotifier,
      IssueCommentsState,
      (String, int)
    >((ref, key) {
      final service = ref.watch(githubServiceProvider);
      final accounts = ref.watch(githubAccountsProvider);
      return IssueCommentsNotifier(service, accounts, key.$1, key.$2);
    });

class IssueCommentsNotifier extends StateNotifier<IssueCommentsState> {
  final GithubService _service;
  final List<GithubAccount> _accounts;
  final String repoKey;
  final int issueNumber;

  IssueCommentsNotifier(
    this._service,
    this._accounts,
    this.repoKey,
    this.issueNumber,
  ) : super(const IssueCommentsState());

  String? _getToken() {
    return _accounts.isNotEmpty ? _accounts.first.token : null;
  }

  List<String> get _ownerRepo => repoKey.split('/');

  Future<void> load() async {
    if (_ownerRepo.length != 2) return;
    super.state = const IssueCommentsState(isLoading: true);
    final token = _getToken();
    if (token == null) {
      super.state = const IssueCommentsState(error: 'Brak konta GitHub');
      return;
    }
    try {
      final comments = await _service.getIssueComments(
        owner: _ownerRepo[0],
        repo: _ownerRepo[1],
        number: issueNumber,
        token: token,
      );
      super.state = IssueCommentsState(comments: comments);
    } catch (e) {
      super.state = IssueCommentsState(error: e.toString());
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
        number: issueNumber,
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

final issueDetailProvider = FutureProvider.family<GhIssue, (String, int)>((
  ref,
  key,
) async {
  final service = ref.watch(githubServiceProvider);
  final accounts = ref.watch(githubAccountsProvider);
  if (accounts.isEmpty) throw Exception('Brak konta GitHub');
  final parts = key.$1.split('/');
  if (parts.length != 2) throw Exception('Invalid repo key');
  return service.getIssue(
    owner: parts[0],
    repo: parts[1],
    number: key.$2,
    token: accounts.first.token,
  );
});
