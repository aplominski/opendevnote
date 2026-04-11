import 'package:flutter/material.dart';

class AppBreadcrumb extends StatelessWidget {
  final List<String> items;
  final List<VoidCallback?> onTap;

  const AppBreadcrumb({super.key, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '/',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
            GestureDetector(
              onTap: onTap[i],
              child: MouseRegion(
                cursor: onTap[i] != null
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
                child: Text(
                  items[i],
                  style: textTheme.bodyMedium?.copyWith(
                    color: i == items.length - 1
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                    fontWeight: i == items.length - 1
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
