import 'package:flutter/material.dart';

class LanguageIcons {
  static const Map<String, IconData> icons = {
    'c': Icons.memory_outlined,
    'cpp': Icons.developer_board_outlined,
    'csharp': Icons.widgets_outlined,
    'java': Icons.local_cafe_outlined,
    'dart': Icons.sports_bar_outlined,
  };

  static const Map<String, String> displayNames = {
    'c': 'C',
    'cpp': 'C++',
    'csharp': 'C#',
    'java': 'Java',
    'dart': 'Dart',
  };

  static IconData getIcon(String language) {
    return icons[language] ?? Icons.code_outlined;
  }

  static String getDisplayName(String language) {
    return displayNames[language] ?? language.toUpperCase();
  }
}

class LanguageColors {
  static const Map<String, int> colorValues = {
    'c': 0xFF3498DB,
    'cpp': 0xFF9B59B6,
    'csharp': 0xFF9B4DCA,
    'java': 0xFFF39C12,
    'dart': 0xFF0175C2,
  };

  static Color getColor(String language) {
    return Color(colorValues[language] ?? 0xFF6B7280);
  }
}
