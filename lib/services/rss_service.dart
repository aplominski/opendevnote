import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:opendevnote/models/rss_article.dart';

class RssService {
  static const _timeout = Duration(seconds: 15);

  static Future<RssFeedData> fetchFeed(String url) async {
    final uri = Uri.parse(url);
    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final body = utf8.decode(response.bodyBytes);
    final doc = XmlDocument.parse(body);

    final root = doc.rootElement;
    final rootName = root.name.local.toLowerCase();

    if (rootName == 'rss') {
      return _parseRss(root, url);
    } else if (rootName == 'feed') {
      return _parseAtom(root, url);
    } else if (rootName == 'rdf' || rootName == 'rdf:rdf') {
      return _parseRss1(root, url);
    }

    throw Exception('Unknown feed format');
  }

  static RssFeedData _parseRss(XmlElement root, String url) {
    final channel = root.findElements('channel').firstOrNull;
    if (channel == null) throw Exception('No channel element');

    final title = channel.findElements('title').firstOrNull?.innerText ?? url;
    final description = channel
        .findElements('description')
        .firstOrNull
        ?.innerText;

    final items = channel.findElements('item');
    final articles = items.map((item) {
      final itemTitle = item.findElements('title').firstOrNull?.innerText ?? '';
      final link = item.findElements('link').firstOrNull?.innerText ?? '';
      final desc = item.findElements('description').firstOrNull?.innerText;
      final pubDate = item.findElements('pubDate').firstOrNull?.innerText;
      final author =
          item.findElements('author').firstOrNull?.innerText ??
          item.findElements('dc:creator').firstOrNull?.innerText;
      final guid = item.findElements('guid').firstOrNull?.innerText;

      final id = guid ?? link;
      final parsedDate = _parseDate(pubDate);

      return RssArticle(
        id: id.hashCode.toRadixString(16),
        feedId: '',
        title: itemTitle,
        description: _stripHtml(desc),
        link: link,
        publishedAt: parsedDate,
        author: author,
      );
    }).toList();

    return RssFeedData(
      title: title,
      description: description,
      articles: articles,
    );
  }

  static RssFeedData _parseAtom(XmlElement root, String url) {
    final title = root.findElements('title').firstOrNull?.innerText ?? url;
    final subtitle = root.findElements('subtitle').firstOrNull?.innerText;

    final entries = root.findElements('entry');
    final articles = entries.map((entry) {
      final itemTitle =
          entry.findElements('title').firstOrNull?.innerText ?? '';
      final linkEl = entry
          .findElements('link')
          .where((e) => e.getAttribute('rel') != 'enclosure')
          .firstOrNull;
      final link = linkEl?.getAttribute('href') ?? '';
      final desc =
          entry.findElements('content').firstOrNull?.innerText ??
          entry.findElements('summary').firstOrNull?.innerText;
      final updated = entry.findElements('updated').firstOrNull?.innerText;
      final author =
          entry.findElements('author').firstOrNull?.innerText ??
          entry
              .findElements('author')
              .firstOrNull
              ?.findElements('name')
              .firstOrNull
              ?.innerText;
      final id = entry.findElements('id').firstOrNull?.innerText ?? link;
      final parsedDate = _parseDate(updated);

      return RssArticle(
        id: id.hashCode.toRadixString(16),
        feedId: '',
        title: itemTitle,
        description: _stripHtml(desc),
        link: link,
        publishedAt: parsedDate,
        author: author,
      );
    }).toList();

    return RssFeedData(title: title, description: subtitle, articles: articles);
  }

  static RssFeedData _parseRss1(XmlElement root, String url) {
    final channel = root.findElements('channel').firstOrNull;
    final title = channel?.findElements('title').firstOrNull?.innerText ?? url;
    final description = channel
        ?.findElements('description')
        .firstOrNull
        ?.innerText;

    final items = root.findElements('item');
    final articles = items.map((item) {
      final itemTitle = item.findElements('title').firstOrNull?.innerText ?? '';
      final link = item.findElements('link').firstOrNull?.innerText ?? '';
      final desc = item.findElements('description').firstOrNull?.innerText;
      final dcDate = item.findElements('dc:date').firstOrNull?.innerText;
      final author = item.findElements('dc:creator').firstOrNull?.innerText;
      final parsedDate = _parseDate(dcDate);

      return RssArticle(
        id: link.hashCode.toRadixString(16),
        feedId: '',
        title: itemTitle,
        description: _stripHtml(desc),
        link: link,
        publishedAt: parsedDate,
        author: author,
      );
    }).toList();

    return RssFeedData(
      title: title,
      description: description,
      articles: articles,
    );
  }

  static DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        final cleaned = dateStr.replaceFirst(RegExp(r'\s+\+\d{4}$'), '');
        return DateTime.parse(cleaned);
      } catch (_) {
        return null;
      }
    }
  }

  static String? _stripHtml(String? html) {
    if (html == null) return null;
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}

class RssFeedData {
  final String title;
  final String? description;
  final List<RssArticle> articles;

  RssFeedData({required this.title, this.description, required this.articles});
}
