import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/note.dart';
import 'package:opendevnote/providers/note_provider.dart';
import 'package:opendevnote/providers/todo_provider.dart';

class EditNoteDialog extends ConsumerStatefulWidget {
  final Note note;

  const EditNoteDialog({super.key, required this.note});

  @override
  ConsumerState<EditNoteDialog> createState() => _EditNoteDialogState();
}

class _EditNoteDialogState extends ConsumerState<EditNoteDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late String? _selectedTaskId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedTaskId = widget.note.linkedTaskId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final todos = ref.watch(todosProvider(widget.note.projectId));
    final availableTasks = todos.where((t) => !t.isCompleted).toList();

    return AlertDialog(
      title: Text(l10n.dialogEditNote),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.labelTitle,
                hintText: l10n.placeholderEnterNoteTitle,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 6,
              minLines: 4,
              decoration: InputDecoration(
                labelText: l10n.labelDescription,
                hintText: l10n.placeholderEnterNoteContent,
                alignLabelWithHint: true,
              ),
            ),
            if (availableTasks.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.link,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.actionLinkTask,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: availableTasks.any((t) => t.id == _selectedTaskId)
                    ? _selectedTaskId
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      l10n.statusNone,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  ...availableTasks.map(
                    (t) => DropdownMenuItem<String?>(
                      value: t.id,
                      child: Text(
                        t.title,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedTaskId = v),
              ),
            ],
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _confirmDelete(context),
          icon: Icon(Icons.delete_outline, color: colorScheme.error),
          tooltip: l10n.dialogDeleteNote,
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.buttonSave)),
      ],
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final updated = widget.note.copyWith(
      title: title,
      content: _contentController.text.trim(),
      linkedTaskId: _selectedTaskId,
    );

    ref.read(notesProvider(widget.note.projectId).notifier).updateNote(updated);
    Navigator.pop(context);
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.dialogDeleteNote),
        content: Text(l10n.dialogDeleteNoteConfirm(widget.note.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(notesProvider(widget.note.projectId).notifier)
                  .deleteNote(widget.note.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: Text(l10n.buttonDelete),
          ),
        ],
      ),
    );
  }
}
