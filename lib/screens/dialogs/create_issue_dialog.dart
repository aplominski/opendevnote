import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/issues_provider.dart';

class CreateIssueDialog extends ConsumerStatefulWidget {
  final String repoKey;

  const CreateIssueDialog({super.key, required this.repoKey});

  @override
  ConsumerState<CreateIssueDialog> createState() => _CreateIssueDialogState();
}

class _CreateIssueDialogState extends ConsumerState<CreateIssueDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _labelsController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _labelsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.dialogNewIssue),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: l10n.placeholderIssueTitle),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(hintText: l10n.placeholderIssueBody),
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _labelsController,
              decoration: InputDecoration(hintText: l10n.placeholderLabels),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _create,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.buttonCreate),
        ),
      ],
    );
  }

  Future<void> _create() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final labels = _labelsController.text.isEmpty
          ? null
          : _labelsController.text
                .split(',')
                .map((l) => l.trim())
                .where((l) => l.isNotEmpty)
                .toList();

      final issue = await ref
          .read(repoIssuesProvider(widget.repoKey).notifier)
          .createIssue(
            title: title,
            body: _bodyController.text.isEmpty ? null : _bodyController.text,
            labels: labels,
          );

      if (mounted) {
        Navigator.pop(context, issue);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
