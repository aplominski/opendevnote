import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/note.dart';
import 'package:opendevnote/providers/note_provider.dart';
import 'package:opendevnote/widgets/app_sidebar.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final Note note;

  const NoteEditorScreen({super.key, required this.note});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _contentController;
  bool _showPreview = true;
  String _previewContent = '';

  Timer? _previewTimer;
  Timer? _saveTimer;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.note.content);
    _previewContent = widget.note.content;
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    _saveTimer?.cancel();
    if (_hasUnsavedChanges) {
      _saveNote();
    }
    _contentController.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });

    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _previewContent = _contentController.text;
      });
    });

    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _saveNote();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 700;

    Widget body = Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: _showPreview
                    ? BorderSide(color: colorScheme.outlineVariant)
                    : BorderSide.none,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Edytor',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _contentController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(
                      hintText: 'Wprowadź treść w formacie Markdown...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: const TextStyle(fontFamily: 'monospace'),
                    onChanged: (_) => _onContentChanged(),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showPreview)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Podgląd',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Markdown(
                    data: _previewContent,
                    selectable: true,
                    padding: const EdgeInsets.all(16),
                    styleSheet: MarkdownStyleSheet(
                      h1: Theme.of(context).textTheme.headlineLarge,
                      h2: Theme.of(context).textTheme.headlineMedium,
                      h3: Theme.of(context).textTheme.headlineSmall,
                      h4: Theme.of(context).textTheme.titleLarge,
                      h5: Theme.of(context).textTheme.titleMedium,
                      h6: Theme.of(context).textTheme.titleSmall,
                      p: Theme.of(context).textTheme.bodyMedium,
                      code: TextStyle(
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        fontFamily: 'monospace',
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: colorScheme.primary,
                            width: 4,
                          ),
                        ),
                      ),
                      listBullet: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    if (isWide) {
      body = Row(
        children: [
          const AppSidebar(),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title),
        actions: [
          if (_hasUnsavedChanges)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          IconButton(
            icon: Icon(_showPreview ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _showPreview = !_showPreview),
            tooltip: _showPreview ? 'Ukryj podgląd' : 'Pokaż podgląd',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Zapisz',
          ),
        ],
      ),
      body: body,
    );
  }

  void _saveNote() {
    final updated = widget.note.copyWith(
      content: _contentController.text.trim(),
    );
    ref.read(notesProvider(widget.note.projectId).notifier).updateNote(updated);
    setState(() {
      _hasUnsavedChanges = false;
    });
  }
}
