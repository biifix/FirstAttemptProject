import '../../domain/models/food_entry.dart';

/// Service for nutrition-related calculations (Single Responsibility Principle)
class NutritionCalculator {
  const NutritionCalculator();

  /// Calculate total protein from a list of food entries
  int calculateTotalProtein(List<FoodEntry> meals) {
    return meals.fold(0, (sum, meal) => sum + meal.protein);
  }

  /// Calculate total carbs from a list of food entries
  int calculateTotalCarbs(List<FoodEntry> meals) {
    return meals.fold(0, (sum, meal) => sum + meal.carbs);
  }

  /// Calculate total fat from a list of food entries
  int calculateTotalFat(List<FoodEntry> meals) {
    return meals.fold(0, (sum, meal) => sum + meal.fat);
  }

  /// Calculate total calories from macros
  int calculateCaloriesFromMacros(int protein, int carbs, int fat) {
    return (protein * 4) + (carbs * 4) + (fat * 9);
  }

  /// Calculate total calories from a list of food entries
  int calculateTotalCalories(List<FoodEntry> meals) {
    return meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  /// Calculate macro percentages
  Map<String, double> calculateMacroPercentages(int protein, int carbs, int fat) {
    final proteinCals = protein * 4;
    final carbsCals = carbs * 4;
    final fatCals = fat * 9;
    final total = proteinCals + carbsCals + fatCals;

    if (total == 0) {
      return {'protein': 0.0, 'carbs': 0.0, 'fat': 0.0};
    }

    return {
      'protein': proteinCals / total,
      'carbs': carbsCals / total,
      'fat': fatCals / total,
    };
  }
}
