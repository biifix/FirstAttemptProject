import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget displaying macro distribution as a donut chart (Single Responsibility)
class MacroDonutChart extends StatelessWidget {
  final int protein;
  final int carbs;
  final int fat;
  final int totalCalories;
  final int targetCalories;
  final int targetCarbs;
  final int targetProtein;
  final int targetFat;

  const MacroDonutChart({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.totalCalories,
    required this.targetCalories,
    required this.targetCarbs,
    required this.targetProtein,
    required this.targetFat,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MacroStatBar(
                  color: const Color(0xFF4ECDC4),
                  label: 'Carbs',
                  current: carbs,
                  target: targetCarbs,
                ),
                _MacroStatBar(
                  color: const Color(0xFFFF6B6B),
                  label: 'Protein',
                  current: protein,
                  target: targetProtein,
                ),
                _MacroStatBar(
                  color: const Color(0xFFFFD93D),
                  label: 'Fat',
                  current: fat,
                  target: targetFat,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroStatBar extends StatelessWidget {
  final Color color;
  final String label;
  final int current;
  final int target;

  const _MacroStatBar({
    required this.color,
    required this.label,
    required this.current,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$current / ${target}g',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 3.5,
          width: 70,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
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

    _drawArc(canvas, center, radius, strokeWidth, startAngle, 2 * math.pi * carbsPercent, const Color(0xFF4ECDC4));
    startAngle += 2 * math.pi * carbsPercent;

    _drawArc(canvas, center, radius, strokeWidth, startAngle, 2 * math.pi * proteinPercent, const Color(0xFFFF6B6B));
    startAngle += 2 * math.pi * proteinPercent;

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
