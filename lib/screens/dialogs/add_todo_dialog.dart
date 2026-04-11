import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/project_provider.dart';
import 'package:opendevnote/providers/todo_provider.dart';

class AddTodoDialog extends ConsumerStatefulWidget {
  final String projectId;
  final DateTime? defaultDueDate;

  const AddTodoDialog({
    super.key,
    required this.projectId,
    this.defaultDueDate,
  });

  @override
  ConsumerState<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends ConsumerState<AddTodoDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final Set<String> _selectedTags = {};
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.defaultDueDate != null) {
      _selectedDueDate = widget.defaultDueDate;
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final projects = ref.watch(projectsProvider);
    final project = projects.firstWhere(
      (p) => p.id == widget.projectId,
      orElse: () => projects.isNotEmpty
          ? projects.first
          : throw StateError('No project found'),
    );

    return AlertDialog(
      title: Text(l10n.dialogNewTask),
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
                hintText: l10n.placeholderEnterTaskTitle,
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.labelDescriptionOptional,
                hintText: l10n.placeholderAdditionalDescription,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.labelDeadline,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_selectedDueDate != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatDate(l10n, _selectedDueDate!),
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        if (_selectedTime != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            _selectedTime!.format(context),
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() {
                            _selectedDueDate = null;
                            _selectedTime = null;
                          }),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Text(
                      l10n.buttonChange,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ] else
                  GestureDetector(
                    onTap: _pickDate,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.buttonSetDeadline,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (project.tags.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l10n.labelTags,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: project.tags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    showCheckmark: false,
                    selectedColor: colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  );
                }).toList(),
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
        FilledButton(onPressed: _submit, child: Text(l10n.buttonAdd)),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (!mounted) return;

    setState(() {
      _selectedDueDate = date;
      _selectedTime = time ?? TimeOfDay.now();
    });
  }

  String _formatDate(AppLocalizations l10n, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    if (target == today) return l10n.timeToday;
    if (target == today.add(const Duration(days: 1))) return l10n.timeTomorrow;
    return '${date.day}.${date.month.toString().padLeft(2, '0')}';
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    DateTime? dueDate;
    if (_selectedDueDate != null && _selectedTime != null) {
      dueDate = DateTime(
        _selectedDueDate!.year,
        _selectedDueDate!.month,
        _selectedDueDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    ref
        .read(todosProvider(widget.projectId).notifier)
        .addTodo(
          title: title,
          description: _descriptionController.text.trim(),
          tags: _selectedTags.toList(),
          dueDate: dueDate,
        );
    Navigator.pop(context);
  }
}
