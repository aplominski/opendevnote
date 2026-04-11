import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    required this.onChanged,
    this.hintText = 'Szukaj...',
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              Icons.search,
              size: 16,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 24,
            minHeight: 24,
          ),
          isDense: true,
        ),
      ),
    );
  }
}
