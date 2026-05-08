import 'package:flutter/material.dart';
import 'package:opendevnote/l10n/app_localizations.dart';

class FileDiffDialog extends StatelessWidget {
  final String filename;
  final String patch;
  final String status;
  final int additions;
  final int deletions;

  const FileDiffDialog({
    super.key,
    required this.filename,
    required this.patch,
    required this.status,
    required this.additions,
    required this.deletions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.code, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              filename,
              style: textTheme.titleSmall?.copyWith(fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 640,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats
              Row(
                children: [
                  _StatusChip(status: status),
                  const SizedBox(width: 8),
                  Text(
                    '+$additions',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '-$deletions',
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 8),
              // Patch
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _formatPatch(patch),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.buttonClose),
        ),
      ],
    );
  }

  String _formatPatch(String patch) {
    final lines = patch.split('\n');
    final buffer = StringBuffer();

    for (final line in lines) {
      if (line.startsWith('@@')) {
        // Hunk header
        buffer.writeln(line);
      } else if (line.startsWith('+') && !line.startsWith('+++')) {
        buffer.writeln(line);
      } else if (line.startsWith('-') && !line.startsWith('---')) {
        buffer.writeln(line);
      } else {
        buffer.writeln(line);
      }
    }

    return buffer.toString();
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Color color;
    String label;
    switch (status) {
      case 'added':
        color = Colors.green;
        label = 'Dodany';
        break;
      case 'removed':
        color = Colors.red;
        label = 'Usunięty';
        break;
      case 'modified':
        color = Colors.orange;
        label = 'Zmodyfikowany';
        break;
      case 'renamed':
        color = Colors.blue;
        label = 'Zmieniona nazwa';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
