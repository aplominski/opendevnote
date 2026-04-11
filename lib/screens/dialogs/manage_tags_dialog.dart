import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/project.dart';
import 'package:opendevnote/providers/project_provider.dart';

class ManageTagsDialog extends ConsumerStatefulWidget {
  final Project project;

  const ManageTagsDialog({super.key, required this.project});

  @override
  ConsumerState<ManageTagsDialog> createState() => _ManageTagsDialogState();
}

class _ManageTagsDialogState extends ConsumerState<ManageTagsDialog> {
  late List<String> _tags;
  final _newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.project.tags);
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.dialogProjectTags),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTagController,
                    decoration: InputDecoration(
                      hintText: l10n.placeholderNewTag,
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tags.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.emptyStateNoTags,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _tags.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.label_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      title: Text(_tags[index]),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colorScheme.error,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _tags.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.buttonSave)),
      ],
    );
  }

  void _addTag() {
    final name = _newTagController.text.trim();
    if (name.isEmpty || _tags.contains(name)) return;

    setState(() {
      _tags.add(name);
      _newTagController.clear();
    });
  }

  void _save() {
    final updated = widget.project.copyWith(tags: _tags);
    ref.read(projectsProvider.notifier).updateProject(updated);
    Navigator.pop(context);
  }
}
