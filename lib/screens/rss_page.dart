import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/rss_article.dart';
import 'package:opendevnote/models/rss_feed.dart';
import 'package:opendevnote/providers/rss_provider.dart';
import 'package:opendevnote/theme/app_colors.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';
import 'package:opendevnote/screens/dialogs/add_rss_feed_dialog.dart';
import 'package:opendevnote/screens/dialogs/rss_settings_dialog.dart';

class RssPage extends ConsumerWidget {
  const RssPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(rssPrefsProvider);

    if (prefs.splitViewMode) {
      return const _SplitView();
    }
    return const _ListViewOnly();
  }
}

class _SplitView extends ConsumerWidget {
  const _SplitView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final feeds = ref.watch(rssFeedsProvider);
    final selectedFeedId = ref.watch(selectedRssFeedIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', l10n.navigationNews],
          onTap: [null, null],
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: Column(
                  children: [
                    _FeedListItem(
                      icon: Icons.all_inbox_outlined,
                      label: l10n.statusAll,
                      unreadCount: ref.watch(totalRssUnreadProvider),
                      isSelected: selectedFeedId == null,
                      onTap: () =>
                          ref.read(selectedRssFeedIdProvider.notifier).state =
                              null,
                    ),
                    const Divider(height: 0.5),
                    Expanded(
                      child: feeds.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  l10n.emptyStateNoFeeds,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: feeds.length,
                              itemBuilder: (context, index) {
                                final feed = feeds[index];
                                final unread =
                                    ref.watch(
                                      rssUnreadCountsProvider,
                                    )[feed.id] ??
                                    0;
                                return _FeedListItem(
                                  icon: Icons.rss_feed,
                                  label: feed.title,
                                  unreadCount: unread,
                                  color: AppColors.getColor(feed.colorIndex),
                                  isSelected: selectedFeedId == feed.id,
                                  onTap: () =>
                                      ref
                                          .read(
                                            selectedRssFeedIdProvider.notifier,
                                          )
                                          .state = feed
                                          .id,
                                  onLongPress: () =>
                                      _showFeedOptions(context, ref, feed),
                                );
                              },
                            ),
                    ),
                    const Divider(height: 0.5),
                    _FeedListItem(
                      icon: Icons.add,
                      label: l10n.tooltipAddFeed,
                      unreadCount: 0,
                      isSelected: false,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const AddRssFeedDialog(),
                      ),
                    ),
                    _FeedListItem(
                      icon: Icons.settings_outlined,
                      label: l10n.tooltipSettings,
                      unreadCount: 0,
                      isSelected: false,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const RssSettingsDialog(),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              VerticalDivider(
                width: 0.5,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(child: _ArticlesList(feedId: selectedFeedId)),
            ],
          ),
        ),
      ],
    );
  }

  void _showFeedOptions(BuildContext context, WidgetRef ref, RssFeed feed) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.refresh, color: colorScheme.primary),
              title: Text(l10n.tooltipRefresh),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(rssFeedsProvider.notifier).refreshFeed(feed.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.done_all, color: colorScheme.primary),
              title: Text(l10n.menuMarkAllRead),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(rssArticlesProvider.notifier).markAllAsRead(feed.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_outlined, color: colorScheme.primary),
              title: Text(l10n.menuChangeCategory),
              onTap: () {
                Navigator.pop(ctx);
                _showCategoryEdit(context, ref, feed);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: colorScheme.error),
              title: Text(
                l10n.menuDeleteFeed,
                style: TextStyle(color: colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(rssFeedsProvider.notifier).deleteFeed(feed.id);
                if (ref.read(selectedRssFeedIdProvider) == feed.id) {
                  ref.read(selectedRssFeedIdProvider.notifier).state = null;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryEdit(BuildContext context, WidgetRef ref, RssFeed feed) {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: feed.category ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.labelCategory),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.dialogCategoryName,
            hintText: 'Tech, Sport...',
          ),
          onSubmitted: (_) {
            feed.category = controller.text.trim().isNotEmpty
                ? controller.text.trim()
                : null;
            ref.read(rssFeedsProvider.notifier).updateFeed(feed);
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () {
              feed.category = controller.text.trim().isNotEmpty
                  ? controller.text.trim()
                  : null;
              ref.read(rssFeedsProvider.notifier).updateFeed(feed);
              Navigator.pop(ctx);
            },
            child: Text(l10n.buttonSave),
          ),
        ],
      ),
    );
  }
}

class _ListViewOnly extends ConsumerWidget {
  const _ListViewOnly();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', l10n.navigationNews],
          onTap: [null, null],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                tooltip: l10n.tooltipRefreshAll,
                onPressed: () {
                  ref.read(rssFeedsProvider.notifier).refreshAllFeeds();
                },
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                tooltip: l10n.tooltipAddFeed,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const AddRssFeedDialog(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 18),
                tooltip: l10n.tooltipSettings,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => const RssSettingsDialog(),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _ArticlesList(feedId: null)),
      ],
    );
  }
}

class _ArticlesList extends ConsumerWidget {
  final String? feedId;

  const _ArticlesList({this.feedId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final feeds = ref.watch(rssFeedsProvider);

    List<RssArticle> articles;
    if (feedId != null) {
      articles = ref
          .watch(rssArticlesProvider)
          .where((a) => a.feedId == feedId)
          .toList();
    } else {
      articles = ref.watch(rssArticlesProvider);
    }

    if (articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rss_feed_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 12),
            Text(
              feedId != null
                  ? l10n.emptyStateNoArticlesInFeed
                  : l10n.emptyStateNoArticles,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        final feedName = _getFeedName(feeds, article.feedId);
        return _ArticleTile(
          article: article,
          feedName: feedName,
          onTap: () async {
            if (!article.isRead) {
              ref.read(rssArticlesProvider.notifier).markAsRead(article.id);
            }
            final uri = Uri.tryParse(article.link);
            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          onLongPress: () => _showArticleOptions(context, ref, article),
        );
      },
    );
  }

  String _getFeedName(List<RssFeed> feeds, String feedId) {
    try {
      return feeds.firstWhere((f) => f.id == feedId).title;
    } catch (_) {
      return '';
    }
  }

  void _showArticleOptions(
    BuildContext context,
    WidgetRef ref,
    RssArticle article,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                article.isRead
                    ? Icons.mark_email_unread_outlined
                    : Icons.mark_email_read_outlined,
                color: colorScheme.primary,
              ),
              title: Text(
                article.isRead ? l10n.menuMarkAsUnread : l10n.menuMarkAsRead,
              ),
              onTap: () {
                Navigator.pop(ctx);
                if (article.isRead) {
                  ref
                      .read(rssArticlesProvider.notifier)
                      .markAsUnread(article.id);
                } else {
                  ref.read(rssArticlesProvider.notifier).markAsRead(article.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedListItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int unreadCount;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _FeedListItem({
    required this.icon,
    required this.label,
    required this.unreadCount,
    required this.isSelected,
    this.color,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.transparent,
        child: Row(
          children: [
            if (color != null)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              )
            else
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
            SizedBox(width: color != null ? 0 : 8),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final RssArticle article;
  final String feedName;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ArticleTile({
    required this.article,
    required this.feedName,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    article.title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: article.isRead
                          ? FontWeight.w400
                          : FontWeight.w600,
                      color: article.isRead
                          ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                          : colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(article.publishedAt, l10n),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            if (article.description != null &&
                article.description!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                article.description!,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (feedName.isNotEmpty || article.author != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (feedName.isNotEmpty)
                    Text(
                      feedName,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.35,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  if (feedName.isNotEmpty && article.author != null)
                    Text(
                      ' · ',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.35,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  if (article.author != null)
                    Expanded(
                      child: Text(
                        article.author!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.35,
                          ),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? date, AppLocalizations l10n) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (diff == 1) return l10n.timeYesterday;
    if (diff < 7) return l10n.timeDays(diff);
    return '${date.day}.${date.month.toString().padLeft(2, '0')}';
  }
}
