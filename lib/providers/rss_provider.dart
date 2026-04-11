import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:opendevnote/models/rss_feed.dart';
import 'package:opendevnote/models/rss_article.dart';
import 'package:opendevnote/models/rss_preferences.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:opendevnote/services/rss_service.dart';

const _uuid = Uuid();

// ── Feeds ──

final rssFeedsProvider = StateNotifierProvider<RssFeedsNotifier, List<RssFeed>>(
  (ref) {
    final storage = ref.watch(storageServiceProvider);
    return RssFeedsNotifier(storage.getAllRssFeeds(), storage, ref);
  },
);

class RssFeedsNotifier extends StateNotifier<List<RssFeed>> {
  final dynamic _storage;
  final Ref _ref;

  RssFeedsNotifier(super.feeds, this._storage, this._ref);

  Future<void> addFeed(String url, {String? category}) async {
    final data = await RssService.fetchFeed(url);
    final feed = RssFeed(
      id: _uuid.v4(),
      url: url,
      title: data.title,
      description: data.description,
      category: category?.isNotEmpty == true ? category : null,
    );
    await _storage.saveRssFeed(feed);

    for (final article in data.articles) {
      article.feedId = feed.id;
      await _storage.saveRssArticle(article);
    }

    _ref.read(rssArticlesProvider.notifier).reload();
    state = [...state, feed];
  }

  Future<void> deleteFeed(String feedId) async {
    await _storage.deleteRssFeed(feedId);
    _ref.read(rssArticlesProvider.notifier).reload();
    state = state.where((f) => f.id != feedId).toList();
  }

  Future<void> updateFeed(RssFeed feed) async {
    await _storage.saveRssFeed(feed);
    state = [
      for (final f in state)
        if (f.id == feed.id) feed else f,
    ];
  }

  Future<void> refreshFeed(String feedId) async {
    final feed = state.firstWhere((f) => f.id == feedId);
    final data = await RssService.fetchFeed(feed.url);

    final existingArticles = _storage.getArticlesForFeed(feedId);
    final existingIds = existingArticles.map((a) => a.id).toSet();

    for (final article in data.articles) {
      article.feedId = feedId;
      if (!existingIds.contains(article.id)) {
        await _storage.saveRssArticle(article);
      }
    }

    feed.lastFetchedAt = DateTime.now();
    feed.title = data.title;
    feed.description = data.description;
    await _storage.saveRssFeed(feed);
    _ref.read(rssArticlesProvider.notifier).reload();
    state = [...state];
  }

  Future<void> refreshAllFeeds() async {
    for (final feed in state) {
      try {
        await refreshFeed(feed.id);
      } catch (_) {}
    }
  }
}

// ── Articles ──

final rssArticlesProvider =
    StateNotifierProvider<RssArticlesNotifier, List<RssArticle>>((ref) {
      final storage = ref.watch(storageServiceProvider);
      return RssArticlesNotifier(storage.getAllRssArticles(), storage);
    });

class RssArticlesNotifier extends StateNotifier<List<RssArticle>> {
  final dynamic _storage;

  RssArticlesNotifier(super.articles, this._storage);

  void reload() {
    state = _storage.getAllRssArticles();
  }

  Future<void> markAsRead(String articleId) async {
    final article = state.firstWhere((a) => a.id == articleId);
    article.isRead = true;
    await _storage.saveRssArticle(article);
    state = [...state];
  }

  Future<void> markAsUnread(String articleId) async {
    final article = state.firstWhere((a) => a.id == articleId);
    article.isRead = false;
    await _storage.saveRssArticle(article);
    state = [...state];
  }

  Future<void> markAllAsRead(String feedId) async {
    for (final article in state) {
      if (article.feedId == feedId && !article.isRead) {
        article.isRead = true;
        await _storage.saveRssArticle(article);
      }
    }
    state = [...state];
  }
}

// ── Selected Feed ──

final selectedRssFeedIdProvider = StateProvider<String?>((ref) => null);

// ── Filtered Articles ──

final filteredRssArticlesProvider = Provider<List<RssArticle>>((ref) {
  final articles = ref.watch(rssArticlesProvider);
  final selectedFeedId = ref.watch(selectedRssFeedIdProvider);

  if (selectedFeedId == null) return articles;
  return articles.where((a) => a.feedId == selectedFeedId).toList();
});

// ── Unread Counts ──

final rssUnreadCountsProvider = Provider<Map<String, int>>((ref) {
  final articles = ref.watch(rssArticlesProvider);
  final counts = <String, int>{};
  for (final a in articles) {
    if (!a.isRead) {
      counts[a.feedId] = (counts[a.feedId] ?? 0) + 1;
    }
  }
  return counts;
});

final totalRssUnreadProvider = Provider<int>((ref) {
  final articles = ref.watch(rssArticlesProvider);
  return articles.where((a) => !a.isRead).length;
});

// ── Preferences ──

final rssPrefsProvider =
    StateNotifierProvider<RssPrefsNotifier, RssPreferences>((ref) {
      final storage = ref.watch(storageServiceProvider);
      return RssPrefsNotifier(storage.getRssPreferences(), storage, ref);
    });

class RssPrefsNotifier extends StateNotifier<RssPreferences> {
  final dynamic _storage;
  final Ref _ref;
  Timer? _autoRefreshTimer;

  RssPrefsNotifier(super.prefs, this._storage, this._ref) {
    _setupAutoRefresh();
  }

  void update({
    bool? autoRefreshEnabled,
    int? autoRefreshMinutes,
    bool? autoCleanupEnabled,
    int? cleanupDays,
    bool? splitViewMode,
  }) {
    state.autoRefreshEnabled = autoRefreshEnabled ?? state.autoRefreshEnabled;
    state.autoRefreshMinutes = autoRefreshMinutes ?? state.autoRefreshMinutes;
    state.autoCleanupEnabled = autoCleanupEnabled ?? state.autoCleanupEnabled;
    state.cleanupDays = cleanupDays ?? state.cleanupDays;
    state.splitViewMode = splitViewMode ?? state.splitViewMode;

    _storage.saveRssPreferences(state);
    state = RssPreferences(
      autoRefreshEnabled: state.autoRefreshEnabled,
      autoRefreshMinutes: state.autoRefreshMinutes,
      autoCleanupEnabled: state.autoCleanupEnabled,
      cleanupDays: state.cleanupDays,
      splitViewMode: state.splitViewMode,
    );
    _setupAutoRefresh();
  }

  void _setupAutoRefresh() {
    _autoRefreshTimer?.cancel();
    if (state.autoRefreshEnabled && state.autoRefreshMinutes >= 5) {
      _autoRefreshTimer = Timer.periodic(
        Duration(minutes: state.autoRefreshMinutes),
        (_) {
          try {
            _ref.read(rssFeedsProvider.notifier).refreshAllFeeds();
            if (state.autoCleanupEnabled) {
              _storage.cleanupOldArticles(state.cleanupDays);
            }
          } catch (_) {}
        },
      );
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }
}

// ── Loading State ──

final rssLoadingProvider = StateProvider<bool>((ref) => false);
