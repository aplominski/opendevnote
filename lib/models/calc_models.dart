class CalcHistoryEntry {
  final String input;
  final String result;
  final String mode;
  final DateTime timestamp;

  CalcHistoryEntry({
    required this.input,
    required this.result,
    required this.mode,
    required this.timestamp,
  });
}

class GraphFunction {
  final String expression;
  final int colorIndex;
  final bool visible;
  final GraphFunctionType type;
  final String? variableName;
  final double? constantValue;

  GraphFunction({
    required this.expression,
    required this.colorIndex,
    this.visible = true,
    this.type = GraphFunctionType.function,
    this.variableName,
    this.constantValue,
  });

  GraphFunction copyWith({
    String? expression,
    int? colorIndex,
    bool? visible,
    GraphFunctionType? type,
    String? variableName,
    double? constantValue,
  }) {
    return GraphFunction(
      expression: expression ?? this.expression,
      colorIndex: colorIndex ?? this.colorIndex,
      visible: visible ?? this.visible,
      type: type ?? this.type,
      variableName: variableName ?? this.variableName,
      constantValue: constantValue ?? this.constantValue,
    );
  }
}

enum GraphFunctionType { function, verticalLine, horizontalLine, parametric }

class GraphParsedExpression {
  final GraphFunctionType type;
  final String expression;
  final String? variableName;
  final double? constantValue;

  GraphParsedExpression({
    required this.type,
    required this.expression,
    this.variableName,
    this.constantValue,
  });
}

extension GraphFunctionTypeExtension on GraphFunctionType {
  String get displayName {
    switch (this) {
      case GraphFunctionType.function:
        return 'f(x)';
      case GraphFunctionType.verticalLine:
        return 'x = const';
      case GraphFunctionType.horizontalLine:
        return 'y = const';
      case GraphFunctionType.parametric:
        return 'parametric';
    }
  }
}

enum CalcMode {
  eval,
  derive,
  integrate,
  solve,
  limit,
  simplify,
  inequality,
  interval,
}

extension CalcModeExtension on CalcMode {
  String get example {
    switch (this) {
      case CalcMode.eval:
        return '2+3*sin(pi/4)';
      case CalcMode.derive:
        return 'x^2+3*x';
      case CalcMode.integrate:
        return 'x^2 | 0..1';
      case CalcMode.solve:
        return 'x^2-4=0';
      case CalcMode.limit:
        return 'sin(x)/x | x→0';
      case CalcMode.simplify:
        return '(x+1)^2';
      case CalcMode.inequality:
        return 'x^2-4<0';
      case CalcMode.interval:
        return '[0, 5]';
    }
  }
}
