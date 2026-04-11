import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/project.dart';
import 'package:opendevnote/providers/todo_provider.dart';
import 'package:opendevnote/theme/app_colors.dart';

class ProjectCard extends ConsumerWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.getColor(project.colorIndex);
    final icon = AppColors.getIcon(project.iconIndex);
    final stats = ref.watch(projectStatsProvider(project.id));
    final total = stats['total']!;
    final completed = stats['completed']!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        hoverColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Hero(
                tag: 'project_icon_${project.id}',
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.tags.isNotEmpty)
                      Text(
                        project.tags.join(', '),
                        style: textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (total > 0) ...[
                const SizedBox(width: 12),
                Text(
                  '$completed/$total',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
