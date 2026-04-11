import 'package:flutter/material.dart';

class AppColors {
  static const List<Color> projectColors = [
    Color(0xFF7C3AED), // Purple (accent)
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFF22C55E), // Green
    Color(0xFF3B82F6), // Blue
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Violet
    Color(0xFF6366F1), // Indigo
  ];

  static const List<IconData> projectIcons = [
    Icons.folder_outlined,
    Icons.work_outline,
    Icons.home_outlined,
    Icons.school_outlined,
    Icons.fitness_center_outlined,
    Icons.shopping_cart_outlined,
    Icons.code_outlined,
    Icons.music_note_outlined,
    Icons.sports_soccer_outlined,
    Icons.restaurant_outlined,
    Icons.flight_outlined,
    Icons.favorite_outline,
    Icons.book_outlined,
    Icons.pets_outlined,
    Icons.sports_esports_outlined,
    Icons.movie_outlined,
  ];

  static Color getColor(int index) {
    return projectColors[index % projectColors.length];
  }

  static IconData getIcon(int index) {
    return projectIcons[index % projectIcons.length];
  }
}
