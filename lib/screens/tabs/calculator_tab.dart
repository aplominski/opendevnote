import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/calc_models.dart';
import 'package:opendevnote/providers/calculator_provider.dart';

String _getModeLabel(AppLocalizations l10n, CalcMode mode) {
  switch (mode) {
    case CalcMode.eval:
      return l10n.calcModeEval;
    case CalcMode.derive:
      return l10n.calcModeDerive;
    case CalcMode.integrate:
      return l10n.calcModeIntegrate;
    case CalcMode.solve:
      return l10n.calcModeSolve;
    case CalcMode.limit:
      return l10n.calcModeLimit;
    case CalcMode.simplify:
      return l10n.calcModeSimplify;
    case CalcMode.inequality:
      return l10n.calcModeInequality;
    case CalcMode.interval:
      return l10n.calcModeInterval;
  }
}

class CalculatorTab extends ConsumerStatefulWidget {
  const CalculatorTab({super.key});

  @override
  ConsumerState<CalculatorTab> createState() => _CalculatorTabState();
}

class _CalculatorTabState extends ConsumerState<CalculatorTab> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final notifier = ref.read(calculatorProvider.notifier);
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      notifier.calculate();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.backspace) {
      notifier.backspace();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      notifier.clear();
      return KeyEventResult.handled;
    }

    final char = event.character;
    if (char == null || char.isEmpty) return KeyEventResult.ignored;

    if (char == '^' ||
        char == '!' ||
        char == '(' ||
        char == ')' ||
        char == '<' ||
        char == '>' ||
        char == '+' ||
        char == '-' ||
        char == '*' ||
        char == '/' ||
        char == '.' ||
        char == ',' ||
        char == ';' ||
        char == ' ' ||
        char == '=') {
      if (char == ',' || char == ' ') {
        notifier.appendInput('.');
      } else if (char == ';') {
        notifier.appendInput('|');
      } else {
        notifier.appendInput(char);
      }
      return KeyEventResult.handled;
    }

    if (char.contains(RegExp(r'^[0-9]$'))) {
      notifier.appendInput(char);
      return KeyEventResult.handled;
    }

    if (char == 'x' || char == 'X') {
      notifier.appendInput('x');
      return KeyEventResult.handled;
    } else if (char == 'y' || char == 'Y') {
      notifier.appendInput('y');
      return KeyEventResult.handled;
    } else if (char == 'z' || char == 'Z') {
      notifier.appendInput('z');
      return KeyEventResult.handled;
    } else if (char == 'e' || char == 'E') {
      notifier.appendInput('e');
      return KeyEventResult.handled;
    } else if (char == 'p' || char == 'P') {
      notifier.appendInput('pi');
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final calcState = ref.watch(calculatorProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isWide = MediaQuery.of(context).size.width > 500;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_focusNode.hasFocus) _focusNode.requestFocus();
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKey,
        child: Column(
          children: [
            if (calcState.history.isNotEmpty)
              _HistorySection(history: calcState.history),
            _DisplaySection(state: calcState),
            _ModeSelector(
              mode: calcState.mode,
              onModeChanged: (m) =>
                  ref.read(calculatorProvider.notifier).setMode(m),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Text(
                l10n.placeholderExampleMode(calcState.mode.example),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ),
            Expanded(child: _ButtonGrid(isWide: isWide)),
          ],
        ),
      ),
    );
  }
}

class _DisplaySection extends StatelessWidget {
  final CalculatorState state;

  const _DisplaySection({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            state.input.isEmpty ? '0' : state.input,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w300,
              color: state.input.isEmpty
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                  : null,
            ),
          ),
          const SizedBox(height: 4),
          if (state.result.isNotEmpty)
            SizedBox(
              height: 24,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  '= ${state.result}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final CalcMode mode;
  final ValueChanged<CalcMode> onModeChanged;

  const _ModeSelector({required this.mode, required this.onModeChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: CalcMode.values.map((m) {
          final isSelected = m == mode;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => onModeChanged(m),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.3)
                        : colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  _getModeLabel(l10n, m),
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ButtonGrid extends ConsumerStatefulWidget {
  final bool isWide;

  const _ButtonGrid({required this.isWide});

  @override
  ConsumerState<_ButtonGrid> createState() => _ButtonGridState();
}

class _ButtonGridState extends ConsumerState<_ButtonGrid> {
  bool _showAdvanced = false;
  bool _equalsPressedOnce = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(calculatorProvider.notifier);

    const advancedButtons = [
      ['sin', 'cos', 'tan', 'log', 'ln'],
      ['√', 'x²', 'xʸ', 'abs', '!'],
    ];

    const mainButtons = [
      ['7', '8', '9', '÷', '('],
      ['4', '5', '6', '×', ')'],
      ['1', '2', '3', '-', 'π'],
      ['0', '.', '=', '+', 'e'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          if (_showAdvanced) ...[
            ...advancedButtons.map(
              (row) => Expanded(
                child: Row(
                  children: row
                      .map(
                        (btn) => Expanded(
                          child: _CalcButton(
                            label: btn,
                            isFunction: true,
                            onTap: () => _onButtonTap(btn),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
          _AdvancedToggle(
            expanded: _showAdvanced,
            onTap: () => setState(() => _showAdvanced = !_showAdvanced),
          ),
          ...mainButtons.map(
            (row) => Expanded(
              child: Row(
                children: row
                    .map(
                      (btn) => Expanded(
                        child: _CalcButton(
                          label: btn,
                          isOperator: ['÷', '×', '-', '+'].contains(btn),
                          isEquals: btn == '=',
                          onTap: () => _onButtonTap(btn),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _CalcButton(
                    label: '⌫',
                    onTap: () => notifier.backspace(),
                    isDanger: true,
                  ),
                ),
                Expanded(
                  child: _CalcButton(
                    label: 'C',
                    onTap: () => notifier.clear(),
                    isDanger: true,
                  ),
                ),
                Expanded(
                  child: _CalcButton(
                    label: 'x',
                    onTap: () => notifier.appendInput('x'),
                  ),
                ),
                Expanded(
                  child: _CalcButton(
                    label: '<',
                    onTap: () => notifier.appendInput('<'),
                  ),
                ),
                Expanded(
                  child: _CalcButton(
                    label: '>',
                    onTap: () => notifier.appendInput('>'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onButtonTap(String btn) {
    final notifier = ref.read(calculatorProvider.notifier);
    final mode = ref.read(calculatorProvider).mode;
    switch (btn) {
      case '=':
        if (mode == CalcMode.solve || mode == CalcMode.inequality) {
          if (_equalsPressedOnce) {
            notifier.calculate();
            setState(() => _equalsPressedOnce = false);
          } else {
            notifier.appendInput('=');
            setState(() => _equalsPressedOnce = true);
          }
        } else {
          notifier.calculate();
        }
        break;
      case 'π':
        notifier.appendInput('pi');
        break;
      case 'e':
        notifier.appendInput('e');
        break;
      case '√':
        notifier.appendInput('sqrt(');
        break;
      case 'x²':
        notifier.appendInput('^2');
        break;
      case 'xʸ':
        notifier.appendInput('^');
        break;
      case '!':
        notifier.appendInput('!');
        break;
      case '÷':
        notifier.appendInput('/');
        break;
      case '×':
        notifier.appendInput('*');
        break;
      case 'log':
        notifier.appendInput('log(');
        break;
      case 'ln':
        notifier.appendInput('ln(');
        break;
      default:
        if (btn == 'sin' || btn == 'cos' || btn == 'tan' || btn == 'abs') {
          notifier.appendInput('$btn(');
        } else {
          notifier.appendInput(btn);
        }
    }
  }
}

class _AdvancedToggle extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _AdvancedToggle({required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 18,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              expanded ? l10n.buttonHideFunctions : l10n.buttonShowFunctions,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isFunction;
  final bool isOperator;
  final bool isEquals;
  final bool isDanger;

  const _CalcButton({
    required this.label,
    required this.onTap,
    this.isFunction = false,
    this.isOperator = false,
    this.isEquals = false,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color? bgColor;
    Color? textColor;

    if (isEquals) {
      bgColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isDanger) {
      bgColor = colorScheme.errorContainer.withValues(alpha: 0.2);
      textColor = colorScheme.error;
    } else if (isFunction) {
      bgColor = colorScheme.tertiaryContainer.withValues(alpha: 0.3);
      textColor = colorScheme.onTertiaryContainer;
    } else if (isOperator) {
      bgColor = colorScheme.primaryContainer.withValues(alpha: 0.3);
      textColor = colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: bgColor ?? colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Center(
            child: Text(
              label,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: textColor,
                fontSize: isFunction ? 13 : 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HistorySection extends ConsumerStatefulWidget {
  final List<CalcHistoryEntry> history;

  const _HistorySection({required this.history});

  @override
  ConsumerState<_HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends ConsumerState<_HistorySection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.labelHistory,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${widget.history.length}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          SizedBox(
            height: 100,
            child: ListView.builder(
              itemCount: widget.history.take(20).length,
              itemBuilder: (context, index) {
                final entry = widget.history[index];
                return InkWell(
                  onTap: () {
                    ref.read(calculatorProvider.notifier).setInput(entry.input);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.2,
                          ),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            entry.input,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '= ${entry.result}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
