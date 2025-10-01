import 'food_entry.dart';

/// Aggregate root representing all meals for a specific day
class MealDay {
  final DateTime date;
  final List<FoodEntry> meals;

  const MealDay({
    required this.date,
    required this.meals,
  });

  /// Get total protein for the day
  int get totalProtein => meals.fold(0, (sum, meal) => sum + meal.protein);

  /// Get total carbs for the day
  int get totalCarbs => meals.fold(0, (sum, meal) => sum + meal.carbs);

  /// Get total fat for the day
  int get totalFat => meals.fold(0, (sum, meal) => sum + meal.fat);

  /// Get total calories for the day
  int get totalCalories => meals.fold(0, (sum, meal) => sum + meal.calories);

  MealDay copyWith({
    DateTime? date,
    List<FoodEntry>? meals,
  }) {
    return MealDay(
      date: date ?? this.date,
      meals: meals ?? this.meals,
    );
  }
}
