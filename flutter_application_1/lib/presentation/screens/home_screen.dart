import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/nutrition_state.dart';
import '../../application/services/date_formatter.dart';
import '../../domain/models/food_entry.dart';
import '../widgets/charts/macro_donut_chart.dart';
import '../widgets/cards/food_entry_card.dart';

/// Home screen displaying nutrition tracking (Interface Segregation - only depends on what it needs)
class HomeScreen extends StatelessWidget {
  final DateFormatter dateFormatter;

  const HomeScreen({
    super.key,
    required this.dateFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionState>(
      builder: (context, state, _) {
        return CustomScrollView(
          slivers: [
            _buildAppBar(context, state),
            _buildChart(state),
            _buildMealsHeader(context, state),
            _buildMealsList(context, state),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, NutritionState state) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: false,
      expandedHeight: 50,
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          children: [
            Text(
              dateFormatter.formatDateLabel(state.selectedDate),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _selectDate(context, state),
              child: const Icon(
                Icons.calendar_today,
                color: Color(0xFF007AFF),
                size: 20,
              ),
            ),
          ],
        ),
        titlePadding: const EdgeInsets.only(left: 7, bottom: 16),
      ),
    );
  }

  Widget _buildChart(NutritionState state) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {}, // Edit target calories
        child: MacroDonutChart(
          protein: state.totalProtein,
          carbs: state.totalCarbs,
          fat: state.totalFat,
          totalCalories: state.totalCalories,
          targetCalories: state.targetCalories,
        ),
      ),
    );
  }

  Widget _buildMealsHeader(BuildContext context, NutritionState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Meals',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            IconButton(
              onPressed: () => _addMeal(context, state),
              icon: const Icon(Icons.add_circle_outline),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsList(BuildContext context, NutritionState state) {
    final meals = state.meals;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= meals.length * 2 - 1) return null;
            if (index.isOdd) return const SizedBox(height: 12);

            final mealIndex = index ~/ 2;
            final meal = meals[mealIndex];
            return FoodEntryCard(
              foodEntry: meal,
              onTap: () => _editMeal(context, state, meal),
            );
          },
          childCount: meals.length * 2 - 1 + 1,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, NutritionState state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      state.selectDate(picked);
    }
  }

  void _addMeal(BuildContext context, NutritionState state) {
    // TODO: Show add meal dialog
  }

  void _editMeal(BuildContext context, NutritionState state, FoodEntry meal) {
    // TODO: Show edit meal dialog
  }
}
