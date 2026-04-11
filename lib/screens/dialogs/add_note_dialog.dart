import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/note_provider.dart';
import 'package:opendevnote/providers/todo_provider.dart';

class AddNoteDialog extends ConsumerStatefulWidget {
  final String projectId;

  const AddNoteDialog({super.key, required this.projectId});

  @override
  ConsumerState<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends ConsumerState<AddNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedTaskId;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final todos = ref.watch(todosProvider(widget.projectId));
    final availableTasks = todos.where((t) => !t.isCompleted).toList();

    return AlertDialog(
      title: Text(l10n.dialogNewNote),
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
                initialValue: _selectedTaskId,
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
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.buttonAdd)),
      ],
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    ref
        .read(notesProvider(widget.projectId).notifier)
        .addNote(
          title: title,
          content: _contentController.text.trim(),
          linkedTaskId: _selectedTaskId,
        );
    Navigator.pop(context);
  }
}
