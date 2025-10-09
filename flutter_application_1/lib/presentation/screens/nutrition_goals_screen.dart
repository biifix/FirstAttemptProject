import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/nutrition_state.dart';

/// Screen for setting daily calorie goal and macronutrient ratios
class NutritionGoalsScreen extends StatefulWidget {
  const NutritionGoalsScreen({super.key});

  @override
  State<NutritionGoalsScreen> createState() => _NutritionGoalsScreenState();
}

class _NutritionGoalsScreenState extends State<NutritionGoalsScreen> {
  late TextEditingController _caloriesController;
  late double _proteinPercent;
  late double _carbsPercent;
  late double _fatPercent;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<NutritionState>(context, listen: false);
    _caloriesController = TextEditingController(text: state.targetCalories.toString());

    // Calculate percentages from saved goals
    final totalGrams = state.targetCarbs + state.targetProtein + state.targetFat;
    if (totalGrams > 0) {
      _carbsPercent = (state.targetCarbs / totalGrams * 100);
      _proteinPercent = (state.targetProtein / totalGrams * 100);
      _fatPercent = (state.targetFat / totalGrams * 100);
    } else {
      // Default percentages
      _carbsPercent = 40;
      _proteinPercent = 30;
      _fatPercent = 30;
    }
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  int get targetCalories => int.tryParse(_caloriesController.text) ?? 2000;

  int get proteinGrams => ((targetCalories * _proteinPercent / 100) / 4).round();
  int get carbsGrams => ((targetCalories * _carbsPercent / 100) / 4).round();
  int get fatGrams => ((targetCalories * _fatPercent / 100) / 9).round();

  void _saveGoals() {
    final state = Provider.of<NutritionState>(context, listen: false);
    state.setTargetCalories(targetCalories);
    state.setMacroGoals(carbsGrams, proteinGrams, fatGrams);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nutrition Goals',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCalorieGoalSection(),
                      const SizedBox(height: 32),
                      _buildMacroSection(),
                    ],
                  ),
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieGoalSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Calorie Goal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              suffixText: 'cal',
              suffixStyle: const TextStyle(
                fontSize: 16,
                color: Color(0xFF666666),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Macronutrient Ratios',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildMacroInfo('Carbs', _carbsPercent, carbsGrams, const Color(0xFF4ECDC4)),
          const SizedBox(height: 12),
          _buildMacroInfo('Protein', _proteinPercent, proteinGrams, const Color(0xFFFF6B6B)),
          const SizedBox(height: 12),
          _buildMacroInfo('Fat', _fatPercent, fatGrams, const Color(0xFFFFD93D)),
          const SizedBox(height: 24),
          _buildTriSlider(),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String name, double percent, int grams, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        Text(
          '${percent.round()}% • ${grams}g',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  Widget _buildTriSlider() {
    // Calculate positions (0 to 1 range)
    final divider1 = _carbsPercent / 100;
    final divider2 = (_carbsPercent + _proteinPercent) / 100;

    return SizedBox(
      height: 80,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return GestureDetector(
            onPanUpdate: (details) {
              final position = (details.localPosition.dx / width).clamp(0.0, 1.0);
              _updateDividers(position, details.localPosition.dx, width);
            },
            child: Stack(
              children: [
                // The tri-color bar
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: _carbsPercent.round(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF4ECDC4),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                bottomLeft: Radius.circular(6),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: _proteinPercent.round(),
                          child: Container(
                            color: const Color(0xFFFF6B6B),
                          ),
                        ),
                        Expanded(
                          flex: _fatPercent.round(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD93D),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // First divider knob (between carbs and protein)
                Positioned(
                  left: (width * divider1) - 12,
                  top: 20,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      final globalPosition = (details.globalPosition.dx - (context.size!.width - width) / 2) / width;
                      final position = globalPosition.clamp(0.1, 0.9);
                      setState(() {
                        _carbsPercent = (position * 100).clamp(10.0, 80.0);
                        final remaining = 100 - _carbsPercent;
                        final proteinRatio = _proteinPercent / (_proteinPercent + _fatPercent);
                        _proteinPercent = remaining * proteinRatio;
                        _fatPercent = remaining * (1 - proteinRatio);
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E5EA), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.drag_handle, size: 16, color: Color(0xFF666666)),
                      ),
                    ),
                  ),
                ),
                // Second divider knob (between protein and fat)
                Positioned(
                  left: (width * divider2) - 12,
                  top: 20,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      final globalPosition = (details.globalPosition.dx - (context.size!.width - width) / 2) / width;
                      final position = globalPosition.clamp(divider1 + 0.1, 0.9);
                      setState(() {
                        final proteinFatTotal = 100 - _carbsPercent;
                        final proteinPercent = ((position - divider1) * 100).clamp(10.0, proteinFatTotal - 10);
                        _proteinPercent = proteinPercent;
                        _fatPercent = proteinFatTotal - proteinPercent;
                      });
                    },
                    child: Container(
                      width: 24,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E5EA), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.drag_handle, size: 16, color: Color(0xFF666666)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateDividers(double position, double xPosition, double width) {
    // This can be used for tap-to-move functionality if needed
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _saveGoals,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Save Goals',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
