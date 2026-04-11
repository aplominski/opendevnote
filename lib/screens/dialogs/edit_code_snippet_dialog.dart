import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/code_snippet.dart';
import 'package:opendevnote/providers/code_snippet_provider.dart';
import 'package:opendevnote/providers/todo_provider.dart';
import 'package:opendevnote/services/syntax_highlighter.dart';
import 'package:opendevnote/widgets/code_snippet_card.dart';

class EditCodeSnippetDialog extends ConsumerStatefulWidget {
  final CodeSnippet snippet;
  final List<String> availableTags;

  const EditCodeSnippetDialog({
    super.key,
    required this.snippet,
    this.availableTags = const [],
  });

  @override
  ConsumerState<EditCodeSnippetDialog> createState() =>
      _EditCodeSnippetDialogState();
}

class _EditCodeSnippetDialogState extends ConsumerState<EditCodeSnippetDialog> {
  late TextEditingController _titleController;
  late String _selectedLanguage;
  String? _selectedTaskId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.snippet.title);
    _selectedLanguage = widget.snippet.language;
    _selectedTaskId = widget.snippet.linkedTaskId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final todos = ref.watch(todosProvider(widget.snippet.projectId));
    final availableTasks = todos.where((t) => !t.isCompleted).toList();
    final languages = SyntaxHighlighter.getAvailableLanguages();

    return AlertDialog(
      title: Text(l10n.dialogEditSnippet),
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
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: InputDecoration(
                labelText: l10n.labelLanguage,
                isDense: true,
              ),
              items: languages.map((lang) {
                final def = SyntaxHighlighter.getDefinition(lang);
                return DropdownMenuItem(
                  value: lang,
                  child: Row(
                    children: [
                      Icon(
                        LanguageIcons.getIcon(lang),
                        size: 16,
                        color: LanguageColors.getColor(lang),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        def?.displayName ?? LanguageIcons.getDisplayName(lang),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedLanguage = v!),
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
                    l10n.actionLinkedTask,
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
        FilledButton(onPressed: _submit, child: Text(l10n.buttonSave)),
      ],
    );
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final updated = widget.snippet.copyWith(
      title: title,
      language: _selectedLanguage,
      linkedTaskId: _selectedTaskId,
      clearLinkedTask: _selectedTaskId == null,
    );
    ref
        .read(snippetsProvider(widget.snippet.projectId).notifier)
        .updateSnippet(updated);
    Navigator.pop(context, updated);
  }
}
