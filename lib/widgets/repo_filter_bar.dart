import 'package:flutter/material.dart';
import 'package:opendevnote/models/repo_filter.dart';

class RepoFilterBar extends StatefulWidget {
  final RepoFilter filter;
  final ValueChanged<RepoFilter> onChanged;
  final List<String>? availableLanguages;
  final bool showLanguage;
  final bool showVisibility;
  final bool showStatus;

  const RepoFilterBar({
    super.key,
    required this.filter,
    required this.onChanged,
    this.availableLanguages,
    this.showLanguage = false,
    this.showVisibility = false,
    this.showStatus = false,
  });

  @override
  State<RepoFilterBar> createState() => _RepoFilterBarState();
}

class _RepoFilterBarState extends State<RepoFilterBar> {
  bool _expanded = false;
  late TextEditingController _ownerController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _ownerController = TextEditingController(text: widget.filter.ownerPattern);
    _nameController = TextEditingController(text: widget.filter.namePattern);
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Toggle row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: widget.filter.hasActiveFilters
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Filtry',
                    style: textTheme.bodySmall?.copyWith(
                      color: widget.filter.hasActiveFilters
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontWeight: widget.filter.hasActiveFilters
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  if (widget.filter.hasActiveFilters) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.filter.activeCount}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (widget.filter.hasActiveFilters)
                    InkWell(
                      onTap: _clearAll,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: Text(
                          'Wyczyść',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Expanded filters
        if (_expanded) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Owner + Name row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ownerController,
                        decoration: const InputDecoration(
                          hintText: 'Owner (regex)',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_outline, size: 16),
                        ),
                        style: const TextStyle(fontSize: 13),
                        onChanged: (v) => widget.onChanged(
                          widget.filter.copyWith(ownerPattern: v),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Name (regex)',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.label_outline, size: 16),
                        ),
                        style: const TextStyle(fontSize: 13),
                        onChanged: (v) => widget.onChanged(
                          widget.filter.copyWith(namePattern: v),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Dropdowns row
                Row(
                  children: [
                    // Language
                    if (widget.showLanguage &&
                        widget.availableLanguages != null) ...[
                      Expanded(
                        child: _DropdownFilter(
                          label: 'Język',
                          value: widget.filter.language,
                          items: widget.availableLanguages!,
                          onChanged: (v) => widget.onChanged(
                            widget.filter.copyWith(
                              language: v,
                              clearLanguage: v == null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Visibility
                    if (widget.showVisibility) ...[
                      Expanded(
                        child: _DropdownFilter(
                          label: 'Widoczność',
                          value: widget.filter.visibility,
                          items: const ['public', 'private'],
                          displayNames: const ['Publiczne', 'Prywatne'],
                          onChanged: (v) => widget.onChanged(
                            widget.filter.copyWith(
                              visibility: v,
                              clearVisibility: v == null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Status
                    if (widget.showStatus) ...[
                      Expanded(
                        child: _DropdownFilter(
                          label: 'Status',
                          value: widget.filter.status,
                          items: const ['success', 'failure', 'in_progress'],
                          displayNames: const [
                            'Sukces',
                            'Niepowodzenie',
                            'W trakcie',
                          ],
                          onChanged: (v) => widget.onChanged(
                            widget.filter.copyWith(
                              status: v,
                              clearStatus: v == null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  void _clearAll() {
    _ownerController.clear();
    _nameController.clear();
    widget.onChanged(const RepoFilter());
  }
}

class _DropdownFilter extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final List<String>? displayNames;
  final ValueChanged<String?> onChanged;

  const _DropdownFilter({
    required this.label,
    required this.value,
    required this.items,
    this.displayNames,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: value,
      isDense: true,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(fontSize: 13),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Wszystkie', style: TextStyle(fontSize: 13)),
        ),
        ...items.asMap().entries.map(
          (e) => DropdownMenuItem<String?>(
            value: e.value,
            child: Text(
              displayNames != null ? displayNames![e.key] : e.value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

// ── Regex matching helper ──

bool matchesRegex(String input, String pattern) {
  if (pattern.isEmpty) return true;
  try {
    return RegExp(pattern, caseSensitive: false).hasMatch(input);
  } catch (_) {
    // Invalid regex - match as literal string
    return input.toLowerCase().contains(pattern.toLowerCase());
  }
}
