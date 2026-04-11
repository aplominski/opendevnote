import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/note.dart';
import 'package:opendevnote/models/todo_item.dart';
import 'package:opendevnote/providers/note_provider.dart';
import 'package:opendevnote/providers/project_provider.dart';
import 'package:opendevnote/providers/todo_provider.dart';
import 'package:opendevnote/screens/note_editor_screen.dart';

class CommandBar extends ConsumerStatefulWidget {
  const CommandBar({super.key});

  @override
  ConsumerState<CommandBar> createState() => _CommandBarState();
}

class _CommandBarState extends ConsumerState<CommandBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<dynamic> _filteredItems = [];
  int _selectedIndex = 0;
  double _startY = 0;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterItems(List<Note> allNotes, List<TodoItem> allTodos) {
    final query = _searchController.text.toLowerCase();
    final items = <dynamic>[];

    for (final note in allNotes) {
      if (note.title.toLowerCase().contains(query) ||
          note.content.toLowerCase().contains(query)) {
        items.add({'type': 'note', 'item': note});
      }
    }

    for (final todo in allTodos) {
      if (todo.title.toLowerCase().contains(query)) {
        items.add({'type': 'todo', 'item': todo});
      }
    }

    setState(() {
      _filteredItems = items.take(15).toList();
      _selectedIndex = 0;
    });
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % _filteredItems.length;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          _selectedIndex =
              (_selectedIndex - 1 + _filteredItems.length) %
              _filteredItems.length;
        });
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_filteredItems.isNotEmpty) {
          _openItem(_filteredItems[_selectedIndex]);
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.pop(context);
      }
    }
  }

  void _openItem(dynamic item) {
    Navigator.pop(context);
    if (item['type'] == 'note') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NoteEditorScreen(note: item['item'] as Note),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    final projects = ref.watch(projectsProvider);
    final allNotes = <Note>[];
    final allTodos = <TodoItem>[];

    for (final project in projects) {
      allNotes.addAll(ref.watch(notesProvider(project.id)));
      allTodos.addAll(ref.watch(todosProvider(project.id)));
    }

    if (_searchController.text.isNotEmpty) {
      _filterItems(allNotes, allTodos);
    } else {
      setState(() {
        _filteredItems = [];
      });
    }

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              onPanStart: (details) => _startY = details.globalPosition.dy,
              onPanUpdate: (details) {
                final currentY = details.globalPosition.dy;
                if ((currentY - _startY).abs() > screenHeight * 0.25) {
                  Navigator.pop(context);
                }
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: screenHeight * 0.2,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Material(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Wyszukaj notatki i zadania...',
                              prefixIcon: Icon(
                                Icons.search,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              border: InputBorder.none,
                              hintStyle: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                              ),
                            ),
                            style: textTheme.bodyMedium,
                            onChanged: (_) => _filterItems(allNotes, allTodos),
                          ),
                        ),
                      ),
                      if (_filteredItems.isNotEmpty) ...[
                        const Divider(height: 1),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 250),
                          child: Material(
                            color: colorScheme.surface,
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final isNote = item['type'] == 'note';
                                final isSelected = index == _selectedIndex;
                                final title = isNote
                                    ? (item['item'] as Note).title
                                    : (item['item'] as TodoItem).title;
                                final isCompleted =
                                    !isNote &&
                                    (item['item'] as TodoItem).isCompleted;

                                return InkWell(
                                  onTap: () => _openItem(item),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    color: isSelected
                                        ? colorScheme.primaryContainer
                                              .withValues(alpha: 0.3)
                                        : Colors.transparent,
                                    child: Row(
                                      children: [
                                        Icon(
                                          isNote
                                              ? Icons.description_outlined
                                              : Icons.check_circle_outline,
                                          size: 14,
                                          color: isSelected
                                              ? colorScheme.primary
                                              : isCompleted
                                              ? colorScheme.onSurfaceVariant
                                                    .withValues(alpha: 0.5)
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  fontWeight: isSelected
                                                      ? FontWeight.w500
                                                      : FontWeight.w400,
                                                  color: isSelected
                                                      ? colorScheme.onSurface
                                                      : isCompleted
                                                      ? colorScheme
                                                            .onSurfaceVariant
                                                            .withValues(
                                                              alpha: 0.5,
                                                            )
                                                      : colorScheme
                                                            .onSurfaceVariant,
                                                  decoration: isCompleted
                                                      ? TextDecoration
                                                            .lineThrough
                                                      : null,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            isNote ? 'Notatka' : 'Zadanie',
                                            style: textTheme.bodySmall
                                                ?.copyWith(
                                                  fontSize: 10,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ] else if (_searchController.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Brak wyników',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
