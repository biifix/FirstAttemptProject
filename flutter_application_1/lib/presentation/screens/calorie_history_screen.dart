import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/i_meal_repository.dart';

/// Screen displaying calorie history as a bar chart
class CalorieHistoryScreen extends StatelessWidget {
  const CalorieHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mealRepository = context.read<IMealRepository>();

    // Get all dates with meals and calculate calories for each
    final allDates = mealRepository.getAllMealDates();
    final calorieData = allDates.map((date) {
      final meals = mealRepository.getMealsForDate(date);
      final totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);
      return MapEntry(date, totalCalories);
    }).toList();

    // Sort by date and take last 7 days
    calorieData.sort((a, b) => a.key.compareTo(b.key));
    final recentData = calorieData.length > 7
        ? calorieData.sublist(calorieData.length - 7)
        : calorieData;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Calorie History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: recentData.isEmpty
          ? Center(
              child: Text(
                'No calorie data available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(recentData),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => Colors.black87,
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.toInt()} cal',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < recentData.length) {
                                  final date = recentData[index].key;
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              interval: _getInterval(recentData),
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _getInterval(recentData),
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[400]!, width: 1),
                            left: BorderSide(color: Colors.grey[400]!, width: 1),
                          ),
                        ),
                        barGroups: recentData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final calories = entry.value.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: calories.toDouble(),
                                color: const Color(0xFF4ECDC4),
                                width: 30,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: _getMaxY(recentData),
                                  color: const Color(0xFFF5F5F5),
                                ),
                                rodStackItems: [],
                              ),
                            ],
                            showingTooltipIndicators: [],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStats(recentData),
                  const Spacer(),
                ],
              ),
            ),
    );
  }

  double _getMaxY(List<MapEntry<DateTime, int>> data) {
    if (data.isEmpty) return 3000;
    final maxCalories = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    // Round up to nearest 500
    return ((maxCalories / 500).ceil() * 500).toDouble();
  }

  double _getInterval(List<MapEntry<DateTime, int>> data) {
    final maxY = _getMaxY(data);
    return maxY / 5; // Show 5 intervals
  }

  Widget _buildStats(List<MapEntry<DateTime, int>> data) {
    if (data.isEmpty) return const SizedBox.shrink();

    final totalCalories = data.fold(0, (sum, entry) => sum + entry.value);
    final avgCalories = (totalCalories / data.length).round();
    final maxCalories = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minCalories = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Avg', value: '$avgCalories'),
          _StatItem(label: 'Max', value: '$maxCalories'),
          _StatItem(label: 'Min', value: '$minCalories'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          'cal',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
