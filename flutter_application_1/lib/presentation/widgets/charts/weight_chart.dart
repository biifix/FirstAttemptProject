import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../domain/models/weight_entry.dart';

/// Widget displaying weight trend chart (Single Responsibility)
class WeightChart extends StatelessWidget {
  final List<WeightEntry> entries;
  final int period; // 0: Day, 1: Month, 2: Year
  final Function(WeightEntry)? onDataPointTap;

  const WeightChart({
    super.key,
    required this.entries,
    required this.period,
    this.onDataPointTap,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        height: 250,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'No weight data yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ),
      );
    }

    return Container(
      height: 300,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTapUp: (details) => _handleTap(details.localPosition),
        child: CustomPaint(
          painter: WeightChartPainter(
            entries: entries,
            period: period,
          ),
          child: Container(),
        ),
      ),
    );
  }

  void _handleTap(Offset position) {
    if (onDataPointTap == null || entries.isEmpty) return;

    // Calculate the actual chart area (accounting for padding and axis space)
    const leftMargin = 40.0; // Space for Y-axis labels
    const bottomMargin = 30.0; // Space for X-axis labels
    const rightMargin = 16.0;
    const topMargin = 16.0;

    final chartWidth = 300 - leftMargin - rightMargin;
    final chartHeight = 300 - topMargin - bottomMargin;

    // Adjust position for margins
    final adjustedX = position.dx - leftMargin;
    final adjustedY = position.dy - topMargin;

    // Check if tap is within chart bounds
    if (adjustedX < 0 || adjustedX > chartWidth || adjustedY < 0 || adjustedY > chartHeight) {
      return;
    }

    // Calculate which data point was tapped
    final tapRadius = 30.0; // Increased tap area
    for (int i = 0; i < entries.length; i++) {
      final x = chartWidth * (i / (entries.length - 1));

      // Calculate y position (same logic as in painter)
      final weights = entries.map((e) => e.weight).toList();
      final minWeight = weights.reduce(math.min) - 2;
      final maxWeight = weights.reduce(math.max) + 2;
      final range = maxWeight - minWeight;
      final normalizedWeight = (entries[i].weight - minWeight) / range;
      final y = chartHeight - (chartHeight * normalizedWeight);

      // Check if tap is within radius of this point
      final distance = math.sqrt(math.pow(adjustedX - x, 2) + math.pow(adjustedY - y, 2));
      if (distance <= tapRadius) {
        onDataPointTap!(entries[i]);
        return;
      }
    }
  }
}

class WeightChartPainter extends CustomPainter {
  final List<WeightEntry> entries;
  final int period;

  WeightChartPainter({
    required this.entries,
    required this.period,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    const leftMargin = 40.0;
    const bottomMargin = 30.0;
    const rightMargin = 0.0;
    const topMargin = 10.0;

    final chartWidth = size.width - leftMargin - rightMargin;
    final chartHeight = size.height - topMargin - bottomMargin;

    final weights = entries.map((e) => e.weight).toList();
    final minWeight = weights.reduce(math.min) - 2;
    final maxWeight = weights.reduce(math.max) + 2;
    final range = maxWeight - minWeight;

    _drawAxes(canvas, size, leftMargin, bottomMargin, topMargin, chartWidth, chartHeight);
    _drawYAxisLabels(canvas, leftMargin, topMargin, chartHeight, minWeight, maxWeight);
    _drawXAxisLabels(canvas, leftMargin, topMargin, chartWidth, chartHeight);
    _drawGridLines(canvas, leftMargin, topMargin, chartWidth, chartHeight);
    _drawCurve(canvas, leftMargin, topMargin, chartWidth, chartHeight, minWeight, range);
  }

  void _drawAxes(Canvas canvas, Size size, double leftMargin, double bottomMargin,
                 double topMargin, double chartWidth, double chartHeight) {
    final axisPaint = Paint()
      ..color = const Color(0xFF8E8E93)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(leftMargin, topMargin),
      Offset(leftMargin, topMargin + chartHeight),
      axisPaint,
    );

    canvas.drawLine(
      Offset(leftMargin, topMargin + chartHeight),
      Offset(leftMargin + chartWidth, topMargin + chartHeight),
      axisPaint,
    );
  }

  void _drawYAxisLabels(Canvas canvas, double leftMargin, double topMargin,
                        double chartHeight, double minWeight, double maxWeight) {
    final textStyle = const TextStyle(
      color: Color(0xFF8E8E93),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i <= 4; i++) {
      final weight = minWeight + (maxWeight - minWeight) * (i / 4);
      final y = topMargin + chartHeight - (chartHeight * (i / 4));

      final textSpan = TextSpan(
        text: '${weight.toStringAsFixed(1)}',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftMargin - textPainter.width - 8, y - textPainter.height / 2),
      );
    }
  }

  void _drawXAxisLabels(Canvas canvas, double leftMargin, double topMargin,
                        double chartWidth, double chartHeight) {
    final textStyle = const TextStyle(
      color: Color(0xFF8E8E93),
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    List<String> labels = [];
    List<int> indices = [];

    if (period == 2) {
      labels = _getMonthlyLabels();
      indices = _getMonthlyIndices();
    } else if (period == 1) {
      labels = _getDayLabels();
      indices = _getDayIndices();
    } else {
      labels = _getSimplifiedLabels();
      indices = _getSimplifiedIndices();
    }

    for (int i = 0; i < labels.length && i < indices.length; i++) {
      final index = indices[i];
      if (index >= entries.length) continue;

      final x = leftMargin + (chartWidth * (index / (entries.length - 1)));
      final y = topMargin + chartHeight + 5;

      final textSpan = TextSpan(text: labels[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y),
      );
    }
  }

  List<String> _getDayLabels() {
    final step = math.max(1, entries.length ~/ 4);
    return List.generate(
      math.min(5, (entries.length / step).ceil()),
      (i) {
        final index = i * step;
        if (index >= entries.length) return '';
        return '${entries[index].date.day}';
      },
    );
  }

  List<int> _getDayIndices() {
    final step = math.max(1, entries.length ~/ 4);
    return List.generate(
      math.min(5, (entries.length / step).ceil()),
      (i) => i * step,
    );
  }

  List<String> _getMonthlyLabels() {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final seen = <int>{};
    final labels = <String>[];

    for (final entry in entries) {
      if (!seen.contains(entry.date.month)) {
        seen.add(entry.date.month);
        labels.add(months[entry.date.month - 1]);
      }
    }

    return labels;
  }

  List<int> _getMonthlyIndices() {
    final seen = <int>{};
    final indices = <int>[];

    for (int i = 0; i < entries.length; i++) {
      if (!seen.contains(entries[i].date.month)) {
        seen.add(entries[i].date.month);
        indices.add(i);
      }
    }

    return indices;
  }

  List<String> _getSimplifiedLabels() {
    if (entries.length <= 3) {
      return entries.map((e) => '${e.date.day}').toList();
    }
    return [
      '${entries.first.date.day}',
      '${entries[entries.length ~/ 2].date.day}',
      '${entries.last.date.day}',
    ];
  }

  List<int> _getSimplifiedIndices() {
    if (entries.length <= 3) {
      return List.generate(entries.length, (i) => i);
    }
    return [0, entries.length ~/ 2, entries.length - 1];
  }

  void _drawGridLines(Canvas canvas, double leftMargin, double topMargin,
                      double chartWidth, double chartHeight) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E5EA)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = topMargin + chartHeight * (i / 4);
      canvas.drawLine(
        Offset(leftMargin, y),
        Offset(leftMargin + chartWidth, y),
        gridPaint,
      );
    }
  }

  void _drawCurve(Canvas canvas, double leftMargin, double topMargin,
                  double chartWidth, double chartHeight, double minWeight, double range) {
    final linePaint = Paint()
      ..color = const Color(0xFF34C759)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = const Color(0xFF34C759)
      ..style = PaintingStyle.fill;

    final pointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final points = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      final x = leftMargin + (chartWidth * (i / (entries.length - 1)));
      final normalizedWeight = (entries[i].weight - minWeight) / range;
      final y = topMargin + chartHeight - (chartHeight * normalizedWeight);
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      // Draw straight lines between points
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], linePaint);
      }

      // Draw data points on top
      for (final point in points) {
        canvas.drawCircle(point, 5, pointPaint);
        canvas.drawCircle(point, 5, pointBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
