import 'package:flutter/foundation.dart';
import '../../domain/models/food_entry.dart';
import '../../domain/repositories/i_meal_repository.dart';
import '../services/nutrition_calculator.dart';

/// State management for nutrition tracking (Open/Closed Principle - open for extension)
class NutritionState extends ChangeNotifier {
  final IMealRepository _mealRepository;
  final NutritionCalculator _calculator;

  DateTime _selectedDate = DateTime.now();
  int _targetCalories = 2000;

  NutritionState({
    required IMealRepository mealRepository,
    required NutritionCalculator calculator,
  })  : _mealRepository = mealRepository,
        _calculator = calculator;

  // Getters
  DateTime get selectedDate => _selectedDate;
  int get targetCalories => _targetCalories;

  List<FoodEntry> get meals => _mealRepository.getMealsForDate(_selectedDate);

  int get totalProtein => _calculator.calculateTotalProtein(meals);
  int get totalCarbs => _calculator.calculateTotalCarbs(meals);
  int get totalFat => _calculator.calculateTotalFat(meals);
  int get totalCalories => _calculator.calculateTotalCalories(meals);

  Map<String, double> get macroPercentages =>
      _calculator.calculateMacroPercentages(totalProtein, totalCarbs, totalFat);

  // Actions
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setTargetCalories(int calories) {
    _targetCalories = calories;
    notifyListeners();
  }

  void addMeal(FoodEntry meal) {
    _mealRepository.addMeal(_selectedDate, meal);
    notifyListeners();
  }

  void updateMeal(String mealId, FoodEntry updatedMeal) {
    _mealRepository.updateMeal(_selectedDate, mealId, updatedMeal);
    notifyListeners();
  }

  void deleteMeal(String mealId) {
    _mealRepository.deleteMeal(_selectedDate, mealId);
    notifyListeners();
  }
}
