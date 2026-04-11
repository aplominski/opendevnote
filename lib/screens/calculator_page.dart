import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/providers/calculator_provider.dart';
import 'package:opendevnote/screens/tabs/calculator_tab.dart';
import 'package:opendevnote/screens/tabs/converter_tab.dart';
import 'package:opendevnote/screens/tabs/graph_tab.dart';
import 'package:opendevnote/widgets/app_breadcrumb.dart';

enum _CalcTab { calculator, graph, converter }

class CalculatorPage extends ConsumerStatefulWidget {
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends ConsumerState<CalculatorPage> {
  _CalcTab _selectedTab = _CalcTab.calculator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final calcState = ref.watch(calculatorProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBreadcrumb(
          items: ['OpenDevNote', l10n.navigationCalculator],
          onTap: [null, null],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                _selectedTab == _CalcTab.calculator
                    ? l10n.tabCalculator
                    : _selectedTab == _CalcTab.graph
                    ? l10n.tabGraph
                    : l10n.tabConverter,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_selectedTab == _CalcTab.calculator &&
                  calcState.history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () =>
                      ref.read(calculatorProvider.notifier).clearHistory(),
                  tooltip: l10n.buttonClearHistory,
                ),
              const SizedBox(width: 4),
              _TabButton(
                icon: Icons.calculate_outlined,
                label: l10n.tabCalculator,
                isSelected: _selectedTab == _CalcTab.calculator,
                onTap: () => setState(() => _selectedTab = _CalcTab.calculator),
              ),
              const SizedBox(width: 4),
              _TabButton(
                icon: Icons.show_chart,
                label: l10n.tabGraph,
                isSelected: _selectedTab == _CalcTab.graph,
                onTap: () => setState(() => _selectedTab = _CalcTab.graph),
              ),
              const SizedBox(width: 4),
              _TabButton(
                icon: Icons.swap_horiz,
                label: l10n.tabConverter,
                isSelected: _selectedTab == _CalcTab.converter,
                onTap: () => setState(() => _selectedTab = _CalcTab.converter),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: switch (_selectedTab) {
            _CalcTab.calculator => const CalculatorTab(),
            _CalcTab.graph => const GraphTab(),
            _CalcTab.converter => const ConverterTab(),
          },
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
