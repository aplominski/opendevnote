import 'package:math_expressions/math_expressions.dart';
import 'package:opendevnote/models/calc_models.dart';

class MathEngine {
  static final _parser = GrammarParser();

  // Parse graph expression and determine its type
  static GraphParsedExpression parseGraphExpression(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return GraphParsedExpression(
        type: GraphFunctionType.function,
        expression: '',
      );
    }

    // Check for vertical line: x=2, t=1, a=5
    final verticalMatch = RegExp(
      r'^([a-zA-Z])\s*=\s*(-?[\d.]+)$',
    ).firstMatch(trimmed);
    if (verticalMatch != null) {
      final varName = verticalMatch.group(1)!;
      final value = double.tryParse(verticalMatch.group(2)!) ?? 0;
      return GraphParsedExpression(
        type: GraphFunctionType.verticalLine,
        expression: trimmed,
        variableName: varName,
        constantValue: value,
      );
    }

    // Check for horizontal line: y=3, f(x)=2 (when just constant)
    final horizontalMatch = RegExp(
      r'^[yf]\s*=\s*(-?[\d.]+)$',
    ).firstMatch(trimmed);
    if (horizontalMatch != null) {
      final value = double.tryParse(horizontalMatch.group(1)!) ?? 0;
      return GraphParsedExpression(
        type: GraphFunctionType.horizontalLine,
        expression: trimmed,
        constantValue: value,
      );
    }

    // Check for parametric: x=2t, y=sin(t)
    final parametricMatch = RegExp(r'^([xy])\s*=\s*(.+)$').firstMatch(trimmed);
    if (parametricMatch != null) {
      return GraphParsedExpression(
        type: GraphFunctionType.parametric,
        expression: parametricMatch.group(2)!,
        variableName: parametricMatch.group(1)!,
      );
    }

    // Check for function definition: f(x)=4x^2
    final funcMatch = RegExp(
      r'^[fg]\s*\([a-z]\)\s*=\s*(.+)$',
      caseSensitive: false,
    ).firstMatch(trimmed);
    if (funcMatch != null) {
      return GraphParsedExpression(
        type: GraphFunctionType.function,
        expression: funcMatch.group(1)!,
      );
    }

    // Default: treat as function of x
    return GraphParsedExpression(
      type: GraphFunctionType.function,
      expression: trimmed,
    );
  }

  // Evaluate expression
  static String evaluate(String input, {Map<String, double>? vars}) {
    try {
      final expr = _parseExpression(input);
      if (expr == null) return 'Błąd składni';
      final context = ContextModel();
      if (vars != null) {
        for (final entry in vars.entries) {
          context.bindVariable(Variable(entry.key), Number(entry.value));
        }
      }
      final result = expr.evaluate(EvaluationType.REAL, context);
      if (result is num) {
        if (result.isInfinite) return '∞';
        if (result.isNaN) return 'Nieokreślone';
        return _formatNumber(result.toDouble());
      }
      return result.toString();
    } catch (e) {
      return 'Błąd: ${e.toString().replaceFirst('Exception: ', '')}';
    }
  }

  // Derive symbolically
  static String derive(String input, String variable) {
    try {
      final expr = _parseExpression(input);
      if (expr == null) return 'Błąd składni';
      final derived = expr.derive(variable);
      final simplified = derived.simplify();
      return simplified.toString();
    } catch (e) {
      return 'Błąd: ${e.toString().replaceFirst('Exception: ', '')}';
    }
  }

  // Simplify
  static String simplify(String input) {
    try {
      final expr = _parseExpression(input);
      if (expr == null) return 'Błąd składni';
      final simplified = expr.simplify();
      return simplified.toString();
    } catch (e) {
      return 'Błąd: ${e.toString().replaceFirst('Exception: ', '')}';
    }
  }

  // Integrate numerically (Simpson's rule)
  static String integrate(String input, String variable, double a, double b) {
    try {
      final expr = _parseExpression(input);
      if (expr == null) return 'Błąd składni';
      final context = ContextModel();
      const n = 1000;
      final h = (b - a) / n;
      double sum = 0;
      for (int i = 0; i <= n; i++) {
        final x = a + i * h;
        context.bindVariable(Variable(variable), Number(x));
        final y = expr.evaluate(EvaluationType.REAL, context);
        if (y is! num) return 'Błąd';
        double weight;
        if (i == 0 || i == n) {
          weight = 1;
        } else if (i % 2 == 0) {
          weight = 2;
        } else {
          weight = 4;
        }
        sum += weight * y.toDouble();
      }
      final result = (h / 3) * sum;
      return _formatNumber(result);
    } catch (e) {
      return 'Błąd: ${e.toString().replaceFirst('Exception: ', '')}';
    }
  }

  // Solve equation numerically (Newton's method)
  static String solve(String input, {String variable = 'x'}) {
    try {
      String lhs, rhs;
      if (input.contains('=')) {
        final parts = input.split('=');
        lhs = parts[0].trim();
        rhs = parts[1].trim();
      } else {
        lhs = input;
        rhs = '0';
      }

      // Try to parse expressions
      final lhsExpr = _parseExpression(lhs);
      final rhsExpr = _parseExpression(rhs);

      if (lhsExpr == null) {
        return 'Błąd składni (lewa strona): $lhs';
      }
      if (rhsExpr == null) {
        return 'Błąd składni (prawa strona): $rhs';
      }

      final context = ContextModel();

      // Find roots using Newton's method from multiple starting points
      final roots = <double>[];
      for (double start = -50; start <= 50; start += 5) {
        double x = start;
        bool converged = false;
        for (int i = 0; i < 100; i++) {
          context.bindVariable(Variable(variable), Number(x));
          final f =
              lhsExpr.evaluate(EvaluationType.REAL, context) -
              rhsExpr.evaluate(EvaluationType.REAL, context);

          const dx = 1e-8;
          context.bindVariable(Variable(variable), Number(x + dx));
          final fp =
              lhsExpr.evaluate(EvaluationType.REAL, context) -
              rhsExpr.evaluate(EvaluationType.REAL, context);

          if (f is! num || fp is! num) break;
          final df = (fp.toDouble() - f.toDouble()) / dx;
          if (df.abs() < 1e-12) break;
          x = x - f.toDouble() / df;

          if (f.toDouble().abs() < 1e-10) {
            converged = true;
            break;
          }
        }
        if (converged) {
          // Check if this root is already found
          final isDuplicate = roots.any((r) => (r - x).abs() < 1e-6);
          if (!isDuplicate) roots.add(x);
        }
      }

      if (roots.isEmpty) return 'Brak rozwiązań';
      roots.sort();
      return roots.map((r) => '$variable = ${_formatNumber(r)}').join(', ');
    } catch (e) {
      return 'Błąd: ${e.toString().replaceFirst('Exception: ', '')}';
    }
  }

  // Limit numerically
  static String limit(String input, String variable, double point) {
    try {
      final expr = _parseExpression(input);
      if (expr == null) return 'Błąd składni';
      final context = ContextModel();

      // Approach from both sides
      double h = 1e-8;
      context.bindVariable(Variable(variable), Number(point + h));
      final right = expr.evaluate(EvaluationType.REAL, context);
      context.bindVariable(Variable(variable), Number(point - h));
      final left = expr.evaluate(EvaluationType.REAL, context);

      if (right is! num || left is! num) return 'Nieokreślone';
      if ((right.toDouble() - left.toDouble()).abs() < 1e-6) {
        return _formatNumber(right.toDouble());
      }
      return 'Nie istnieje (lewa: ${_formatNumber(left.toDouble())}, prawa: ${_formatNumber(right.toDouble())})';
    } catch (e) {
      return 'Błąd: ${e.toString().replaceFirst('Exception: ', '')}';
    }
  }

  // Solve inequality
  static String solveInequality(String input, {String variable = 'x'}) {
    try {
      // Parse inequality: find the operator
      String operator;
      String lhs, rhs;

      if (input.contains('>=')) {
        operator = '>=';
        final parts = input.split('>=');
        lhs = parts[0].trim();
        rhs = parts[1].trim();
      } else if (input.contains('<=')) {
        operator = '<=';
        final parts = input.split('<=');
        lhs = parts[0].trim();
        rhs = parts[1].trim();
      } else if (input.contains('>')) {
        operator = '>';
        final parts = input.split('>');
        lhs = parts[0].trim();
        rhs = parts[1].trim();
      } else if (input.contains('<')) {
        operator = '<';
        final parts = input.split('<');
        lhs = parts[0].trim();
        rhs = parts[1].trim();
      } else {
        return 'Błąd: brak operatora nierówności (>, <, >=, <=)';
      }

      // Parse both sides
      final lhsExpr = _parseExpression(lhs);
      final rhsExpr = _parseExpression(rhs);

      if (lhsExpr == null) {
        return 'Błąd składni (lewa strona): $lhs';
      }
      if (rhsExpr == null) {
        return 'Błąd składni (prawa strona): $rhs';
      }

      // Create expression: lhs - rhs
      final diffExpr = lhsExpr - rhsExpr;

      // Find roots of the difference
      final roots = _findRootsFromExpression(diffExpr, variable);

      if (roots.isEmpty) {
        // Check if the inequality is always true or false
        final context = ContextModel();
        context.bindVariable(Variable(variable), Number(0.0));
        final testValue = diffExpr.evaluate(EvaluationType.REAL, context);
        if (testValue is num) {
          final alwaysTrue = (operator == '>' || operator == '>=')
              ? testValue > 0
              : testValue < 0;
          if (alwaysTrue) return 'x ∈ ℝ';
          return 'Brak rozwiązań';
        }
        return 'Błąd';
      }

      // Build solution intervals
      final solutions = <String>[];
      roots.sort();

      // Test intervals between roots
      final testPoints = <double>[];
      if (roots.first > -100) testPoints.add(roots.first - 1);
      for (int i = 0; i < roots.length - 1; i++) {
        testPoints.add((roots[i] + roots[i + 1]) / 2);
      }
      if (roots.last < 100) testPoints.add(roots.last + 1);

      final context = ContextModel();
      for (final point in testPoints) {
        context.bindVariable(Variable(variable), Number(point));
        final value = diffExpr.evaluate(EvaluationType.REAL, context);
        if (value is num) {
          final satisfies = (operator == '>' || operator == '>=')
              ? value > 0
              : value < 0;
          if (satisfies) {
            solutions.add(_formatIntervalFromPoint(point, roots));
          }
        }
      }

      if (solutions.isEmpty) return 'Brak rozwiązań';
      return 'x ∈ ${solutions.join(' ∪ ')}';
    } catch (e) {
      return 'Błąd: ${e.toString().replaceFirst('Exception: ', '')}';
    }
  }

  // Find roots from an Expression object
  static List<double> _findRootsFromExpression(
    Expression expr,
    String variable,
  ) {
    final roots = <double>[];
    try {
      final context = ContextModel();

      // Find roots using Newton's method from multiple starting points
      for (double start = -50; start <= 50; start += 5) {
        double x = start;
        bool converged = false;
        for (int i = 0; i < 100; i++) {
          context.bindVariable(Variable(variable), Number(x));
          final f = expr.evaluate(EvaluationType.REAL, context);

          const dx = 1e-8;
          context.bindVariable(Variable(variable), Number(x + dx));
          final fp = expr.evaluate(EvaluationType.REAL, context);

          if (f is! num || fp is! num) break;
          final df = (fp.toDouble() - f.toDouble()) / dx;
          if (df.abs() < 1e-12) break;
          x = x - f.toDouble() / df;

          if (f.toDouble().abs() < 1e-10) {
            converged = true;
            break;
          }
        }
        if (converged) {
          final isDuplicate = roots.any((r) => (r - x).abs() < 1e-6);
          if (!isDuplicate) roots.add(x);
        }
      }
    } catch (_) {}
    return roots;
  }

  // Format interval based on test point and roots
  static String _formatIntervalFromPoint(double point, List<double> roots) {
    if (point < roots.first) {
      return '(-∞, ${_formatNumber(roots.first)})';
    } else if (point > roots.last) {
      return '(${_formatNumber(roots.last)}, ∞)';
    } else {
      for (int i = 0; i < roots.length - 1; i++) {
        if (point > roots[i] && point < roots[i + 1]) {
          return '(${_formatNumber(roots[i])}, ${_formatNumber(roots[i + 1])})';
        }
      }
    }
    return '';
  }

  // Solve interval
  static String solveInterval(String input) {
    try {
      // Parse interval: [a, b], (a, b), [a, b), (a, b]
      final trimmed = input.trim();
      if (!trimmed.startsWith('[') && !trimmed.startsWith('(')) {
        return 'Format: [a, b] lub (a, b)';
      }

      final openLeft = trimmed.startsWith('(');
      final openRight = trimmed.endsWith(')');

      final inner = trimmed.substring(1, trimmed.length - 1).trim();
      final parts = inner.split(',');
      if (parts.length != 2) return 'Format: [a, b] lub (a, b)';

      final a = double.tryParse(parts[0].trim());
      final b = double.tryParse(parts[1].trim());

      if (a == null || b == null) return 'Błąd: nieprawidłowe liczby';
      if (a > b) return 'Błąd: a > b';

      final leftBracket = openLeft ? '(' : '[';
      final rightBracket = openRight ? ')' : ']';

      return '$leftBracket${_formatNumber(a)}, ${_formatNumber(b)}$rightBracket';
    } catch (e) {
      return 'Błąd: ${e.toString().replaceFirst('Exception: ', '')}';
    }
  }

  // Set operations
  static List<dynamic> setOperation(
    String op,
    List<dynamic> a,
    List<dynamic> b,
  ) {
    final setA = a.toSet();
    final setB = b.toSet();
    switch (op) {
      case 'union':
        return setA.union(setB).toList()..sort();
      case 'intersect':
        return setA.intersection(setB).toList()..sort();
      case 'diff':
        return setA.difference(setB).toList()..sort();
      default:
        return [];
    }
  }

  // Base conversion
  static String convertBase(String value, int fromBase, int toBase) {
    try {
      final parsed = int.parse(value, radix: fromBase);
      switch (toBase) {
        case 2:
          return parsed.toRadixString(2);
        case 8:
          return parsed.toRadixString(8);
        case 10:
          return parsed.toString();
        case 16:
          return parsed.toRadixString(16).toUpperCase();
        default:
          return parsed.toRadixString(toBase);
      }
    } catch (e) {
      return 'Błąd';
    }
  }

  // Parse expression helper
  static Expression? _parseExpression(String input) {
    try {
      // Pre-process the input
      var processed = _preprocessExpression(input);
      processed = _addImplicitMultiplication(processed);
      return _parser.parse(processed);
    } catch (_) {
      return null;
    }
  }

  // Preprocess expression to handle special cases
  static String _preprocessExpression(String input) {
    var result = input;

    // Handle function powers: cos^2(x) -> (cos(x))^2
    final functions = [
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'ln',
      'log',
      'sqrt',
      'abs',
      'exp',
      'ceil',
      'floor',
      'sgn',
    ];

    for (final func in functions) {
      final pattern = RegExp(
        '${func}'
        r'\^(\d+)\(',
      );
      while (pattern.hasMatch(result)) {
        int start = 0;
        bool found = false;
        while (start < result.length) {
          final match = pattern.matchAsPrefix(result, start);
          if (match == null) {
            start++;
            continue;
          }
          final funcStart = match.start;
          final powerStr = match.group(1)!;
          final openParen = match.end - 1;

          int depth = 1;
          int closeParen = openParen + 1;
          while (closeParen < result.length && depth > 0) {
            if (result[closeParen] == '(') depth++;
            if (result[closeParen] == ')') depth--;
            closeParen++;
          }

          if (depth == 0) {
            final arg = result.substring(openParen, closeParen);
            final before = result.substring(0, funcStart);
            final after = result.substring(closeParen);
            result = '$before($func$arg)^$powerStr$after';
            found = true;
            break;
          } else {
            break;
          }
        }
        if (!found) break;
      }
    }

    // Handle negative exponents: 2^-2 -> 2^(-2)
    final negExpRegex = RegExp(r'(\d+\.?\d*|[a-z]|\))\^-(\d+\.?\d*)');
    result = result.replaceAllMapped(negExpRegex, (match) {
      final base = match.group(1)!;
      final exp = match.group(2)!;
      return '$base^(-$exp)';
    });

    return result;
  }

  // Add implicit multiplication (e.g., 2x -> 2*x, 3(x+1) -> 3*(x+1))
  // But preserve function calls like sin(x), cos(x), etc.
  static String _addImplicitMultiplication(String input) {
    final result = StringBuffer();
    final functions = [
      'sin',
      'cos',
      'tan',
      'asin',
      'acos',
      'atan',
      'ln',
      'log',
      'sqrt',
      'abs',
      'exp',
      'ceil',
      'floor',
      'sgn',
    ];

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      result.write(char);

      // Add * after digit if followed by letter (but not part of function name)
      if (_isDigit(char) && i + 1 < input.length) {
        final next = input[i + 1];
        if (_isLetter(next)) {
          // Check if this is not a function call
          result.write('*');
        } else if (next == '(') {
          result.write('*');
        }
      }

      // Add * after ) if followed by digit, letter, or (
      if (char == ')' && i + 1 < input.length) {
        final next = input[i + 1];
        if (_isDigit(next) || _isLetter(next) || next == '(') {
          result.write('*');
        }
      }

      // Add * after letter if followed by digit or (
      // BUT skip if this letter is part of a function name
      if (_isLetter(char) && i + 1 < input.length) {
        final next = input[i + 1];
        if (next == '(') {
          // Check if preceding letters form a function name
          final start = i;
          int j = i;
          while (j > 0 && _isLetter(input[j - 1])) {
            j--;
          }
          final name = input.substring(j, start + 1);
          if (!functions.any((f) => f == name)) {
            result.write('*');
          }
        } else if (_isDigit(next)) {
          result.write('*');
        }
      }
    }
    return result.toString();
  }

  static bool _isDigit(String char) {
    return char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;
  }

  static bool _isLetter(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  // Format number
  static String _formatNumber(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    // Remove trailing zeros
    final str = value.toStringAsPrecision(10);
    if (str.contains('.')) {
      return str
          .replaceFirst(RegExp(r'0+$'), '')
          .replaceFirst(RegExp(r'\.$'), '');
    }
    return str;
  }
}
