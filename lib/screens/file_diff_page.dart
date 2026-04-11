import 'package:flutter/material.dart';

class FileDiffPage extends StatelessWidget {
  final String filename;
  final String patch;
  final String status;
  final int additions;
  final int deletions;

  const FileDiffPage({
    super.key,
    required this.filename,
    required this.patch,
    required this.status,
    required this.additions,
    required this.deletions,
  });

  @override
  Widget build(BuildContext context) {
    final lines = _parsePatch(patch);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          filename,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
        actions: [
          _StatusChip(status: status),
          const SizedBox(width: 8),
          Text(
            '+$additions',
            style: const TextStyle(color: Colors.green, fontSize: 13),
          ),
          const SizedBox(width: 4),
          Text(
            '-$deletions',
            style: const TextStyle(color: Colors.red, fontSize: 13),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView.builder(
        itemCount: lines.length,
        itemBuilder: (context, index) => _DiffLineWidget(line: lines[index]),
      ),
    );
  }

  List<_DiffLine> _parsePatch(String patch) {
    final result = <_DiffLine>[];
    final rawLines = patch.split('\n');
    int oldLine = 0;
    int newLine = 0;

    for (final raw in rawLines) {
      if (raw.startsWith('@@')) {
        // Parse hunk header: @@ -oldStart,oldCount +newStart,newCount @@
        final match = RegExp(
          r'@@ -(\d+)(?:,\d+)? \+(\d+)(?:,\d+)? @@(.*)',
        ).firstMatch(raw);
        if (match != null) {
          oldLine = int.parse(match.group(1)!);
          newLine = int.parse(match.group(2)!);
          result.add(_DiffLine(type: _DiffLineType.hunk, text: raw));
        } else {
          result.add(_DiffLine(type: _DiffLineType.hunk, text: raw));
        }
      } else if (raw.startsWith('+') && !raw.startsWith('+++')) {
        result.add(
          _DiffLine(
            type: _DiffLineType.add,
            text: raw.substring(1),
            newLineNum: newLine++,
          ),
        );
      } else if (raw.startsWith('-') && !raw.startsWith('---')) {
        result.add(
          _DiffLine(
            type: _DiffLineType.remove,
            text: raw.substring(1),
            oldLineNum: oldLine++,
          ),
        );
      } else if (raw.startsWith('+++') || raw.startsWith('---')) {
        // Skip file headers
      } else {
        result.add(
          _DiffLine(
            type: _DiffLineType.context,
            text: raw,
            oldLineNum: oldLine++,
            newLineNum: newLine++,
          ),
        );
      }
    }

    return result;
  }
}

enum _DiffLineType { add, remove, context, hunk }

class _DiffLine {
  final _DiffLineType type;
  final String text;
  final int? oldLineNum;
  final int? newLineNum;

  _DiffLine({
    required this.type,
    required this.text,
    this.oldLineNum,
    this.newLineNum,
  });
}

class _DiffLineWidget extends StatelessWidget {
  final _DiffLine line;

  const _DiffLineWidget({required this.line});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (line.type == _DiffLineType.hunk) {
      return Container(
        color: colorScheme.primaryContainer.withValues(alpha: 0.15),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Row(
          children: [
            const SizedBox(width: 60),
            const SizedBox(width: 60),
            Expanded(
              child: Text(
                line.text,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Color bgColor;
    Color textColor;
    String prefix;

    switch (line.type) {
      case _DiffLineType.add:
        bgColor = Colors.green.withValues(alpha: 0.08);
        textColor = const Color(0xFF22863A);
        prefix = '+';
        break;
      case _DiffLineType.remove:
        bgColor = Colors.red.withValues(alpha: 0.1);
        textColor = const Color(0xFFCB2431);
        prefix = '-';
        break;
      case _DiffLineType.context:
        bgColor = Colors.transparent;
        textColor = colorScheme.onSurface.withValues(alpha: 0.7);
        prefix = ' ';
        break;
      case _DiffLineType.hunk:
        return const SizedBox.shrink();
    }

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Old line number
          SizedBox(
            width: 48,
            child: Text(
              line.oldLineNum?.toString() ?? '',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // New line number
          SizedBox(
            width: 48,
            child: Text(
              line.newLineNum?.toString() ?? '',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Prefix
          SizedBox(
            width: 16,
            child: Text(
              prefix,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: textColor,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Content
          Expanded(
            child: SelectableText(
              line.text,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'added':
        color = Colors.green;
        label = 'Added';
        break;
      case 'removed':
        color = Colors.red;
        label = 'Removed';
        break;
      case 'modified':
        color = Colors.orange;
        label = 'Modified';
        break;
      case 'renamed':
        color = Colors.blue;
        label = 'Renamed';
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
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
