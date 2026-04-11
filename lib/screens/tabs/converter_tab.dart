import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/calculator_provider.dart';

class ConverterTab extends ConsumerStatefulWidget {
  const ConverterTab({super.key});

  @override
  ConsumerState<ConverterTab> createState() => _ConverterTabState();
}

class _ConverterTabState extends ConsumerState<ConverterTab> {
  final _decController = TextEditingController();
  final _hexController = TextEditingController();
  final _binController = TextEditingController();
  final _octController = TextEditingController();
  bool _updating = false;

  @override
  void dispose() {
    _decController.dispose();
    _hexController.dispose();
    _binController.dispose();
    _octController.dispose();
    super.dispose();
  }

  void _updateFrom(String value, int fromBase) {
    if (_updating) return;
    _updating = true;
    final num = int.tryParse(value, radix: fromBase);
    if (num != null) {
      if (fromBase != 10) _decController.text = num.toString();
      if (fromBase != 16)
        _hexController.text = num.toRadixString(16).toUpperCase();
      if (fromBase != 2) _binController.text = num.toRadixString(2);
      if (fromBase != 8) _octController.text = num.toRadixString(8);
    } else {
      for (final c in [
        _decController,
        _hexController,
        _binController,
        _octController,
      ]) {
        if (fromBase == 10 && c == _decController) continue;
        if (fromBase == 16 && c == _hexController) continue;
        if (fromBase == 2 && c == _binController) continue;
        if (fromBase == 8 && c == _octController) continue;
        c.text = '';
      }
    }
    _updating = false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final convState = ref.watch(converterProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cat = converterCategories[convState.categoryIndex];

    if (cat.name == l10n.labelNumeric) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.labelCategory,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: converterCategories.asMap().entries.map((entry) {
                final isSelected = entry.key == convState.categoryIndex;
                return ChoiceChip(
                  label: Text(
                    _getCategoryName(l10n, entry.value.name),
                    style: const TextStyle(fontSize: 12),
                  ),
                  selected: isSelected,
                  onSelected: (_) => ref
                      .read(converterProvider.notifier)
                      .setCategory(entry.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            _BaseField(
              label: 'DEC (10)',
              controller: _decController,
              onChanged: (v) => _updateFrom(v, 10),
              color: colorScheme.primary,
            ),
            const SizedBox(height: 12),
            _BaseField(
              label: 'HEX (16)',
              controller: _hexController,
              onChanged: (v) => _updateFrom(v.toUpperCase(), 16),
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _BaseField(
              label: 'BIN (2)',
              controller: _binController,
              onChanged: (v) => _updateFrom(v, 2),
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _BaseField(
              label: 'OCT (8)',
              controller: _octController,
              onChanged: (v) => _updateFrom(v, 8),
              color: Colors.purple,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.labelCategory,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: converterCategories.asMap().entries.map((entry) {
              final isSelected = entry.key == convState.categoryIndex;
              return ChoiceChip(
                label: Text(
                  _getCategoryName(l10n, entry.value.name),
                  style: const TextStyle(fontSize: 12),
                ),
                selected: isSelected,
                onSelected: (_) =>
                    ref.read(converterProvider.notifier).setCategory(entry.key),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.labelFrom,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '0',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 18),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) =>
                      ref.read(converterProvider.notifier).setInput(v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: convState.fromUnitIndex,
                  isDense: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: cat.units
                      .asMap()
                      .entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(
                            e.value,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(converterProvider.notifier).setFromUnit(v);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: IconButton(
              icon: const Icon(Icons.swap_vert),
              onPressed: () => ref.read(converterProvider.notifier).swap(),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.labelTo,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    convState.result.isEmpty ? '—' : convState.result,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: convState.result.isEmpty
                          ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                          : colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: convState.toUnitIndex,
                  isDense: true,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(),
                  ),
                  items: cat.units
                      .asMap()
                      .entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(
                            e.value,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref.read(converterProvider.notifier).setToUnit(v);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            l10n.labelPopular,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _quickConversions(context, cat),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(AppLocalizations l10n, String originalName) {
    switch (originalName) {
      case 'Liczbowe':
        return l10n.labelNumeric;
      case 'Długość':
        return l10n.converterLength;
      case 'Masa':
        return l10n.converterMass;
      case 'Temperatura':
        return l10n.converterTemperature;
      case 'Czas':
        return l10n.converterTime;
      case 'Prędkość':
        return l10n.converterSpeed;
      case 'Objętość':
        return l10n.converterVolume;
      case 'Dane':
        return l10n.converterData;
      case 'Kąt':
        return l10n.converterAngle;
      default:
        return originalName;
    }
  }

  List<Widget> _quickConversions(BuildContext context, dynamic cat) {
    final colorScheme = Theme.of(context).colorScheme;
    final pairs = <String>[];

    for (int i = 0; i < cat.units.length; i++) {
      for (int j = i + 1; j < cat.units.length && j <= i + 3; j++) {
        pairs.add('${cat.units[i]} → ${cat.units[j]}');
      }
    }

    return pairs.map((p) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          p,
          style: TextStyle(
            fontSize: 11,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      );
    }).toList();
  }
}

class _BaseField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Color color;

  const _BaseField({
    required this.label,
    required this.controller,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
