import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/rss_provider.dart';

class AddRssFeedDialog extends ConsumerStatefulWidget {
  const AddRssFeedDialog({super.key});

  @override
  ConsumerState<AddRssFeedDialog> createState() => _AddRssFeedDialogState();
}

class _AddRssFeedDialogState extends ConsumerState<AddRssFeedDialog> {
  final _urlController = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref
          .read(rssFeedsProvider.notifier)
          .addFeed(url, category: _categoryController.text.trim());
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = AppLocalizations.of(
          context,
        )!.errorFeedFetchFailed(e.toString());
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.dialogAddRssFeed),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _urlController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.placeholderFeedUrl,
                hintText: 'https://example.com/feed.xml',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: l10n.labelCategoryOptional,
                hintText: l10n.placeholderCategoryExample,
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: colorScheme.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.buttonAdd),
        ),
      ],
    );
  }
}
