import '../../domain/models/food_entry.dart';
import '../../domain/repositories/i_meal_repository.dart';

/// In-memory implementation of meal repository
class InMemoryMealRepository implements IMealRepository {
  final Map<String, List<FoodEntry>> _mealsByDate = {};

  InMemoryMealRepository({Map<String, List<FoodEntry>>? initialData}) {
    if (initialData != null) {
      _mealsByDate.addAll(initialData);
    }
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  List<FoodEntry> getMealsForDate(DateTime date) {
    return List.unmodifiable(_mealsByDate[_dateKey(date)] ?? []);
  }

  @override
  void addMeal(DateTime date, FoodEntry meal) {
    final key = _dateKey(date);
    _mealsByDate[key] = [...(_mealsByDate[key] ?? []), meal];
  }

  @override
  void updateMeal(DateTime date, String mealId, FoodEntry updatedMeal) {
    final key = _dateKey(date);
    final meals = _mealsByDate[key];
    if (meals != null) {
      final index = meals.indexWhere((m) => m.id == mealId);
      if (index != -1) {
        meals[index] = updatedMeal;
      }
    }
  }

  @override
  void deleteMeal(DateTime date, String mealId) {
    final key = _dateKey(date);
    final meals = _mealsByDate[key];
    if (meals != null) {
      meals.removeWhere((m) => m.id == mealId);
      if (meals.isEmpty) {
        _mealsByDate.remove(key);
      }
    }
  }

  @override
  List<DateTime> getAllMealDates() {
    return _mealsByDate.keys.map((key) {
      final parts = key.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    }).toList()
      ..sort();
  }
}
