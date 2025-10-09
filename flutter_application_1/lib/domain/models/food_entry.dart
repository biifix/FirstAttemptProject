/// Meal type enum for categorizing food entries
enum MealType {
  breakfast,
  lunch,
  dinner,
}

/// Domain model representing a food item with nutritional information
class FoodEntry {
  final String id;
  final String name;
  final String icon;
  final int protein; // grams
  final int carbs; // grams
  final int fat; // grams
  final MealType mealType;

  const FoodEntry({
    required this.id,
    required this.name,
    required this.icon,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
  });

  /// Calculate total calories using standard macro-calorie conversions
  int get calories => (protein * 4) + (carbs * 4) + (fat * 9);

  FoodEntry copyWith({
    String? id,
    String? name,
    String? icon,
    int? protein,
    int? carbs,
    int? fat,
    MealType? mealType,
  }) {
    return FoodEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      mealType: mealType ?? this.mealType,
    );
  }
}
