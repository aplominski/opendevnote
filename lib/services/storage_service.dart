import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:opendevnote/models/cached_github_data.dart';
import 'package:opendevnote/models/code_snippet.dart';
import 'package:opendevnote/models/event.dart';
import 'package:opendevnote/models/github_account.dart';
import 'package:opendevnote/models/github_repo_config.dart';
import 'package:opendevnote/models/note.dart';
import 'package:opendevnote/models/project.dart';
import 'package:opendevnote/models/todo_item.dart';
import 'package:opendevnote/models/work_session.dart';
import 'package:opendevnote/models/rss_feed.dart';
import 'package:opendevnote/models/rss_article.dart';
import 'package:opendevnote/models/rss_preferences.dart';

class StorageService {
  static const String projectsBox = 'projects';
  static const String todosBox = 'todos';
  static const String notesBox = 'notes';
  static const String eventsBox = 'events';
  static const String snippetsBox = 'snippets';
  static const String githubReposBox = 'github_repos';
  static const String githubAccountsBox = 'github_accounts';
  static const String starredReposBox = 'starred_repos';
  static const String workSessionsBox = 'work_sessions';
  static const String rssFeedsBox = 'rss_feeds';
  static const String rssArticlesBox = 'rss_articles';
  static const String rssPrefsBox = 'rss_prefs';
  static const String githubCacheBox = 'github_cache';
  static const String settingsBox = 'settings';

  Box<Project> get _projectsBox => Hive.box<Project>(projectsBox);
  Box<TodoItem> get _todosBox => Hive.box<TodoItem>(todosBox);
  Box<Note> get _notesBox => Hive.box<Note>(notesBox);
  Box<Event> get _eventsBox => Hive.box<Event>(eventsBox);
  Box<CodeSnippet> get _snippetsBox => Hive.box<CodeSnippet>(snippetsBox);
  Box<GithubRepoConfig> get _githubReposBox =>
      Hive.box<GithubRepoConfig>(githubReposBox);
  Box<GithubAccount> get _githubAccountsBox =>
      Hive.box<GithubAccount>(githubAccountsBox);

  // Projects
  List<Project> getAllProjects() {
    return _projectsBox.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  Project? getProject(String id) {
    return _projectsBox.get(id);
  }

  Future<void> saveProject(Project project) async {
    await _projectsBox.put(project.id, project);
  }

  Future<void> deleteProject(String projectId) async {
    final todoKeys = _todosBox.values
        .where((todo) => todo.projectId == projectId)
        .map((todo) => todo.id)
        .toList();
    for (final key in todoKeys) {
      await _todosBox.delete(key);
    }
    final noteKeys = _notesBox.values
        .where((note) => note.projectId == projectId)
        .map((note) => note.id)
        .toList();
    for (final key in noteKeys) {
      await _notesBox.delete(key);
    }
    final snippetKeys = _snippetsBox.values
        .where((snippet) => snippet.projectId == projectId)
        .map((snippet) => snippet.id)
        .toList();
    for (final key in snippetKeys) {
      await _snippetsBox.delete(key);
    }
    await _projectsBox.delete(projectId);
  }

  Future<void> updateProjectsOrder(List<Project> projects) async {
    for (int i = 0; i < projects.length; i++) {
      final updated = projects[i].copyWith(sortOrder: i);
      await _projectsBox.put(updated.id, updated);
    }
  }

  // Todos
  List<TodoItem> getTodosForProject(String projectId) {
    return _todosBox.values
        .where((todo) => todo.projectId == projectId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  TodoItem? getTodo(String id) {
    return _todosBox.get(id);
  }

  Future<void> saveTodo(TodoItem todo) async {
    await _todosBox.put(todo.id, todo);
  }

  Future<void> deleteTodo(String todoId) async {
    await _todosBox.delete(todoId);
  }

  Future<void> updateTodosOrder(List<TodoItem> todos) async {
    for (int i = 0; i < todos.length; i++) {
      final updated = todos[i].copyWith(sortOrder: i);
      await _todosBox.put(updated.id, updated);
    }
  }

  // Search
  List<TodoItem> searchTodos(String query, {String? projectId}) {
    final lowerQuery = query.toLowerCase();
    Iterable<TodoItem> results = _todosBox.values.where((todo) {
      return todo.title.toLowerCase().contains(lowerQuery) ||
          todo.description.toLowerCase().contains(lowerQuery) ||
          todo.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    });
    if (projectId != null) {
      results = results.where((todo) => todo.projectId == projectId);
    }
    return results.toList();
  }

  int getTodoCountForProject(String projectId) {
    return _todosBox.values.where((todo) => todo.projectId == projectId).length;
  }

  int getCompletedCountForProject(String projectId) {
    return _todosBox.values
        .where((todo) => todo.projectId == projectId && todo.isCompleted)
        .length;
  }

  // Notes
  List<Note> getNotesForProject(String projectId) {
    return _notesBox.values
        .where((note) => note.projectId == projectId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> saveNote(Note note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> deleteNote(String noteId) async {
    await _notesBox.delete(noteId);
  }

  // Events
  List<Event> getAllEvents() {
    return _eventsBox.values.toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  List<Event> getEventsForProject(String projectId) {
    return _eventsBox.values
        .where((event) => event.projectId == projectId)
        .toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  List<Event> getEventsForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return _eventsBox.values.where((event) {
      final eventDate = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );
      return eventDate == targetDate;
    }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  Future<void> saveEvent(Event event) async {
    await _eventsBox.put(event.id, event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsBox.delete(eventId);
  }

  // Snippets
  List<CodeSnippet> getSnippetsForProject(String projectId) {
    return _snippetsBox.values
        .where((snippet) => snippet.projectId == projectId)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  CodeSnippet? getSnippet(String id) {
    return _snippetsBox.get(id);
  }

  Future<void> saveSnippet(CodeSnippet snippet) async {
    await _snippetsBox.put(snippet.id, snippet);
  }

  Future<void> deleteSnippet(String snippetId) async {
    await _snippetsBox.delete(snippetId);
  }

  // GitHub Repo Configs
  List<GithubRepoConfig> getGithubRepoConfigs() {
    return _githubReposBox.values.toList();
  }

  Future<void> saveGithubRepoConfig(GithubRepoConfig config) async {
    await _githubReposBox.put(config.id, config);
  }

  Future<void> deleteGithubRepoConfig(String id) async {
    await _githubReposBox.delete(id);
  }

  // GitHub Accounts
  List<GithubAccount> getGithubAccounts() {
    return _githubAccountsBox.values.toList();
  }

  Future<void> saveGithubAccount(GithubAccount account) async {
    await _githubAccountsBox.put(account.id, account);
  }

  Future<void> deleteGithubAccount(String id) async {
    await _githubAccountsBox.delete(id);
  }

  // Starred repos
  List<String> getStarredRepos() {
    final box = Hive.box(starredReposBox);
    final data = box.get('starred', defaultValue: <String>[]);
    return List<String>.from(data as List);
  }

  Future<void> saveStarredRepos(List<String> repos) async {
    final box = Hive.box(starredReposBox);
    await box.put('starred', repos);
  }

  // Work Sessions
  Box<WorkSession> get _workSessionsBox =>
      Hive.box<WorkSession>(workSessionsBox);

  List<WorkSession> getAllWorkSessions() {
    return _workSessionsBox.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  WorkSession? getActiveWorkSession() {
    try {
      return _workSessionsBox.values.firstWhere((s) => s.isActive);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveWorkSession(WorkSession session) async {
    await _workSessionsBox.put(session.id, session);
  }

  Future<void> deleteWorkSession(String id) async {
    await _workSessionsBox.delete(id);
  }

  // RSS Feeds
  Box<RssFeed> get _rssFeedsBox => Hive.box<RssFeed>(rssFeedsBox);
  Box<RssArticle> get _rssArticlesBox => Hive.box<RssArticle>(rssArticlesBox);
  Box<RssPreferences> get _rssPrefsBox => Hive.box<RssPreferences>(rssPrefsBox);
  Box<CachedGithubData> get _githubCacheBox =>
      Hive.box<CachedGithubData>(githubCacheBox);

  List<RssFeed> getAllRssFeeds() {
    return _rssFeedsBox.values.toList()
      ..sort((a, b) => a.addedAt.compareTo(b.addedAt));
  }

  RssFeed? getRssFeed(String id) {
    return _rssFeedsBox.get(id);
  }

  Future<void> saveRssFeed(RssFeed feed) async {
    await _rssFeedsBox.put(feed.id, feed);
  }

  Future<void> deleteRssFeed(String feedId) async {
    final articleKeys = _rssArticlesBox.values
        .where((a) => a.feedId == feedId)
        .map((a) => a.id)
        .toList();
    for (final key in articleKeys) {
      await _rssArticlesBox.delete(key);
    }
    await _rssFeedsBox.delete(feedId);
  }

  // RSS Articles
  List<RssArticle> getArticlesForFeed(String feedId) {
    return _rssArticlesBox.values.where((a) => a.feedId == feedId).toList()
      ..sort((a, b) {
        final aDate = a.publishedAt ?? a.fetchedAt;
        final bDate = b.publishedAt ?? b.fetchedAt;
        return bDate.compareTo(aDate);
      });
  }

  List<RssArticle> getAllRssArticles() {
    return _rssArticlesBox.values.toList()..sort((a, b) {
      final aDate = a.publishedAt ?? a.fetchedAt;
      final bDate = b.publishedAt ?? b.fetchedAt;
      return bDate.compareTo(aDate);
    });
  }

  Future<void> saveRssArticle(RssArticle article) async {
    await _rssArticlesBox.put(article.id, article);
  }

  Future<void> deleteRssArticle(String articleId) async {
    await _rssArticlesBox.delete(articleId);
  }

  int getUnreadCount(String feedId) {
    return _rssArticlesBox.values
        .where((a) => a.feedId == feedId && !a.isRead)
        .length;
  }

  int getTotalUnreadCount() {
    return _rssArticlesBox.values.where((a) => !a.isRead).length;
  }

  Future<void> cleanupOldArticles(int days) async {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final toDelete = _rssArticlesBox.values
        .where((a) => a.fetchedAt.isBefore(cutoff))
        .map((a) => a.id)
        .toList();
    for (final key in toDelete) {
      await _rssArticlesBox.delete(key);
    }
  }

  // RSS Preferences
  RssPreferences getRssPreferences() {
    if (_rssPrefsBox.isEmpty) {
      return RssPreferences();
    }
    return _rssPrefsBox.getAt(0)!;
  }

  Future<void> saveRssPreferences(RssPreferences prefs) async {
    await _rssPrefsBox.put(0, prefs);
  }

  // GitHub API Cache
  CachedGithubData? getGithubCache(String key) {
    return _githubCacheBox.get(key);
  }

  Future<void> saveGithubCache(String key, Map<String, dynamic> data) async {
    final cached = CachedGithubData(
      key: key,
      data: jsonEncode(data),
      cachedAt: DateTime.now(),
    );
    await _githubCacheBox.put(key, cached);
  }

  Map<String, dynamic>? loadGithubCacheData(String key) {
    final cached = _githubCacheBox.get(key);
    if (cached == null || cached.isExpired) return null;
    try {
      return jsonDecode(cached.data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  bool hasValidGithubCache(String key) {
    final cached = _githubCacheBox.get(key);
    return cached != null && !cached.isExpired;
  }

  bool hasStaleGithubCache(String key) {
    final cached = _githubCacheBox.get(key);
    return cached != null && !cached.isExpired;
  }

  Future<void> clearGithubCache() async {
    await _githubCacheBox.clear();
  }

  // App Settings
  String? getLocale() {
    final box = Hive.box(settingsBox);
    return box.get('locale');
  }

  Future<void> saveLocale(String? locale) async {
    final box = Hive.box(settingsBox);
    if (locale == null) {
      await box.delete('locale');
    } else {
      await box.put('locale', locale);
    }
  }

  // Export/Import all data
  Map<String, dynamic> exportAllToJson() {
    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'projects': _projectsBox.values.map(_projectToJson).toList(),
      'todos': _todosBox.values.map(_todoToJson).toList(),
      'notes': _notesBox.values.map(_noteToJson).toList(),
      'events': _eventsBox.values.map(_eventToJson).toList(),
      'snippets': _snippetsBox.values.map(_snippetToJson).toList(),
      'githubAccounts': _githubAccountsBox.values
          .map(_githubAccountToJson)
          .toList(),
      'githubRepoConfigs': _githubReposBox.values
          .map(_githubRepoConfigToJson)
          .toList(),
      'workSessions': _workSessionsBox.values.map(_workSessionToJson).toList(),
      'rssFeeds': _rssFeedsBox.values.map(_rssFeedToJson).toList(),
      'rssArticles': _rssArticlesBox.values.map(_rssArticleToJson).toList(),
      'rssPreferences': _rssPrefsBox.isEmpty
          ? null
          : _rssPrefsToJson(_rssPrefsBox.getAt(0)!),
      'starredRepos': getStarredRepos(),
      'settings': {'locale': getLocale()},
    };
  }

  Future<void> importAllFromJson(Map<String, dynamic> data) async {
    await _projectsBox.clear();
    await _todosBox.clear();
    await _notesBox.clear();
    await _eventsBox.clear();
    await _snippetsBox.clear();
    await _githubAccountsBox.clear();
    await _githubReposBox.clear();
    await _workSessionsBox.clear();
    await _rssFeedsBox.clear();
    await _rssArticlesBox.clear();
    await _rssPrefsBox.clear();
    await Hive.box(starredReposBox).clear();
    await Hive.box(settingsBox).clear();

    for (final json in data['projects'] as List) {
      await _projectsBox.put(json['id'], _projectFromJson(json));
    }
    for (final json in data['todos'] as List) {
      await _todosBox.put(json['id'], _todoFromJson(json));
    }
    for (final json in data['notes'] as List) {
      await _notesBox.put(json['id'], _noteFromJson(json));
    }
    for (final json in data['events'] as List) {
      await _eventsBox.put(json['id'], _eventFromJson(json));
    }
    for (final json in data['snippets'] as List) {
      await _snippetsBox.put(json['id'], _snippetFromJson(json));
    }
    for (final json in data['githubAccounts'] as List) {
      await _githubAccountsBox.put(json['id'], _githubAccountFromJson(json));
    }
    for (final json in data['githubRepoConfigs'] as List) {
      await _githubReposBox.put(json['id'], _githubRepoConfigFromJson(json));
    }
    for (final json in data['workSessions'] as List) {
      await _workSessionsBox.put(json['id'], _workSessionFromJson(json));
    }
    for (final json in data['rssFeeds'] as List) {
      await _rssFeedsBox.put(json['id'], _rssFeedFromJson(json));
    }
    for (final json in data['rssArticles'] as List) {
      await _rssArticlesBox.put(json['id'], _rssArticleFromJson(json));
    }
    if (data['rssPreferences'] != null) {
      await _rssPrefsBox.put(0, _rssPrefsFromJson(data['rssPreferences']));
    }
    await saveStarredRepos(List<String>.from(data['starredRepos'] as List));
    if (data['settings']?['locale'] != null) {
      await saveLocale(data['settings']['locale']);
    }
  }

  Map<String, dynamic> _projectToJson(Project p) => {
    'id': p.id,
    'name': p.name,
    'colorIndex': p.colorIndex,
    'iconIndex': p.iconIndex,
    'tags': p.tags,
    'createdAt': p.createdAt.toIso8601String(),
    'sortOrder': p.sortOrder,
  };

  Project _projectFromJson(Map<String, dynamic> j) => Project(
    id: j['id'],
    name: j['name'],
    colorIndex: j['colorIndex'],
    iconIndex: j['iconIndex'],
    tags: List<String>.from(j['tags']),
    createdAt: DateTime.parse(j['createdAt']),
    sortOrder: j['sortOrder'],
  );

  Map<String, dynamic> _todoToJson(TodoItem t) => {
    'id': t.id,
    'projectId': t.projectId,
    'title': t.title,
    'description': t.description,
    'isCompleted': t.isCompleted,
    'tags': t.tags,
    'createdAt': t.createdAt.toIso8601String(),
    'sortOrder': t.sortOrder,
    'dueDate': t.dueDate?.toIso8601String(),
  };

  TodoItem _todoFromJson(Map<String, dynamic> j) => TodoItem(
    id: j['id'],
    projectId: j['projectId'],
    title: j['title'],
    description: j['description'],
    isCompleted: j['isCompleted'],
    tags: List<String>.from(j['tags']),
    createdAt: DateTime.parse(j['createdAt']),
    sortOrder: j['sortOrder'],
    dueDate: j['dueDate'] != null ? DateTime.parse(j['dueDate']) : null,
  );

  Map<String, dynamic> _noteToJson(Note n) => {
    'id': n.id,
    'projectId': n.projectId,
    'title': n.title,
    'content': n.content,
    'createdAt': n.createdAt.toIso8601String(),
    'updatedAt': n.updatedAt.toIso8601String(),
    'sortOrder': n.sortOrder,
    'linkedTaskId': n.linkedTaskId,
  };

  Note _noteFromJson(Map<String, dynamic> j) => Note(
    id: j['id'],
    projectId: j['projectId'],
    title: j['title'],
    content: j['content'],
    createdAt: DateTime.parse(j['createdAt']),
    updatedAt: DateTime.parse(j['updatedAt']),
    sortOrder: j['sortOrder'],
    linkedTaskId: j['linkedTaskId'],
  );

  Map<String, dynamic> _eventToJson(Event e) => {
    'id': e.id,
    'projectId': e.projectId,
    'title': e.title,
    'description': e.description,
    'startDate': e.startDate.toIso8601String(),
    'endDate': e.endDate?.toIso8601String(),
    'colorIndex': e.colorIndex,
    'createdAt': e.createdAt.toIso8601String(),
    'sortOrder': e.sortOrder,
  };

  Event _eventFromJson(Map<String, dynamic> j) => Event(
    id: j['id'],
    projectId: j['projectId'],
    title: j['title'],
    description: j['description'],
    startDate: DateTime.parse(j['startDate']),
    endDate: j['endDate'] != null ? DateTime.parse(j['endDate']) : null,
    colorIndex: j['colorIndex'],
    createdAt: DateTime.parse(j['createdAt']),
    sortOrder: j['sortOrder'],
  );

  Map<String, dynamic> _snippetToJson(CodeSnippet s) => {
    'id': s.id,
    'projectId': s.projectId,
    'title': s.title,
    'code': s.code,
    'language': s.language,
    'createdAt': s.createdAt.toIso8601String(),
    'updatedAt': s.updatedAt.toIso8601String(),
    'sortOrder': s.sortOrder,
    'linkedTaskId': s.linkedTaskId,
    'description': s.description,
  };

  CodeSnippet _snippetFromJson(Map<String, dynamic> j) => CodeSnippet(
    id: j['id'],
    projectId: j['projectId'],
    title: j['title'],
    code: j['code'],
    language: j['language'],
    createdAt: DateTime.parse(j['createdAt']),
    updatedAt: DateTime.parse(j['updatedAt']),
    sortOrder: j['sortOrder'],
    linkedTaskId: j['linkedTaskId'],
    description: j['description'],
  );

  Map<String, dynamic> _githubAccountToJson(GithubAccount a) => {
    'id': a.id,
    'name': a.name,
    'token': a.token,
  };

  GithubAccount _githubAccountFromJson(Map<String, dynamic> j) =>
      GithubAccount(id: j['id'], name: j['name'], token: j['token']);

  Map<String, dynamic> _githubRepoConfigToJson(GithubRepoConfig c) => {
    'id': c.id,
    'owner': c.owner,
    'repo': c.repo,
    'accountId': c.accountId,
    'refreshIntervalSeconds': c.refreshIntervalSeconds,
  };

  GithubRepoConfig _githubRepoConfigFromJson(Map<String, dynamic> j) =>
      GithubRepoConfig(
        id: j['id'],
        owner: j['owner'],
        repo: j['repo'],
        accountId: j['accountId'],
        refreshIntervalSeconds: j['refreshIntervalSeconds'],
      );

  Map<String, dynamic> _workSessionToJson(WorkSession s) => {
    'id': s.id,
    'taskId': s.taskId,
    'projectId': s.projectId,
    'startedAt': s.startedAt.toIso8601String(),
    'endedAt': s.endedAt?.toIso8601String(),
  };

  WorkSession _workSessionFromJson(Map<String, dynamic> j) => WorkSession(
    id: j['id'],
    taskId: j['taskId'],
    projectId: j['projectId'],
    startedAt: DateTime.parse(j['startedAt']),
    endedAt: j['endedAt'] != null ? DateTime.parse(j['endedAt']) : null,
  );

  Map<String, dynamic> _rssFeedToJson(RssFeed f) => {
    'id': f.id,
    'url': f.url,
    'title': f.title,
    'description': f.description,
    'category': f.category,
    'addedAt': f.addedAt.toIso8601String(),
    'lastFetchedAt': f.lastFetchedAt?.toIso8601String(),
    'colorIndex': f.colorIndex,
  };

  RssFeed _rssFeedFromJson(Map<String, dynamic> j) => RssFeed(
    id: j['id'],
    url: j['url'],
    title: j['title'],
    description: j['description'],
    category: j['category'],
    addedAt: DateTime.parse(j['addedAt']),
    lastFetchedAt: j['lastFetchedAt'] != null
        ? DateTime.parse(j['lastFetchedAt'])
        : null,
    colorIndex: j['colorIndex'],
  );

  Map<String, dynamic> _rssArticleToJson(RssArticle a) => {
    'id': a.id,
    'feedId': a.feedId,
    'title': a.title,
    'description': a.description,
    'link': a.link,
    'publishedAt': a.publishedAt?.toIso8601String(),
    'isRead': a.isRead,
    'author': a.author,
    'fetchedAt': a.fetchedAt.toIso8601String(),
  };

  RssArticle _rssArticleFromJson(Map<String, dynamic> j) => RssArticle(
    id: j['id'],
    feedId: j['feedId'],
    title: j['title'],
    description: j['description'],
    link: j['link'],
    publishedAt: j['publishedAt'] != null
        ? DateTime.parse(j['publishedAt'])
        : null,
    isRead: j['isRead'],
    author: j['author'],
    fetchedAt: DateTime.parse(j['fetchedAt']),
  );

  Map<String, dynamic> _rssPrefsToJson(RssPreferences p) => {
    'autoRefreshEnabled': p.autoRefreshEnabled,
    'autoRefreshMinutes': p.autoRefreshMinutes,
    'autoCleanupEnabled': p.autoCleanupEnabled,
    'cleanupDays': p.cleanupDays,
    'splitViewMode': p.splitViewMode,
  };

  RssPreferences _rssPrefsFromJson(Map<String, dynamic> j) => RssPreferences(
    autoRefreshEnabled: j['autoRefreshEnabled'],
    autoRefreshMinutes: j['autoRefreshMinutes'],
    autoCleanupEnabled: j['autoCleanupEnabled'],
    cleanupDays: j['cleanupDays'],
    splitViewMode: j['splitViewMode'],
  );
}
