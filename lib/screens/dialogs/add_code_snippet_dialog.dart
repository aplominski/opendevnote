import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/code_snippet_provider.dart';
import 'package:opendevnote/providers/todo_provider.dart';

class AddCodeSnippetDialog extends ConsumerStatefulWidget {
  final String projectId;

  const AddCodeSnippetDialog({super.key, required this.projectId});

  @override
  ConsumerState<AddCodeSnippetDialog> createState() =>
      _AddCodeSnippetDialogState();
}

class _AddCodeSnippetDialogState extends ConsumerState<AddCodeSnippetDialog> {
  final _titleController = TextEditingController();
  String? _selectedTaskId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isSubmitting = true);

    ref
        .read(snippetsProvider(widget.projectId).notifier)
        .addSnippet(
          title: title,
          language: 'dart',
          code: '',
          linkedTaskId: _selectedTaskId,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final todos = ref.watch(todosProvider(widget.projectId));
    final availableTasks = todos.where((t) => !t.isCompleted).toList();

    return AlertDialog(
      title: Text(l10n.dialogNewCodeSnippet),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.labelTitle,
                hintText: l10n.placeholderEnterTitle,
              ),
              onSubmitted: (_) => _submit(),
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
                value: _selectedTaskId,
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
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: Text(l10n.buttonAdd),
        ),
      ],
    );
  }
}
