import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Domain
import 'domain/models/food_entry.dart';
import 'domain/models/weight_entry.dart';
import 'domain/repositories/i_meal_repository.dart';
import 'domain/repositories/i_weight_repository.dart';

// Infrastructure
import 'infrastructure/repositories/in_memory_meal_repository.dart';
import 'infrastructure/repositories/in_memory_weight_repository.dart';

// Application
import 'application/services/nutrition_calculator.dart';
import 'application/services/date_formatter.dart';
import 'application/state/nutrition_state.dart';
import 'application/state/weight_state.dart';

// Presentation
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/trends_screen.dart';
import 'presentation/widgets/navigation/bottom_nav_bar.dart';
import 'core/theme/app_theme.dart';

/// Minimal main that wires up dependencies and runs the app
void main() {
  // Create services (stateless, can be singletons)
  final nutritionCalculator = const NutritionCalculator();
  final dateFormatter = const DateFormatter();

  // Create repositories with sample data (Dependency Inversion - depend on abstractions)
  final IMealRepository mealRepository = _createMealRepository();
  final IWeightRepository weightRepository = _createWeightRepository();

  runApp(
    NutritionTrackerApp(
      mealRepository: mealRepository,
      weightRepository: weightRepository,
      nutritionCalculator: nutritionCalculator,
      dateFormatter: dateFormatter,
    ),
  );
}

/// Factory method to create meal repository with sample data
IMealRepository _createMealRepository() {
  final now = DateTime.now();
  final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

  return InMemoryMealRepository(
    initialData: {
      dateKey: [
        FoodEntry(
          id: '1',
          name: 'Oatmeal with Berries',
          icon: '🥣',
          protein: 12,
          carbs: 54,
          fat: 6,
          mealType: MealType.breakfast,
        ),
        FoodEntry(
          id: '2',
          name: 'Grilled Chicken Salad',
          icon: '🥗',
          protein: 35,
          carbs: 28,
          fat: 18,
          mealType: MealType.lunch,
        ),
        FoodEntry(
          id: '3',
          name: 'Protein Smoothie',
          icon: '🥤',
          protein: 25,
          carbs: 32,
          fat: 8,
          mealType: MealType.breakfast,
        ),
        FoodEntry(
          id: '4',
          name: 'Salmon with Quinoa',
          icon: '🐟',
          protein: 38,
          carbs: 35,
          fat: 12,
          mealType: MealType.dinner,
        ),
      ],
    },
  );
}

/// Factory method to create weight repository with sample data
IWeightRepository _createWeightRepository() {
  final now = DateTime.now();

  String dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  return InMemoryWeightRepository(
    initialData: {
      dateKey(now.subtract(const Duration(days: 30))): WeightEntry(
        id: '1',
        date: now.subtract(const Duration(days: 30)),
        weight: 75.5,
        bodyFat: 18.5,
      ),
      dateKey(now.subtract(const Duration(days: 25))): WeightEntry(
        id: '2',
        date: now.subtract(const Duration(days: 25)),
        weight: 75.2,
        bodyFat: 18.3,
      ),
      dateKey(now.subtract(const Duration(days: 20))): WeightEntry(
        id: '3',
        date: now.subtract(const Duration(days: 20)),
        weight: 74.8,
        bodyFat: 18.0,
      ),
      dateKey(now.subtract(const Duration(days: 15))): WeightEntry(
        id: '4',
        date: now.subtract(const Duration(days: 15)),
        weight: 74.5,
        bodyFat: 17.8,
      ),
      dateKey(now.subtract(const Duration(days: 10))): WeightEntry(
        id: '5',
        date: now.subtract(const Duration(days: 10)),
        weight: 74.2,
        bodyFat: 17.5,
      ),
      dateKey(now.subtract(const Duration(days: 5))): WeightEntry(
        id: '6',
        date: now.subtract(const Duration(days: 5)),
        weight: 73.8,
        bodyFat: 17.2,
      ),
      dateKey(now): WeightEntry(
        id: '7',
        date: now,
        weight: 73.5,
        bodyFat: 17.0,
      ),
    },
  );
}

/// Root application widget - wires up providers (Dependency Injection)
class NutritionTrackerApp extends StatelessWidget {
  final IMealRepository mealRepository;
  final IWeightRepository weightRepository;
  final NutritionCalculator nutritionCalculator;
  final DateFormatter dateFormatter;

  const NutritionTrackerApp({
    super.key,
    required this.mealRepository,
    required this.weightRepository,
    required this.nutritionCalculator,
    required this.dateFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide repositories
        Provider<IMealRepository>.value(value: mealRepository),
        Provider<IWeightRepository>.value(value: weightRepository),
        // Provide state objects that depend on repositories
        ChangeNotifierProvider(
          create: (_) => NutritionState(
            mealRepository: mealRepository,
            calculator: nutritionCalculator,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WeightState(weightRepository: weightRepository),
        ),
        // Provide services
        Provider<DateFormatter>.value(value: dateFormatter),
        Provider<NutritionCalculator>.value(value: nutritionCalculator),
      ],
      child: MaterialApp(
        title: 'Nutrition Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigator(),
      ),
    );
  }
}

/// Main navigator widget handling tab navigation
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = Provider.of<DateFormatter>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(dateFormatter: dateFormatter),
            const TrendsScreen(),
            const Center(child: Text('Add Tab')),
            const Center(child: Text('Recipes Tab')),
            const Center(child: Text('Profile Tab')),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
