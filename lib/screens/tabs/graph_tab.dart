import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:opendevnote/l10n/app_localizations.dart';
import 'package:opendevnote/models/calc_models.dart';
import 'package:opendevnote/providers/calculator_provider.dart';
import 'package:opendevnote/services/math_engine.dart';

class GraphTab extends ConsumerStatefulWidget {
  const GraphTab({super.key});

  @override
  ConsumerState<GraphTab> createState() => _GraphTabState();
}

class _GraphTabState extends ConsumerState<GraphTab> {
  final _controllers = <TextEditingController>[];

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final graphState = ref.watch(graphProvider);
    final colorScheme = Theme.of(context).colorScheme;

    while (_controllers.length < graphState.functions.length) {
      _controllers.add(
        TextEditingController(
          text: graphState.functions[_controllers.length].expression,
        ),
      );
    }
    while (_controllers.length > graphState.functions.length) {
      _controllers.removeLast().dispose();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              ...graphState.functions.asMap().entries.map((entry) {
                final i = entry.key;
                final func = entry.value;
                final colors = [
                  Colors.blue,
                  Colors.red,
                  Colors.green,
                  Colors.purple,
                  Colors.orange,
                  Colors.teal,
                ];
                final color = colors[func.colorIndex % colors.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controllers[i],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                            hintText: 'x^2, sin(x), t=2, y=3',
                          ),
                          onSubmitted: (v) => ref
                              .read(graphProvider.notifier)
                              .updateFunction(i, v),
                          onChanged: (v) => ref
                              .read(graphProvider.notifier)
                              .updateFunction(i, v),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          func.visible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 16,
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: () =>
                            ref.read(graphProvider.notifier).toggleFunction(i),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        visualDensity: VisualDensity.compact,
                        onPressed: () =>
                            ref.read(graphProvider.notifier).removeFunction(i),
                      ),
                    ],
                  ),
                );
              }),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(graphProvider.notifier).addFunction('');
                    _controllers.add(TextEditingController(text: ''));
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    l10n.converterAddFunction,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return MouseRegion(
                onHover: (event) {
                  final x =
                      graphState.xMin +
                      (event.localPosition.dx / constraints.maxWidth) *
                          (graphState.xMax - graphState.xMin);
                  final y =
                      graphState.yMax -
                      (event.localPosition.dy / constraints.maxHeight) *
                          (graphState.yMax - graphState.yMin);

                  IntersectionPoint? closest;
                  double minDist = 0.5;

                  for (final point in graphState.intersections) {
                    final dist =
                        ((point.x - x).abs() + (point.y - y).abs()) / 2;
                    if (dist < minDist) {
                      minDist = dist;
                      closest = point;
                    }
                  }

                  ref
                      .read(graphProvider.notifier)
                      .setHoveredIntersection(closest);
                },
                onExit: (_) {
                  ref.read(graphProvider.notifier).setHoveredIntersection(null);
                },
                child: GestureDetector(
                  onScaleUpdate: (details) {
                    if (details.scale != 1.0) {
                      ref.read(graphProvider.notifier).zoom(1 / details.scale);
                    } else if (details.focalPointDelta != Offset.zero) {
                      ref
                          .read(graphProvider.notifier)
                          .pan(
                            details.focalPointDelta.dx,
                            details.focalPointDelta.dy,
                            constraints.maxWidth,
                            constraints.maxHeight,
                          );
                    }
                  },
                  onTapUp: (details) {
                    final x =
                        graphState.xMin +
                        (details.localPosition.dx / constraints.maxWidth) *
                            (graphState.xMax - graphState.xMin);
                    final y =
                        graphState.yMax -
                        (details.localPosition.dy / constraints.maxHeight) *
                            (graphState.yMax - graphState.yMin);
                    ref
                        .read(graphProvider.notifier)
                        .setTappedPoint(Offset(x, y));
                  },
                  child: ClipRect(
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _GraphPainter(
                        functions: graphState.functions,
                        xMin: graphState.xMin,
                        xMax: graphState.xMax,
                        yMin: graphState.yMin,
                        yMax: graphState.yMax,
                        tappedPoint: graphState.tappedPoint,
                        intersections: graphState.intersections,
                        hoveredIntersection: graphState.hoveredIntersection,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.zoom_in, size: 20),
                onPressed: () => ref.read(graphProvider.notifier).zoom(0.8),
              ),
              IconButton(
                icon: const Icon(Icons.zoom_out, size: 20),
                onPressed: () => ref.read(graphProvider.notifier).zoom(1.25),
              ),
              IconButton(
                icon: const Icon(Icons.center_focus_strong, size: 20),
                onPressed: () =>
                    ref.read(graphProvider.notifier).resetViewport(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GraphPainter extends CustomPainter {
  final List<GraphFunction> functions;
  final double xMin, xMax, yMin, yMax;
  final Offset? tappedPoint;
  final List<IntersectionPoint> intersections;
  final IntersectionPoint? hoveredIntersection;
  final ColorScheme colorScheme;

  _GraphPainter({
    required this.functions,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
    this.tappedPoint,
    this.intersections = const [],
    this.hoveredIntersection,
    required this.colorScheme,
  });

  static const _functionColors = [
    Color(0xFF2196F3),
    Color(0xFFF44336),
    Color(0xFF4CAF50),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
    Color(0xFF009688),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = colorScheme.surface;
    canvas.drawRect(Offset.zero & size, bgPaint);

    _drawGrid(canvas, size);
    _drawAxes(canvas, size);

    for (int i = 0; i < functions.length; i++) {
      final func = functions[i];
      if (!func.visible) continue;
      final color = _functionColors[func.colorIndex % _functionColors.length];
      final parsed = MathEngine.parseGraphExpression(func.expression);

      switch (parsed.type) {
        case GraphFunctionType.verticalLine:
          _drawVerticalLine(canvas, size, parsed.constantValue ?? 0, color);
          break;
        case GraphFunctionType.horizontalLine:
          _drawHorizontalLine(canvas, size, parsed.constantValue ?? 0, color);
          break;
        case GraphFunctionType.function:
        case GraphFunctionType.parametric:
          _drawFunction(canvas, size, parsed.expression, color);
          break;
      }
    }

    if (tappedPoint != null) {
      final sx = ((tappedPoint!.dx - xMin) / (xMax - xMin)) * size.width;
      final sy = ((yMax - tappedPoint!.dy) / (yMax - yMin)) * size.height;

      final dotPaint = Paint()
        ..color = colorScheme.primary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(sx, sy), 5, dotPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text:
              '(${tappedPoint!.dx.toStringAsFixed(2)}, ${tappedPoint!.dy.toStringAsFixed(2)})',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(sx + 8, sy - textPainter.height - 4));
    }

    for (final point in intersections) {
      final sx = ((point.x - xMin) / (xMax - xMin)) * size.width;
      final sy = ((yMax - point.y) / (yMax - yMin)) * size.height;

      final isHovered =
          hoveredIntersection != null &&
          (hoveredIntersection!.x - point.x).abs() < 0.001 &&
          (hoveredIntersection!.y - point.y).abs() < 0.001;

      final dotPaint = Paint()
        ..color = isHovered ? colorScheme.primary : colorScheme.onSurface
        ..style = PaintingStyle.fill;

      final radius = isHovered ? 8.0 : 5.0;
      canvas.drawCircle(Offset(sx, sy), radius, dotPaint);

      final outlinePaint = Paint()
        ..color = colorScheme.surface
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(sx, sy), radius, outlinePaint);

      if (isHovered) {
        final textPainter = TextPainter(
          text: TextSpan(
            text:
                '(${point.x.toStringAsFixed(3)}, ${point.y.toStringAsFixed(3)})',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'monospace',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final labelY = sy - textPainter.height - 12;
        final labelX = sx - textPainter.width / 2;

        final bgPaint = Paint()
          ..color = colorScheme.surfaceContainerHigh
          ..style = PaintingStyle.fill;
        final bgRect = Rect.fromLTWH(
          labelX - 4,
          labelY - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(bgRect, const Radius.circular(4)),
          bgPaint,
        );

        textPainter.paint(canvas, Offset(labelX, labelY));
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;

    final xRange = xMax - xMin;
    final yRange = yMax - yMin;

    final xStep = _niceStep(xRange / 10);
    final yStep = _niceStep(yRange / 10);

    final xStart = (xMin / xStep).ceil() * xStep;
    for (double x = xStart; x <= xMax; x += xStep) {
      final sx = ((x - xMin) / xRange) * size.width;
      canvas.drawLine(Offset(sx, 0), Offset(sx, size.height), gridPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: x.toStringAsFixed(x == x.roundToDouble() ? 0 : 1),
          style: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(sx + 2, size.height - 14));
    }

    final yStart = (yMin / yStep).ceil() * yStep;
    for (double y = yStart; y <= yMax; y += yStep) {
      final sy = ((yMax - y) / yRange) * size.height;
      canvas.drawLine(Offset(0, sy), Offset(size.width, sy), gridPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: y.toStringAsFixed(y == y.roundToDouble() ? 0 : 1),
          style: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(2, sy - textPainter.height - 2));
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;

    final xRange = xMax - xMin;
    final yRange = yMax - yMin;

    if (yMin <= 0 && yMax >= 0) {
      final sy = (yMax / yRange) * size.height;
      canvas.drawLine(Offset(0, sy), Offset(size.width, sy), axisPaint);
    }

    if (xMin <= 0 && xMax >= 0) {
      final sx = (-xMin / xRange) * size.width;
      canvas.drawLine(Offset(sx, 0), Offset(sx, size.height), axisPaint);
    }
  }

  void _drawVerticalLine(Canvas canvas, Size size, double xValue, Color color) {
    if (xValue < xMin || xValue > xMax) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final xRange = xMax - xMin;
    final sx = ((xValue - xMin) / xRange) * size.width;
    canvas.drawLine(Offset(sx, 0), Offset(sx, size.height), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'x=$xValue',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(sx + 4, 4));
  }

  void _drawHorizontalLine(
    Canvas canvas,
    Size size,
    double yValue,
    Color color,
  ) {
    if (yValue < yMin || yValue > yMax) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final yRange = yMax - yMin;
    final sy = ((yMax - yValue) / yRange) * size.height;
    canvas.drawLine(Offset(0, sy), Offset(size.width, sy), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'y=$yValue',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(4, sy - textPainter.height - 2));
  }

  void _drawFunction(Canvas canvas, Size size, String expression, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final xRange = xMax - xMin;
    final yRange = yMax - yMin;
    final steps = size.width.toInt();
    bool started = false;

    for (int i = 0; i <= steps; i++) {
      final x = xMin + (i / steps) * xRange;
      final yStr = MathEngine.evaluate(expression, vars: {'x': x});
      final y = double.tryParse(yStr);

      if (y == null || y.isNaN || y.isInfinite) {
        started = false;
        continue;
      }

      final sx = (i / steps) * size.width;
      final sy = ((yMax - y) / yRange) * size.height;

      if (!started || sy < -1000 || sy > size.height + 1000) {
        path.moveTo(sx, sy.clamp(-1000, size.height + 1000));
        started = true;
      } else {
        path.lineTo(sx, sy.clamp(-1000, size.height + 1000));
      }
    }

    canvas.drawPath(path, paint);
  }

  double _niceStep(double rough) {
    final pow = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    final norm = rough / pow;
    if (norm <= 1) return pow;
    if (norm <= 2) return 2 * pow;
    if (norm <= 5) return 5 * pow;
    return 10 * pow;
  }

  @override
  bool shouldRepaint(covariant _GraphPainter old) {
    return true;
  }
}
