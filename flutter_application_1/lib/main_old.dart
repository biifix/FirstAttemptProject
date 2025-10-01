import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'trends_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nutrition Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: '.SF Pro Text',
        useMaterial3: true,
      ),
      home: const NutritionTrackerHome(),
    );
  }
}

class NutritionTrackerHome extends StatefulWidget {
  const NutritionTrackerHome({super.key});

  @override
  State<NutritionTrackerHome> createState() => _NutritionTrackerHomeState();
}

class _NutritionTrackerHomeState extends State<NutritionTrackerHome> {
  int targetCalories = 2000;
  DateTime selectedDate = DateTime.now();
  int currentTabIndex = 0;

  // Store meals by date
  Map<String, List<FoodEntry>> mealsByDate = {
    _dateKey(DateTime.now()): [
      FoodEntry(name: 'Oatmeal with Berries', icon: '🥣', protein: 12, carbs: 54, fat: 6),
      FoodEntry(name: 'Grilled Chicken Salad', icon: '🥗', protein: 35, carbs: 28, fat: 18),
      FoodEntry(name: 'Protein Smoothie', icon: '🥤', protein: 25, carbs: 32, fat: 8),
      FoodEntry(name: 'Salmon with Quinoa', icon: '🐟', protein: 38, carbs: 35, fat: 12),
    ],
  };

  // Weight tracking data
  Map<String, WeightEntry> weightEntries = {
    _dateKey(DateTime.now().subtract(const Duration(days: 30))): WeightEntry(weight: 75.5, bodyFat: 18.5),
    _dateKey(DateTime.now().subtract(const Duration(days: 25))): WeightEntry(weight: 75.2, bodyFat: 18.3),
    _dateKey(DateTime.now().subtract(const Duration(days: 20))): WeightEntry(weight: 74.8, bodyFat: 18.0),
    _dateKey(DateTime.now().subtract(const Duration(days: 15))): WeightEntry(weight: 74.5, bodyFat: 17.8),
    _dateKey(DateTime.now().subtract(const Duration(days: 10))): WeightEntry(weight: 74.2, bodyFat: 17.5),
    _dateKey(DateTime.now().subtract(const Duration(days: 5))): WeightEntry(weight: 73.8, bodyFat: 17.2),
    _dateKey(DateTime.now()): WeightEntry(weight: 73.5, bodyFat: 17.0),
  };

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<FoodEntry> get meals => mealsByDate[_dateKey(selectedDate)] ?? [];

  int get totalProtein => meals.fold(0, (sum, meal) => sum + meal.protein);
  int get totalCarbs => meals.fold(0, (sum, meal) => sum + meal.carbs);
  int get totalFat => meals.fold(0, (sum, meal) => sum + meal.fat);
  int get totalCalories => (totalProtein * 4) + (totalCarbs * 4) + (totalFat * 9);

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF007AFF),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String _getDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (selected == today) {
      return 'Today';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (selected == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[selectedDate.month - 1]} ${selectedDate.day}';
    }
  }

  void _editTargetCalories() {
    final controller = TextEditingController(text: targetCalories.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Target Calories'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Calories',
            suffixText: 'cal',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                targetCalories = int.tryParse(controller.text) ?? targetCalories;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editMeal(int index) {
    final meal = meals[index];
    final nameController = TextEditingController(text: meal.name);
    final iconController = TextEditingController(text: meal.icon);
    final proteinController = TextEditingController(text: meal.protein.toString());
    final carbsController = TextEditingController(text: meal.carbs.toString());
    final fatController = TextEditingController(text: meal.fat.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Meal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: 'Icon (emoji)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: proteinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: carbsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                final dateKey = _dateKey(selectedDate);
                final currentMeals = mealsByDate[dateKey] ?? [];
                currentMeals[index] = FoodEntry(
                  name: nameController.text,
                  icon: iconController.text,
                  protein: int.tryParse(proteinController.text) ?? meal.protein,
                  carbs: int.tryParse(carbsController.text) ?? meal.carbs,
                  fat: int.tryParse(fatController.text) ?? meal.fat,
                );
                mealsByDate[dateKey] = currentMeals;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addMeal() {
    final nameController = TextEditingController();
    final iconController = TextEditingController(text: '🍽️');
    final proteinController = TextEditingController(text: '0');
    final carbsController = TextEditingController(text: '0');
    final fatController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Meal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: 'Icon (emoji)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: proteinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Protein (g)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: carbsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Carbs (g)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fatController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Fat (g)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  final dateKey = _dateKey(selectedDate);
                  final currentMeals = mealsByDate[dateKey] ?? [];
                  currentMeals.add(FoodEntry(
                    name: nameController.text,
                    icon: iconController.text,
                    protein: int.tryParse(proteinController.text) ?? 0,
                    carbs: int.tryParse(carbsController.text) ?? 0,
                    fat: int.tryParse(fatController.text) ?? 0,
                  ));
                  mealsByDate[dateKey] = currentMeals;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteMeal(int index) {
    setState(() {
      final dateKey = _dateKey(selectedDate);
      final currentMeals = mealsByDate[dateKey] ?? [];
      currentMeals.removeAt(index);
      if (currentMeals.isEmpty) {
        mealsByDate.remove(dateKey);
      } else {
        mealsByDate[dateKey] = currentMeals;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: currentTabIndex,
          children: [
            _buildHomeTab(),
            TrendsTab(
              weightEntries: weightEntries,
              onAddWeight: (weight, bodyFat) {
                setState(() {
                  weightEntries[_dateKey(DateTime.now())] = WeightEntry(
                    weight: weight,
                    bodyFat: bodyFat,
                  );
                });
              },
            ),
            const Center(child: Text('Add Tab')),
            const Center(child: Text('Recipes Tab')),
            const Center(child: Text('Profile Tab')),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: currentTabIndex == 0,
                  color: const Color(0xFF007AFF),
                  onTap: () => setState(() => currentTabIndex = 0),
                ),
                _NavBarItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Trends',
                  isActive: currentTabIndex == 1,
                  color: const Color(0xFF34C759),
                  onTap: () => setState(() => currentTabIndex = 1),
                ),
                _NavBarItem(
                  icon: Icons.add_circle,
                  label: 'Add',
                  isActive: currentTabIndex == 2,
                  color: const Color(0xFFFF9500),
                  onTap: _addMeal,
                ),
                _NavBarItem(
                  icon: Icons.restaurant_menu_rounded,
                  label: 'Recipes',
                  isActive: currentTabIndex == 3,
                  color: const Color(0xFFFF3B30),
                  onTap: () => setState(() => currentTabIndex = 3),
                ),
                _NavBarItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isActive: currentTabIndex == 4,
                  color: const Color(0xFF5856D6),
                  onTap: () => setState(() => currentTabIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: false,
              expandedHeight: 50,
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  children: [
                    Text(
                      _getDateLabel(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Icon(
                        Icons.calendar_today,
                        color: Color(0xFF007AFF),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                titlePadding: EdgeInsets.only(left: 7, bottom: 16),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _editTargetCalories,
                    child: MacroDonutChart(
                      protein: totalProtein,
                      carbs: totalCarbs,
                      fat: totalFat,
                      totalCalories: totalCalories,
                      targetCalories: targetCalories,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meals',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          onPressed: _addMeal,
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= meals.length * 2 - 1) return null;
                    if (index.isOdd) return const SizedBox(height: 12);

                    final mealIndex = index ~/ 2;
                    final meal = meals[mealIndex];
                    return Dismissible(
                      key: Key('${_dateKey(selectedDate)}_$mealIndex'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E8E93),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        // Show action sheet
                        return await showModalBottomSheet<bool>(
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
                                    Text(
                                      meal.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ListTile(
                                      leading: const Icon(Icons.edit, color: Color(0xFF007AFF)),
                                      title: const Text('Edit Meal'),
                                      onTap: () {
                                        Navigator.pop(context, false);
                                        _editMeal(mealIndex);
                                      },
                                    ),
                                    Divider(height: 1, color: Colors.grey[200]),
                                    ListTile(
                                      leading: const Icon(Icons.delete, color: Color(0xFFFF3B30)),
                                      title: const Text(
                                        'Delete Meal',
                                        style: TextStyle(color: Color(0xFFFF3B30)),
                                      ),
                                      onTap: () async {
                                        Navigator.pop(context, false);
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Delete Meal'),
                                              content: Text('Delete "${meal.name}"?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(color: Color(0xFFFF3B30)),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        if (confirm == true) {
                                          _deleteMeal(mealIndex);
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                          },
                        ) ?? false;
                      },
                      child: FoodEntryCard(
                        foodName: meal.name,
                        icon: meal.icon,
                        calories: meal.calories,
                        protein: meal.protein,
                        carbs: meal.carbs,
                        fat: meal.fat,
                      ),
                    );
                  },
                  childCount: meals.length * 2 - 1 + 1,
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isActive ? color : const Color(0xFF8E8E93),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? color : const Color(0xFF8E8E93),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodEntry {
  final String name;
  final String icon;
  final int protein;
  final int carbs;
  final int fat;

  FoodEntry({
    required this.name,
    required this.icon,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  int get calories => (protein * 4) + (carbs * 4) + (fat * 9);
}

class MacroDonutChart extends StatelessWidget {
  final int protein;
  final int carbs;
  final int fat;
  final int totalCalories;
  final int targetCalories;

  const MacroDonutChart({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.totalCalories,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final proteinCals = protein * 4;
    final carbsCals = carbs * 4;
    final fatCals = fat * 9;
    final total = proteinCals + carbsCals + fatCals;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: DonutChartPainter(
                    proteinPercent: proteinCals / total,
                    carbsPercent: carbsCals / total,
                    fatPercent: fatCals / total,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$totalCalories',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'of $targetCalories cal',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MacroLegend(
                color: const Color(0xFFFF6B6B),
                label: 'Protein',
                value: '${protein}g',
              ),
              const SizedBox(width: 28),
              _MacroLegend(
                color: const Color(0xFF4ECDC4),
                label: 'Carbs',
                value: '${carbs}g',
              ),
              const SizedBox(width: 28),
              _MacroLegend(
                color: const Color(0xFFFFD93D),
                label: 'Fat',
                value: '${fat}g',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _MacroLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double proteinPercent;
  final double carbsPercent;
  final double fatPercent;

  DonutChartPainter({
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 24.0;

    final proteinPaint = Paint()
      ..color = const Color(0xFFFF6B6B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final carbsPaint = Paint()
      ..color = const Color(0xFF4ECDC4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fatPaint = Paint()
      ..color = const Color(0xFFFFD93D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final bgPaint = Paint()
      ..color = const Color(0xFFF5F5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    double startAngle = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      2 * math.pi * proteinPercent,
      false,
      proteinPaint,
    );

    startAngle += 2 * math.pi * proteinPercent;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      2 * math.pi * carbsPercent,
      false,
      carbsPaint,
    );

    startAngle += 2 * math.pi * carbsPercent;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      2 * math.pi * fatPercent,
      false,
      fatPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FoodEntryCard extends StatelessWidget {
  final String foodName;
  final String icon;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;

  const FoodEntryCard({
    super.key,
    required this.foodName,
    required this.icon,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  foodName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$calories cal',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _MacroChip(label: 'P', value: protein, color: const Color(0xFFFF6B6B)),
              const SizedBox(height: 4),
              Row(
                children: [
                  _MacroChip(label: 'C', value: carbs, color: const Color(0xFF4ECDC4)),
                  const SizedBox(width: 6),
                  _MacroChip(label: 'F', value: fat, color: const Color(0xFFFFD93D)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MacroChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
