import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/rss_provider.dart';

class RssSettingsDialog extends ConsumerStatefulWidget {
  const RssSettingsDialog({super.key});

  @override
  ConsumerState<RssSettingsDialog> createState() => _RssSettingsDialogState();
}

class _RssSettingsDialogState extends ConsumerState<RssSettingsDialog> {
  late bool _autoRefresh;
  late int _refreshMinutes;
  late bool _autoCleanup;
  late int _cleanupDays;
  late bool _splitView;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(rssPrefsProvider);
    _autoRefresh = prefs.autoRefreshEnabled;
    _refreshMinutes = prefs.autoRefreshMinutes;
    _autoCleanup = prefs.autoCleanupEnabled;
    _cleanupDays = prefs.cleanupDays;
    _splitView = prefs.splitViewMode;
  }

  void _save() {
    ref
        .read(rssPrefsProvider.notifier)
        .update(
          autoRefreshEnabled: _autoRefresh,
          autoRefreshMinutes: _refreshMinutes,
          autoCleanupEnabled: _autoCleanup,
          cleanupDays: _cleanupDays,
          splitViewMode: _splitView,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.dialogRssSettings),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsAutoRefresh),
              subtitle: Text(
                '$_refreshMinutes min',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              value: _autoRefresh,
              onChanged: (v) => setState(() => _autoRefresh = v),
            ),
            if (_autoRefresh) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${l10n.settingsInterval} ',
                    style: textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Slider(
                      value: _refreshMinutes.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      label: '$_refreshMinutes min',
                      onChanged: (v) =>
                          setState(() => _refreshMinutes = v.toInt()),
                    ),
                  ),
                  Text('${_refreshMinutes}min', style: textTheme.bodySmall),
                ],
              ),
            ],
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsAutoCleanup),
              subtitle: Text(
                '$_cleanupDays dni',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              value: _autoCleanup,
              onChanged: (v) => setState(() => _autoCleanup = v),
            ),
            if (_autoCleanup) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${l10n.settingsDaysThreshold} ',
                    style: textTheme.bodyMedium,
                  ),
                  Expanded(
                    child: Slider(
                      value: _cleanupDays.toDouble(),
                      min: 7,
                      max: 90,
                      divisions: 83,
                      label: '$_cleanupDays dni',
                      onChanged: (v) =>
                          setState(() => _cleanupDays = v.toInt()),
                    ),
                  ),
                  Text('${_cleanupDays}d', style: textTheme.bodySmall),
                ],
              ),
            ],
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsSplitView),
              subtitle: Text(
                _splitView
                    ? 'Lista feedow + artykuly'
                    : 'Tylko lista artykulow',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
              value: _splitView,
              onChanged: (v) => setState(() => _splitView = v),
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
}
