import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/providers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final currentLocale = ref.watch(localeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.settingsTitle, style: textTheme.titleLarge),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.language, color: colorScheme.primary),
          title: Text(l10n.settingsLanguage),
          subtitle: Text(l10n.settingsLanguageDesc),
          trailing: DropdownButton<Locale?>(
            value: currentLocale,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l10n.settingsLanguageSystem),
              ),
              DropdownMenuItem(
                value: const Locale('pl'),
                child: Text(l10n.settingsLanguagePolish),
              ),
              DropdownMenuItem(
                value: const Locale('en'),
                child: Text(l10n.settingsLanguageEnglish),
              ),
            ],
            onChanged: (locale) {
              ref.read(localeProvider.notifier).setLocale(locale);
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            l10n.settingsDataManagement,
            style: textTheme.titleMedium,
          ),
        ),
        ListTile(
          leading: Icon(Icons.save_alt, color: colorScheme.primary),
          title: Text(l10n.settingsExportData),
          subtitle: Text(l10n.settingsExportDataDesc),
          onTap: () => _exportData(context, ref),
        ),
        ListTile(
          leading: Icon(Icons.restore, color: colorScheme.primary),
          title: Text(l10n.settingsImportData),
          subtitle: Text(l10n.settingsImportDataDesc),
          onTap: () => _importData(context, ref),
        ),
      ],
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final storage = ref.read(storageServiceProvider);
    final data = storage.exportAllToJson();
    final jsonStr = const JsonEncoder.withIndent(' ').convert(data);
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final filename = 'opendevnote_backup_$timestamp.json';

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      String? path = await FilePicker.platform.saveFile(
        dialogTitle: l10n.settingsExportData,
        fileName: filename,
      );
      if (path == null) return;

      if (!path.endsWith('.json')) {
        path = '$path.json';
      }

      final file = File(path);
      await file.writeAsString(jsonStr);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.settingsExportSuccess)));
      }
    } else {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(jsonStr);
      await Share.shareXFiles([XFile(file.path)], subject: filename);
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsImportData),
        content: Text(l10n.settingsImportConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.buttonImport),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await FilePicker.platform.pickFiles(
      dialogTitle: l10n.settingsImportData,
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.first.path!);
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;

    final storage = ref.read(storageServiceProvider);
    await storage.importAllFromJson(data);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.settingsImportSuccess)));
      final navigator = Navigator.of(context);
      navigator.pushReplacementNamed('/');
    }
  }
}
