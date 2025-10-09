import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/nutrition_state.dart';
import '../../application/services/date_formatter.dart';
import '../../domain/models/food_entry.dart';
import '../widgets/charts/macro_donut_chart.dart';
import '../widgets/cards/food_entry_card.dart';
import 'calorie_history_screen.dart';
import 'nutrition_goals_screen.dart';

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
            _buildChart(context, state),
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8),
          child: GestureDetector(
            onTap: () => _showSettingsMenu(context, state),
            child: const Icon(
              Icons.more_vert,
              color: Color(0xFF007AFF),
              size: 28,
            ),
          ),
        ),
      ],
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

  Widget _buildChart(BuildContext context, NutritionState state) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CalorieHistoryScreen(),
            ),
          );
        },
        child: MacroDonutChart(
          protein: state.totalProtein,
          carbs: state.totalCarbs,
          fat: state.totalFat,
          totalCalories: state.totalCalories,
          targetCalories: state.targetCalories,
          targetCarbs: state.targetCarbs,
          targetProtein: state.targetProtein,
          targetFat: state.targetFat,
        ),
      ),
    );
  }

  Widget _buildMealsHeader(BuildContext context, NutritionState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
        child: const Text(
          'Meals',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildMealsList(BuildContext context, NutritionState state) {
    final meals = state.meals;

    // Group meals by type
    final breakfastMeals = meals.where((m) => m.mealType == MealType.breakfast).toList();
    final lunchMeals = meals.where((m) => m.mealType == MealType.lunch).toList();
    final dinnerMeals = meals.where((m) => m.mealType == MealType.dinner).toList();

    return SliverList(
      delegate: SliverChildListDelegate([
        if (breakfastMeals.isNotEmpty) ...[
          _buildMealSection(context, state, 'Breakfast', breakfastMeals),
          const SizedBox(height: 20),
        ],
        if (lunchMeals.isNotEmpty) ...[
          _buildMealSection(context, state, 'Lunch', lunchMeals),
          const SizedBox(height: 20),
        ],
        if (dinnerMeals.isNotEmpty) ...[
          _buildMealSection(context, state, 'Dinner', dinnerMeals),
        ],
      ]),
    );
  }

  Widget _buildMealSection(BuildContext context, NutritionState state, String title, List<FoodEntry> meals) {
    MealType mealType;
    if (title == 'Breakfast') {
      mealType = MealType.breakfast;
    } else if (title == 'Lunch') {
      mealType = MealType.lunch;
    } else {
      mealType = MealType.dinner;
    }

    // Calculate total calories for this meal type
    final totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => _addMealForType(context, state, mealType),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.add_circle_outline,
                        size: 20,
                        color: Color(0xFF007AFF),
                      ),
                    ],
                  ),
                  Text(
                    '$totalCalories cal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            if (meals.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...meals.map((meal) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FoodEntryCard(
                  foodEntry: meal,
                  onTap: () => _editMeal(context, state, meal),
                ),
              )),
            ],
          ],
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

  void _showSettingsMenu(BuildContext context, NutritionState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E5EA),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.local_fire_department, color: Color(0xFF007AFF)),
                  title: const Text('Nutrition Goals'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NutritionGoalsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addMealForType(BuildContext context, NutritionState state, MealType mealType) {
    // TODO: Show add meal dialog for specific meal type
  }

  void _editMeal(BuildContext context, NutritionState state, FoodEntry meal) {
    // TODO: Show edit meal dialog
  }
}
