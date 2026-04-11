import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
import 'package:opendevnote/app.dart';
import 'package:opendevnote/services/notification_service.dart';
import 'package:opendevnote/services/syntax_highlighter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(TodoItemAdapter());
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(EventAdapter());
  Hive.registerAdapter(CodeSnippetAdapter());
  Hive.registerAdapter(GithubRepoConfigAdapter());
  Hive.registerAdapter(GithubAccountAdapter());
  Hive.registerAdapter(WorkSessionAdapter());
  Hive.registerAdapter(RssFeedAdapter());
  Hive.registerAdapter(RssArticleAdapter());
  Hive.registerAdapter(RssPreferencesAdapter());
  Hive.registerAdapter(CachedGithubDataAdapter());

  await Hive.openBox<Project>('projects');
  await Hive.openBox<TodoItem>('todos');
  await Hive.openBox<Note>('notes');
  await Hive.openBox<Event>('events');
  await Hive.openBox<CodeSnippet>('snippets');
  await Hive.openBox<GithubRepoConfig>('github_repos');
  await Hive.openBox<GithubAccount>('github_accounts');
  await Hive.openBox('starred_repos');
  await Hive.openBox<WorkSession>('work_sessions');
  await Hive.openBox<RssFeed>('rss_feeds');
  await Hive.openBox<RssArticle>('rss_articles');
  await Hive.openBox<RssPreferences>('rss_prefs');
  await Hive.openBox<CachedGithubData>('github_cache');
  await Hive.openBox('settings');

  await SyntaxHighlighter.loadDefinitions();
  await NotificationService().init();

  runApp(const ProviderScope(child: OpenDevNoteApp()));
}
