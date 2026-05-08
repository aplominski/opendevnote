import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/gh_branch.dart';
import 'package:opendevnote/providers/pull_requests_provider.dart';

class CreatePullRequestDialog extends ConsumerStatefulWidget {
  final String repoKey;

  const CreatePullRequestDialog({super.key, required this.repoKey});

  @override
  ConsumerState<CreatePullRequestDialog> createState() =>
      _CreatePullRequestDialogState();
}

class _CreatePullRequestDialogState
    extends ConsumerState<CreatePullRequestDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _selectedHead;
  String? _selectedBase;
  bool _isDraft = false;
  bool _isLoading = false;
  List<GhBranch> _branches = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBranches();
    });
  }

  Future<void> _loadBranches() async {
    await ref
        .read(repoPullRequestsProvider(widget.repoKey).notifier)
        .loadBranches();
    final state = ref.read(repoPullRequestsProvider(widget.repoKey));
    setState(() {
      _branches = state.branches;
      if (_branches.isNotEmpty) {
        _selectedBase = _branches.first.name;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.tooltipCreatePullRequest),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.labelTitle,
                  hintText: l10n.placeholderPullRequestTitle,
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: l10n.labelDescription,
                  hintText: l10n.placeholderPullRequestBody,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedHead,
                      decoration: InputDecoration(
                        labelText: l10n.labelHeadBranch,
                      ),
                      items: _branches
                          .map(
                            (b) => DropdownMenuItem(
                              value: b.name,
                              child: Text(b.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedHead = v),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(Icons.arrow_forward),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedBase,
                      decoration: InputDecoration(
                        labelText: l10n.labelBaseBranch,
                      ),
                      items: _branches
                          .map(
                            (b) => DropdownMenuItem(
                              value: b.name,
                              child: Text(b.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBase = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _isDraft,
                    onChanged: (v) => setState(() => _isDraft = v ?? false),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.labelDraft),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed:
              _isLoading ||
                  _titleController.text.isEmpty ||
                  _selectedHead == null ||
                  _selectedBase == null
              ? null
              : _createPr,
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

  Future<void> _createPr() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(repoPullRequestsProvider(widget.repoKey).notifier)
          .createPullRequest(
            title: _titleController.text,
            body: _bodyController.text.isEmpty ? null : _bodyController.text,
            head: _selectedHead!,
            base: _selectedBase!,
            draft: _isDraft,
          );
      await ref.read(pullRequestsProvider.notifier).fetchAll();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
