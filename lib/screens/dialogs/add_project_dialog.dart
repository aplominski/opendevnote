import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/project_provider.dart';
import 'package:opendevnote/theme/app_colors.dart';

class AddProjectDialog extends ConsumerStatefulWidget {
  const AddProjectDialog({super.key});

  @override
  ConsumerState<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends ConsumerState<AddProjectDialog> {
  final _nameController = TextEditingController();
  int _selectedColor = 0;
  int _selectedIcon = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.dialogNewProject),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.labelProjectName,
                hintText: l10n.placeholderEnterProjectName,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.labelColor,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(AppColors.projectColors.length, (index) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.projectColors[index],
                      shape: BoxShape.circle,
                      border: _selectedColor == index
                          ? Border.all(color: colorScheme.onSurface, width: 2)
                          : null,
                    ),
                    child: _selectedColor == index
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.labelIcon,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: List.generate(AppColors.projectIcons.length, (index) {
                final isSelected = _selectedIcon == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = index),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      AppColors.projectIcons[index],
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.buttonCreate)),
      ],
    );
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    ref
        .read(projectsProvider.notifier)
        .addProject(
          name: name,
          colorIndex: _selectedColor,
          iconIndex: _selectedIcon,
        );
    Navigator.pop(context);
  }
}
