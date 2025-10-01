import '../models/food_entry.dart';

/// Repository interface for meal persistence (Dependency Inversion Principle)
abstract class IMealRepository {
  /// Get all meals for a specific date
  List<FoodEntry> getMealsForDate(DateTime date);

  /// Add a meal to a specific date
  void addMeal(DateTime date, FoodEntry meal);

  /// Update an existing meal
  void updateMeal(DateTime date, String mealId, FoodEntry updatedMeal);

  /// Delete a meal by ID
  void deleteMeal(DateTime date, String mealId);

  /// Get all dates with meals
  List<DateTime> getAllMealDates();
}
