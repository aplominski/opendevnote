import 'package:opendevnote/services/syntax_highlighter.dart';

class LanguageDetector {
  static const Map<String, List<String>> _languagePatterns = {
    'c': ['#include\\s*<', 'printf\\s*\\(', 'scanf\\s*\\(', 'malloc\\s*\\(', 'int\\s+main\\s*\\('],
    'cpp': ['#include\\s*<iostream>', 'std::', 'cout\\s*<<', 'cin\\s*>>', 'class\\s+\\w+\\s*{', 'namespace\\s+'],
    'csharp': ['using\\s+System', 'Console\\.', 'namespace\\s+\\w+\\s*{', 'public\\s+class\\s+', 'void\\s+Main\\s*\\('],
    'java': ['public\\s+static\\s+void\\s+main', 'System\\.out\\.', 'import\\s+java\\.', 'package\\s+\\w+\\s*;'],
    'dart': ['import\\s+[\'"]dart:', 'void\\s+main\\s*\\(', 'Future\\s*<', 'async\\s*{', 'await\\s+'],
  };

  static String? detect(String code) {
    if (code.isEmpty) return null;

    final scores = <String, int>{};

    for (final entry in _languagePatterns.entries) {
      int score = 0;
      for (final pattern in entry.value) {
        if (RegExp(pattern).hasMatch(code)) {
          score += 10;
        }
      }
      if (score > 0) {
        scores[entry.key] = score;
      }
    }

    if (scores.isEmpty) return null;

    var bestLanguage = scores.entries.first.key;
    var bestScore = scores.entries.first.value;

    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestLanguage = entry.key;
      }
    }

    return bestLanguage;
  }

  static String detectWithDefault(String code, String defaultLanguage) {
    return detect(code) ?? defaultLanguage;
  }

  static String? detectFromCode(String code) {
    if (code.isEmpty) return null;

    if (code.contains('#include')) {
      if (code.contains('<iostream>') || code.contains('std::') || code.contains('class ') && code.contains('public:')) {
        return 'cpp';
      }
      return 'c';
    }

    if (code.contains('using System') || code.contains('Console.') || code.contains('namespace ') && !code.contains('std::')) {
      return 'csharp';
    }

    if (code.contains('public static void main') || code.contains('System.out.') || code.contains('import java.')) {
      return 'java';
    }

    if (code.contains('import \'dart:') || code.contains('void main()') || code.contains('Future<') || code.contains('async')) {
      return 'dart';
    }

    return null;
  }
}
