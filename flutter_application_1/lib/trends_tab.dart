import 'package:flutter/material.dart';
import 'dart:math' as math;

class WeightEntry {
  final double weight;
  final double? bodyFat;

  WeightEntry({required this.weight, this.bodyFat});
}

class TrendsTab extends StatefulWidget {
  final Map<String, WeightEntry> weightEntries;
  final Function(double weight, double? bodyFat) onAddWeight;

  const TrendsTab({
    super.key,
    required this.weightEntries,
    required this.onAddWeight,
  });

  @override
  State<TrendsTab> createState() => _TrendsTabState();
}

class _TrendsTabState extends State<TrendsTab> {
  int selectedPeriod = 1; // 0: Day, 1: Month, 2: Year

  void _addWeightEntry() {
    final weightController = TextEditingController();
    final bodyFatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Weight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight',
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyFatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Body Fat (optional)',
                suffixText: '%',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              final bodyFat = double.tryParse(bodyFatController.text);
              if (weight != null) {
                widget.onAddWeight(weight, bodyFat);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedEntries = widget.weightEntries.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final latestEntry = sortedEntries.isNotEmpty ? sortedEntries.last.value : null;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          pinned: false,
          expandedHeight: 50,
          flexibleSpace: const FlexibleSpaceBar(
            title: Text(
              'Trends',
              style: TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            titlePadding: EdgeInsets.only(left: 20, bottom: 16),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      _PeriodButton(
                        label: 'Day',
                        isSelected: selectedPeriod == 0,
                        onTap: () => setState(() => selectedPeriod = 0),
                      ),
                      _PeriodButton(
                        label: 'Month',
                        isSelected: selectedPeriod == 1,
                        onTap: () => setState(() => selectedPeriod = 1),
                      ),
                      _PeriodButton(
                        label: 'Year',
                        isSelected: selectedPeriod == 2,
                        onTap: () => setState(() => selectedPeriod = 2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              WeightChart(
                entries: sortedEntries,
                period: selectedPeriod,
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Weight',
                        value: latestEntry != null ? '${latestEntry.weight.toStringAsFixed(1)} kg' : '--',
                        icon: Icons.monitor_weight_outlined,
                        color: const Color(0xFF34C759),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Body Fat',
                        value: latestEntry?.bodyFat != null ? '${latestEntry!.bodyFat!.toStringAsFixed(1)}%' : '--',
                        icon: Icons.analytics_outlined,
                        color: const Color(0xFF007AFF),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addWeightEntry,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Weight Entry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007AFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class WeightChart extends StatelessWidget {
  final List<MapEntry<String, WeightEntry>> entries;
  final int period;

  const WeightChart({
    super.key,
    required this.entries,
    required this.period,
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 250,
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
      child: CustomPaint(
        painter: WeightChartPainter(entries: entries),
        child: Container(),
      ),
    );
  }
}

class WeightChartPainter extends CustomPainter {
  final List<MapEntry<String, WeightEntry>> entries;

  WeightChartPainter({required this.entries});

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final weights = entries.map((e) => e.value.weight).toList();
    final minWeight = weights.reduce(math.min) - 2;
    final maxWeight = weights.reduce(math.max) + 2;
    final range = maxWeight - minWeight;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E5EA)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Draw smooth curve
    final path = Path();
    final paint = Paint()
      ..color = const Color(0xFF34C759)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final points = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      final x = size.width * (i / (entries.length - 1));
      final normalizedWeight = (entries[i].value.weight - minWeight) / range;
      final y = size.height - (size.height * normalizedWeight);
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          p1.dx, p1.dy,
        );
      }

      canvas.drawPath(path, paint);

      // Draw points
      final pointPaint = Paint()
        ..color = const Color(0xFF34C759)
        ..style = PaintingStyle.fill;

      for (final point in points) {
        canvas.drawCircle(point, 5, pointPaint);
        canvas.drawCircle(point, 5, Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
