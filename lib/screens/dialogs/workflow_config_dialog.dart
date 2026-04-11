import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/github_account.dart';
import 'package:opendevnote/providers/workflow_provider.dart';

class GithubSettingsDialog extends ConsumerStatefulWidget {
  const GithubSettingsDialog({super.key});

  @override
  ConsumerState<GithubSettingsDialog> createState() =>
      _GithubSettingsDialogState();
}

class _GithubSettingsDialogState extends ConsumerState<GithubSettingsDialog> {
  final _nameController = TextEditingController();
  final _tokenController = TextEditingController();
  bool _tokenVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final allAccounts = ref.watch(githubAccountsProvider);

    final seenIds = <String>{};
    final accounts = allAccounts.where((a) => seenIds.add(a.id)).toList();

    return AlertDialog(
      title: const Text('Konta GitHub'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Existing accounts
              if (accounts.isNotEmpty) ...[
                Text(
                  'Twoje konta',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                ...accounts.map(
                  (account) => _AccountTile(
                    account: account,
                    onDelete: () => ref
                        .read(githubAccountsProvider.notifier)
                        .deleteAccount(account.id),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
              ],
              // Add new account
              Text(
                'Dodaj konto',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwa konta',
                  hintText: 'np. Praca, Osobiste',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tokenController,
                obscureText: !_tokenVisible,
                decoration: InputDecoration(
                  labelText: 'Personal Access Token',
                  hintText: 'ghp_xxxxxxxxxxxx',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _tokenVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _tokenVisible = !_tokenVisible),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Zamknij'),
        ),
        FilledButton.icon(
          onPressed: _addAccount,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Dodaj konto'),
        ),
      ],
    );
  }

  void _addAccount() {
    final name = _nameController.text.trim();
    final token = _tokenController.text.trim();
    if (name.isEmpty || token.isEmpty) return;

    ref
        .read(githubAccountsProvider.notifier)
        .addAccount(name: name, token: token);

    _nameController.clear();
    _tokenController.clear();
  }
}

class _AccountTile extends StatelessWidget {
  final GithubAccount account;
  final VoidCallback onDelete;

  const _AccountTile({required this.account, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.key_outlined,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  account.maskedToken,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: colorScheme.error,
            ),
            onPressed: onDelete,
            visualDensity: VisualDensity.compact,
            tooltip: 'Usuń',
          ),
        ],
      ),
    );
  }
}
