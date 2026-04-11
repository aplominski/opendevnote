import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/models/calc_models.dart';
import 'package:opendevnote/services/math_engine.dart';

// Calculator state
class CalculatorState {
  final String input;
  final String result;
  final CalcMode mode;
  final List<CalcHistoryEntry> history;

  const CalculatorState({
    this.input = '',
    this.result = '',
    this.mode = CalcMode.eval,
    this.history = const [],
  });

  CalculatorState copyWith({
    String? input,
    String? result,
    CalcMode? mode,
    List<CalcHistoryEntry>? history,
  }) {
    return CalculatorState(
      input: input ?? this.input,
      result: result ?? this.result,
      mode: mode ?? this.mode,
      history: history ?? this.history,
    );
  }
}

final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>(
      (ref) => CalculatorNotifier(),
    );

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(const CalculatorState());

  void setInput(String input) {
    state = state.copyWith(input: input);
  }

  void appendInput(String text) {
    state = state.copyWith(input: state.input + text);
  }

  void backspace() {
    if (state.input.isNotEmpty) {
      state = state.copyWith(
        input: state.input.substring(0, state.input.length - 1),
      );
    }
  }

  void clear() {
    state = state.copyWith(input: '', result: '');
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }

  void setMode(CalcMode mode) {
    state = state.copyWith(mode: mode);
  }

  void calculate() {
    if (state.input.isEmpty) return;

    String result;
    switch (state.mode) {
      case CalcMode.eval:
        result = MathEngine.evaluate(state.input);
        break;
      case CalcMode.derive:
        result = MathEngine.derive(state.input, 'x');
        break;
      case CalcMode.integrate:
        final parts = state.input.split('|');
        if (parts.length == 2) {
          final expr = parts[0].trim();
          final range = parts[1].trim();
          final rangeParts = range.split('..');
          if (rangeParts.length == 2) {
            final a = double.tryParse(rangeParts[0].trim());
            final b = double.tryParse(rangeParts[1].trim());
            if (a != null && b != null) {
              result = MathEngine.integrate(expr, 'x', a, b);
            } else {
              result = 'Format: expr | a..b';
            }
          } else {
            result = 'Format: expr | a..b';
          }
        } else {
          result = 'Format: expr | a..b';
        }
        break;
      case CalcMode.solve:
        result = MathEngine.solve(state.input);
        break;
      case CalcMode.limit:
        final parts = state.input.split('|');
        if (parts.length == 2) {
          final expr = parts[0].trim();
          final limitPart = parts[1].trim();
          final match = RegExp(r'x\s*→\s*([-\d.]+)').firstMatch(limitPart);
          if (match != null) {
            final point = double.tryParse(match.group(1)!);
            if (point != null) {
              result = MathEngine.limit(expr, 'x', point);
            } else {
              result = 'Format: expr | x→wartość';
            }
          } else {
            result = 'Format: expr | x→wartość';
          }
        } else {
          result = 'Format: expr | x→wartość';
        }
        break;
      case CalcMode.simplify:
        result = MathEngine.simplify(state.input);
        break;
      case CalcMode.inequality:
        result = MathEngine.solveInequality(state.input);
        break;
      case CalcMode.interval:
        result = MathEngine.solveInterval(state.input);
        break;
    }

    // Add to history
    final entry = CalcHistoryEntry(
      input: state.input,
      result: result,
      mode: state.mode.name,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(result: result, history: [entry, ...state.history]);
  }
}

// Graph state
class IntersectionPoint {
  final double x;
  final double y;
  final int function1Index;
  final int function2Index;

  const IntersectionPoint({
    required this.x,
    required this.y,
    required this.function1Index,
    required this.function2Index,
  });
}

class GraphState {
  final List<GraphFunction> functions;
  final double xMin, xMax, yMin, yMax;
  final Offset? tappedPoint;
  final List<IntersectionPoint> intersections;
  final IntersectionPoint? hoveredIntersection;

  const GraphState({
    this.functions = const [],
    this.xMin = -10,
    this.xMax = 10,
    this.yMin = -10,
    this.yMax = 10,
    this.tappedPoint,
    this.intersections = const [],
    this.hoveredIntersection,
  });

  GraphState copyWith({
    List<GraphFunction>? functions,
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
    Offset? tappedPoint,
    List<IntersectionPoint>? intersections,
    IntersectionPoint? hoveredIntersection,
    bool clearTapped = false,
    bool clearHovered = false,
  }) {
    return GraphState(
      functions: functions ?? this.functions,
      xMin: xMin ?? this.xMin,
      xMax: xMax ?? this.xMax,
      yMin: yMin ?? this.yMin,
      yMax: yMax ?? this.yMax,
      tappedPoint: clearTapped ? null : (tappedPoint ?? this.tappedPoint),
      intersections: intersections ?? this.intersections,
      hoveredIntersection: clearHovered
          ? null
          : (hoveredIntersection ?? this.hoveredIntersection),
    );
  }
}

final graphProvider = StateNotifierProvider<GraphNotifier, GraphState>(
  (ref) => GraphNotifier(),
);

class GraphNotifier extends StateNotifier<GraphState> {
  GraphNotifier() : super(const GraphState());

  void addFunction(String expression) {
    final funcs = [...state.functions];
    final colorIdx = funcs.length % 6;
    final parsed = MathEngine.parseGraphExpression(expression);
    funcs.add(
      GraphFunction(
        expression: expression,
        colorIndex: colorIdx,
        type: parsed.type,
        variableName: parsed.variableName,
        constantValue: parsed.constantValue,
      ),
    );
    state = state.copyWith(functions: funcs);
    _recalculateIntersections();
  }

  void removeFunction(int index) {
    final funcs = [...state.functions]..removeAt(index);
    state = state.copyWith(functions: funcs);
    _recalculateIntersections();
  }

  void updateFunction(int index, String expression) {
    final funcs = [...state.functions];
    final parsed = MathEngine.parseGraphExpression(expression);
    funcs[index] = funcs[index].copyWith(
      expression: expression,
      type: parsed.type,
      variableName: parsed.variableName,
      constantValue: parsed.constantValue,
    );
    state = state.copyWith(functions: funcs);
    _recalculateIntersections();
  }

  void toggleFunction(int index) {
    final funcs = [...state.functions];
    funcs[index] = funcs[index].copyWith(visible: !funcs[index].visible);
    state = state.copyWith(functions: funcs);
    _recalculateIntersections();
  }

  void _recalculateIntersections() {
    final intersections = <IntersectionPoint>[];
    final funcs = state.functions.where((f) => f.visible).toList();

    for (int i = 0; i < funcs.length; i++) {
      for (int j = i + 1; j < funcs.length; j++) {
        final points = _findIntersections(funcs[i], funcs[j]);
        intersections.addAll(points);
      }
    }

    state = state.copyWith(intersections: intersections);
  }

  List<IntersectionPoint> _findIntersections(
    GraphFunction f1,
    GraphFunction f2,
  ) {
    final points = <IntersectionPoint>[];

    // Get evaluated functions
    final eval1 = _getEvaluator(f1);
    final eval2 = _getEvaluator(f2);

    if (eval1 == null || eval2 == null) return points;

    // Find intersections by scanning
    final xStep = (state.xMax - state.xMin) / 1000;
    double? prevDiff;

    for (double x = state.xMin; x <= state.xMax; x += xStep) {
      final y1 = eval1(x);
      final y2 = eval2(x);

      if (y1 == null || y2 == null) continue;

      final diff = y1 - y2;

      if (prevDiff != null && prevDiff * diff < 0) {
        // Sign change - intersection found, refine with bisection
        final xInt = _refineIntersection(eval1, eval2, x - xStep, x);
        if (xInt != null) {
          final yInt = eval1(xInt);
          if (yInt != null) {
            points.add(
              IntersectionPoint(
                x: xInt,
                y: yInt,
                function1Index: state.functions.indexOf(f1),
                function2Index: state.functions.indexOf(f2),
              ),
            );
          }
        }
      }
      prevDiff = diff;
    }

    return points;
  }

  double? Function(double)? _getEvaluator(GraphFunction func) {
    final parsed = MathEngine.parseGraphExpression(func.expression);

    switch (parsed.type) {
      case GraphFunctionType.function:
        return (x) {
          final result = MathEngine.evaluate(parsed.expression, vars: {'x': x});
          return double.tryParse(result);
        };
      case GraphFunctionType.verticalLine:
        return null; // Can't intersect as y=f(x)
      case GraphFunctionType.horizontalLine:
        return (_) => parsed.constantValue;
      case GraphFunctionType.parametric:
        return (x) {
          // For parametric, evaluate with the variable
          final result = MathEngine.evaluate(
            parsed.expression,
            vars: {parsed.variableName ?? 't': x},
          );
          return double.tryParse(result);
        };
    }
  }

  double? _refineIntersection(
    double? Function(double) f1,
    double? Function(double) f2,
    double a,
    double b,
  ) {
    for (int i = 0; i < 20; i++) {
      final mid = (a + b) / 2;
      final y1 = f1(mid);
      final y2 = f2(mid);
      if (y1 == null || y2 == null) return null;

      final diff = y1 - y2;

      if (diff.abs() < 1e-10) return mid;

      final diffA = (f1(a) ?? 0) - (f2(a) ?? 0);
      if (diffA * diff < 0) {
        b = mid;
      } else {
        a = mid;
      }
    }
    return (a + b) / 2;
  }

  void setViewport({double? xMin, double? xMax, double? yMin, double? yMax}) {
    state = state.copyWith(xMin: xMin, xMax: xMax, yMin: yMin, yMax: yMax);
    _recalculateIntersections();
  }

  void resetViewport() {
    state = state.copyWith(xMin: -10, xMax: 10, yMin: -10, yMax: 10);
    _recalculateIntersections();
  }

  void zoom(double factor) {
    final xCenter = (state.xMin + state.xMax) / 2;
    final yCenter = (state.yMin + state.yMax) / 2;
    final xRange = (state.xMax - state.xMin) * factor / 2;
    final yRange = (state.yMax - state.yMin) * factor / 2;
    state = state.copyWith(
      xMin: xCenter - xRange,
      xMax: xCenter + xRange,
      yMin: yCenter - yRange,
      yMax: yCenter + yRange,
    );
  }

  void pan(double dx, double dy, double canvasWidth, double canvasHeight) {
    final xScale = (state.xMax - state.xMin) / canvasWidth;
    final yScale = (state.yMax - state.yMin) / canvasHeight;
    final xOffset = -dx * xScale;
    final yOffset = dy * yScale;
    state = state.copyWith(
      xMin: state.xMin + xOffset,
      xMax: state.xMax + xOffset,
      yMin: state.yMin + yOffset,
      yMax: state.yMax + yOffset,
    );
  }

  void setTappedPoint(Offset? point) {
    state = state.copyWith(tappedPoint: point, clearTapped: point == null);
  }

  void setHoveredIntersection(IntersectionPoint? point) {
    state = state.copyWith(hoveredIntersection: point);
  }
}

// Converter state
class ConverterCategory {
  final String name;
  final List<String> units;

  const ConverterCategory({required this.name, required this.units});
}

class ConverterState {
  final int categoryIndex;
  final int fromUnitIndex;
  final int toUnitIndex;
  final String input;
  final String result;

  const ConverterState({
    this.categoryIndex = 0,
    this.fromUnitIndex = 0,
    this.toUnitIndex = 1,
    this.input = '',
    this.result = '',
  });

  ConverterState copyWith({
    int? categoryIndex,
    int? fromUnitIndex,
    int? toUnitIndex,
    String? input,
    String? result,
  }) {
    return ConverterState(
      categoryIndex: categoryIndex ?? this.categoryIndex,
      fromUnitIndex: fromUnitIndex ?? this.fromUnitIndex,
      toUnitIndex: toUnitIndex ?? this.toUnitIndex,
      input: input ?? this.input,
      result: result ?? this.result,
    );
  }
}

const converterCategories = [
  ConverterCategory(
    name: 'Długość',
    units: ['m', 'km', 'cm', 'mm', 'in', 'ft', 'yd', 'mi'],
  ),
  ConverterCategory(name: 'Masa', units: ['kg', 'g', 'mg', 'lb', 'oz', 'ton']),
  ConverterCategory(name: 'Temperatura', units: ['°C', '°F', 'K']),
  ConverterCategory(name: 'Czas', units: ['s', 'min', 'h', 'day', 'week']),
  ConverterCategory(name: 'Prędkość', units: ['m/s', 'km/h', 'mph', 'knots']),
  ConverterCategory(name: 'Objętość', units: ['L', 'mL', 'gal', 'm³', 'cm³']),
  ConverterCategory(name: 'Dane', units: ['bit', 'B', 'KB', 'MB', 'GB', 'TB']),
  ConverterCategory(name: 'Kąt', units: ['deg', 'rad', 'grad']),
  ConverterCategory(name: 'Liczbowe', units: ['DEC', 'HEX', 'BIN', 'OCT']),
];

final converterProvider =
    StateNotifierProvider<ConverterNotifier, ConverterState>(
      (ref) => ConverterNotifier(),
    );

class ConverterNotifier extends StateNotifier<ConverterState> {
  ConverterNotifier() : super(const ConverterState());

  void setCategory(int index) {
    final currentInput = state.input;
    state = ConverterState(
      categoryIndex: index,
      fromUnitIndex: 0,
      toUnitIndex: 1,
      input: currentInput,
      result: '',
    );
    if (currentInput.isNotEmpty) convert();
  }

  void setFromUnit(int index) {
    state = state.copyWith(fromUnitIndex: index);
    if (state.input.isNotEmpty) convert();
  }

  void setToUnit(int index) {
    state = state.copyWith(toUnitIndex: index);
    if (state.input.isNotEmpty) convert();
  }

  void setInput(String input) {
    state = state.copyWith(input: input);
    convert();
  }

  void swap() {
    state = state.copyWith(
      fromUnitIndex: state.toUnitIndex,
      toUnitIndex: state.fromUnitIndex,
      input: state.result,
    );
    convert();
  }

  void convert() {
    final value = double.tryParse(state.input);
    if (value == null) {
      state = state.copyWith(result: '');
      return;
    }
    final cat = converterCategories[state.categoryIndex];
    final fromUnit = cat.units[state.fromUnitIndex];
    final toUnit = cat.units[state.toUnitIndex];

    // Convert via SI base unit
    final inBase = _toBase(value, fromUnit);
    if (inBase == null) {
      state = state.copyWith(result: 'N/A');
      return;
    }
    final result = _fromBase(inBase, toUnit);
    state = state.copyWith(
      result: result != null ? _formatConv(result) : 'N/A',
    );
  }

  double? _toBase(double value, String unit) {
    // Length -> meters
    const lengthToM = {
      'm': 1.0,
      'km': 1000.0,
      'cm': 0.01,
      'mm': 0.001,
      'in': 0.0254,
      'ft': 0.3048,
      'yd': 0.9144,
      'mi': 1609.344,
    };
    // Mass -> kg
    const massToKg = {
      'kg': 1.0,
      'g': 0.001,
      'mg': 0.000001,
      'lb': 0.453592,
      'oz': 0.0283495,
      'ton': 1000.0,
    };
    // Time -> seconds
    const timeToS = {
      's': 1.0,
      'min': 60.0,
      'h': 3600.0,
      'day': 86400.0,
      'week': 604800.0,
    };
    // Speed -> m/s
    const speedToMs = {
      'm/s': 1.0,
      'km/h': 1 / 3.6,
      'mph': 0.44704,
      'knots': 0.514444,
    };
    // Volume -> liters
    const volToL = {
      'L': 1.0,
      'mL': 0.001,
      'gal': 3.78541,
      'm³': 1000.0,
      'cm³': 0.001,
    };
    // Data -> bits
    const dataToBit = {
      'bit': 1.0,
      'B': 8.0,
      'KB': 8192.0,
      'MB': 8388608.0,
      'GB': 8589934592.0,
      'TB': 8796093022208.0,
    };
    // Angle -> degrees
    const angleToDeg = {'deg': 1.0, 'rad': 180 / 3.14159265358979, 'grad': 0.9};

    if (lengthToM.containsKey(unit)) return value * lengthToM[unit]!;
    if (massToKg.containsKey(unit)) return value * massToKg[unit]!;
    if (timeToS.containsKey(unit)) return value * timeToS[unit]!;
    if (speedToMs.containsKey(unit)) return value * speedToMs[unit]!;
    if (volToL.containsKey(unit)) return value * volToL[unit]!;
    if (dataToBit.containsKey(unit)) return value * dataToBit[unit]!;
    if (angleToDeg.containsKey(unit)) return value * angleToDeg[unit]!;

    // Temperature special cases
    if (unit == '°C') return value;
    if (unit == '°F') return (value - 32) * 5 / 9;
    if (unit == 'K') return value - 273.15;
    return null;
  }

  double? _fromBase(double baseValue, String unit) {
    const lengthFromM = {
      'm': 1.0,
      'km': 1 / 1000.0,
      'cm': 1 / 0.01,
      'mm': 1 / 0.001,
      'in': 1 / 0.0254,
      'ft': 1 / 0.3048,
      'yd': 1 / 0.9144,
      'mi': 1 / 1609.344,
    };
    const massFromKg = {
      'kg': 1.0,
      'g': 1 / 0.001,
      'mg': 1 / 0.000001,
      'lb': 1 / 0.453592,
      'oz': 1 / 0.0283495,
      'ton': 1 / 1000.0,
    };
    const timeFromS = {
      's': 1.0,
      'min': 1 / 60.0,
      'h': 1 / 3600.0,
      'day': 1 / 86400.0,
      'week': 1 / 604800.0,
    };
    const speedFromMs = {
      'm/s': 1.0,
      'km/h': 3.6,
      'mph': 1 / 0.44704,
      'knots': 1 / 0.514444,
    };
    const volFromL = {
      'L': 1.0,
      'mL': 1 / 0.001,
      'gal': 1 / 3.78541,
      'm³': 1 / 1000.0,
      'cm³': 1 / 0.001,
    };
    const dataFromBit = {
      'bit': 1.0,
      'B': 1 / 8.0,
      'KB': 1 / 8192.0,
      'MB': 1 / 8388608.0,
      'GB': 1 / 8589934592.0,
      'TB': 1 / 8796093022208.0,
    };
    const angleFromDeg = {
      'deg': 1.0,
      'rad': 3.14159265358979 / 180,
      'grad': 1 / 0.9,
    };

    if (lengthFromM.containsKey(unit)) return baseValue * lengthFromM[unit]!;
    if (massFromKg.containsKey(unit)) return baseValue * massFromKg[unit]!;
    if (timeFromS.containsKey(unit)) return baseValue * timeFromS[unit]!;
    if (speedFromMs.containsKey(unit)) return baseValue * speedFromMs[unit]!;
    if (volFromL.containsKey(unit)) return baseValue * volFromL[unit]!;
    if (dataFromBit.containsKey(unit)) return baseValue * dataFromBit[unit]!;
    if (angleFromDeg.containsKey(unit)) return baseValue * angleFromDeg[unit]!;

    // Temperature special cases (base is °C)
    if (unit == '°C') return baseValue;
    if (unit == '°F') return baseValue * 9 / 5 + 32;
    if (unit == 'K') return baseValue + 273.15;
    return null;
  }

  String _formatConv(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value.toStringAsPrecision(8);
  }
}
