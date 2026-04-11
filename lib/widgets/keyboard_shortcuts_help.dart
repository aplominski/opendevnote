import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardShortcutsHelp extends StatelessWidget {
  const KeyboardShortcutsHelp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.transparent),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.all(32),
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.keyboard, color: colorScheme.primary),
                        const SizedBox(width: 12),
                        Text('Skróty klawiszowe', style: textTheme.titleLarge),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _ShortcutRow(
                          keys: 'Ctrl + N',
                          description: 'Nowa notatka w aktualnym projekcie',
                        ),
                        const SizedBox(height: 12),
                        _ShortcutRow(
                          keys: 'Ctrl + T',
                          description: 'Nowe zadanie w aktualnym projekcie',
                        ),
                        const SizedBox(height: 12),
                        _ShortcutRow(
                          keys: 'Ctrl + /',
                          description: 'Pokaż/ukryj pomoc skrótów',
                        ),
                        const SizedBox(height: 12),
              _ShortcutRow(
                keys: 'Ctrl + P',
                description: 'Wyszukaj notatki (command bar)',
              ),
              const SizedBox(height: 12),
              _ShortcutRow(
                keys: 'Ctrl + E',
                description: 'Nowe wydarzenie w kalendarzu',
              ),
              const SizedBox(height: 12),
              _ShortcutRow(
                keys: 'Ctrl + Scroll',
                description: 'Przybliż/oddal widok kalendarza',
              ),
              const SizedBox(height: 12),
              _ShortcutRow(
                keys: '← / →',
                description: 'Nawigacja miesiąc / tydzień',
              ),
              const SizedBox(height: 12),
              _ShortcutRow(
                keys: 'Ctrl + ← / →',
                description: 'Nawigacja dzień',
              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  final String keys;
  final String description;

  const _ShortcutRow({required this.keys, required this.description});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Text(
            keys,
            style: textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(description, style: textTheme.bodyMedium)),
      ],
    );
  }
}
