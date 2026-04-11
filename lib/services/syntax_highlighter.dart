import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SyntaxDefinition {
  final String language;
  final String displayName;
  final List<String> keywords;
  final List<String> types;
  final List<String> builtIns;

  const SyntaxDefinition({
    required this.language,
    required this.displayName,
    required this.keywords,
    required this.types,
    required this.builtIns,
  });

  factory SyntaxDefinition.fromJson(Map<String, dynamic> json) {
    return SyntaxDefinition(
      language: json['language'] as String,
      displayName: json['displayName'] as String,
      keywords: List<String>.from(json['keywords'] as List),
      types: List<String>.from(json['types'] as List),
      builtIns: List<String>.from(json['builtIns'] as List),
    );
  }
}

class SyntaxHighlighter {
  static final Map<String, SyntaxDefinition> _definitions = {};
  static bool _loaded = false;

  static bool get isLoaded => _loaded;

  static Future<void> loadDefinitions() async {
    if (_loaded) return;

    const languages = ['c', 'cpp', 'csharp', 'java', 'dart'];

    for (final lang in languages) {
      try {
        final jsonStr = await rootBundle.loadString('assets/syntax/syntax_$lang.json');
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        _definitions[lang] = SyntaxDefinition.fromJson(json);
      } catch (e) {
        debugPrint('Failed to load syntax for $lang: $e');
      }
    }

    _loaded = true;
  }

  static SyntaxDefinition? getDefinition(String language) {
    return _definitions[language];
  }

  static List<String> getAvailableLanguages() {
    return _definitions.keys.toList();
  }

  static bool _isDarkMode() {
    return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
  }

  static Map<String, TextStyle> getStringMap(String language) {
    final def = _definitions[language];
    if (def == null) return {};

    final isDark = _isDarkMode();

    final map = <String, TextStyle>{};

    final keywordStyle = TextStyle(
      color: isDark ? const Color(0xFFC792EA) : const Color(0xFF7C3AED),
      fontWeight: FontWeight.w600,
    );

    final typeStyle = TextStyle(
      color: isDark ? const Color(0xFF82AAFF) : const Color(0xFF3B82F6),
    );

    final builtInStyle = TextStyle(
      color: isDark ? const Color(0xFF89DDFF) : const Color(0xFF14B8A6),
    );

    for (final kw in def.keywords) {
      map[kw] = keywordStyle;
    }
    for (final t in def.types) {
      map[t] = typeStyle;
    }
    for (final b in def.builtIns) {
      map[b] = builtInStyle;
    }

    return map;
  }

  static Map<String, TextStyle> getPatternMap() {
    final isDark = _isDarkMode();

    return {
      r'//.*$': TextStyle(
        color: Colors.grey.withValues(alpha: 0.6),
        fontStyle: FontStyle.italic,
      ),
      r'/\*[\s\S]*?\*/': TextStyle(
        color: Colors.grey.withValues(alpha: 0.6),
        fontStyle: FontStyle.italic,
      ),
      r'"(?:[^"\\]|\\.)*"': TextStyle(
        color: isDark ? const Color(0xFFC3E88D) : const Color(0xFF22C55E),
      ),
      r"'(?:[^'\\]|\\.)*'": TextStyle(
        color: isDark ? const Color(0xFFC3E88D) : const Color(0xFF22C55E),
      ),
      r'\b\d+(?:\.\d+)?(?:[eE][+-]?\d+)?[fFlLuU]*\b': TextStyle(
        color: isDark ? const Color(0xFFF78C6C) : const Color(0xFFF97316),
      ),
    };
  }
}
