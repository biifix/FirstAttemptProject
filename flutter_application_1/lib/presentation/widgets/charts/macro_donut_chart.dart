import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget displaying macro distribution as a donut chart (Single Responsibility)
class MacroDonutChart extends StatelessWidget {
  final int protein;
  final int carbs;
  final int fat;
  final int totalCalories;
  final int targetCalories;

  const MacroDonutChart({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.totalCalories,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final proteinCals = protein * 4;
    final carbsCals = carbs * 4;
    final fatCals = fat * 9;
    final total = proteinCals + carbsCals + fatCals;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: DonutChartPainter(
                    proteinPercent: total > 0 ? proteinCals / total : 0,
                    carbsPercent: total > 0 ? carbsCals / total : 0,
                    fatPercent: total > 0 ? fatCals / total : 0,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalCalories',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'of $targetCalories cal',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MacroLegend(color: const Color(0xFFFF6B6B), label: 'Protein', value: '${protein}g'),
              const SizedBox(width: 28),
              _MacroLegend(color: const Color(0xFF4ECDC4), label: 'Carbs', value: '${carbs}g'),
              const SizedBox(width: 28),
              _MacroLegend(color: const Color(0xFFFFD93D), label: 'Fat', value: '${fat}g'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _MacroLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;

  DonutChartPainter({
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 24.0;

    final bgPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    double startAngle = -math.pi / 2;

    _drawArc(canvas, center, radius, strokeWidth, startAngle, 2 * math.pi * proteinPercent, const Color(0xFFFF6B6B));
    startAngle += 2 * math.pi * proteinPercent;

    _drawArc(canvas, center, radius, strokeWidth, startAngle, 2 * math.pi * carbsPercent, const Color(0xFF4ECDC4));
    startAngle += 2 * math.pi * carbsPercent;

    _drawArc(canvas, center, radius, strokeWidth, startAngle, 2 * math.pi * fatPercent, const Color(0xFFFFD93D));
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double strokeWidth, double startAngle, double sweepAngle, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
