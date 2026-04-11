import 'package:flutter/material.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/todo_item.dart';

class EditTodoDialog extends StatefulWidget {
  final TodoItem todo;
  final List<String> availableTags;

  const EditTodoDialog({
    super.key,
    required this.todo,
    this.availableTags = const [],
  });

  @override
  State<EditTodoDialog> createState() => _EditTodoDialogState();
}

class _EditTodoDialogState extends State<EditTodoDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late Set<String> _selectedTags;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedTime;
  bool _clearDueDate = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(
      text: widget.todo.description,
    );
    _selectedTags = Set.from(widget.todo.tags);
    if (widget.todo.dueDate != null) {
      _selectedDueDate = widget.todo.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.todo.dueDate!);
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(l10n.dialogEditTask),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.labelTitle),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.labelDescription,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            // Due date section
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
                if (_selectedDueDate != null && !_clearDueDate) ...[
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
                          _formatDate(_selectedDueDate!),
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
                            _clearDueDate = true;
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
            if (widget.availableTags.isNotEmpty) ...[
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
                children: widget.availableTags.map((tag) {
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
        FilledButton(onPressed: _submit, child: Text(l10n.buttonSave)),
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
      _clearDueDate = false;
    });
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
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
    if (!_clearDueDate && _selectedDueDate != null && _selectedTime != null) {
      dueDate = DateTime(
        _selectedDueDate!.year,
        _selectedDueDate!.month,
        _selectedDueDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    final updated = widget.todo.copyWith(
      title: title,
      description: _descriptionController.text.trim(),
      tags: _selectedTags.toList(),
      dueDate: _clearDueDate ? null : dueDate,
      clearDueDate: _clearDueDate && dueDate == null,
    );
    Navigator.pop(context, updated);
  }
}
