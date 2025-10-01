import 'package:flutter/material.dart';
import '../../../domain/models/food_entry.dart';

/// Widget displaying a food entry card (Single Responsibility)
class FoodEntryCard extends StatelessWidget {
  final FoodEntry foodEntry;
  final VoidCallback? onTap;

  const FoodEntryCard({
    super.key,
    required this.foodEntry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 14),
            _buildInfo(),
            const SizedBox(width: 12),
            _buildMacros(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(foodEntry.icon, style: const TextStyle(fontSize: 28)),
      ),
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            foodEntry.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            '${foodEntry.calories} cal',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMacros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _MacroChip(label: 'P', value: foodEntry.protein, color: const Color(0xFFFF6B6B)),
        const SizedBox(height: 4),
        Row(
          children: [
            _MacroChip(label: 'C', value: foodEntry.carbs, color: const Color(0xFF4ECDC4)),
            const SizedBox(width: 6),
            _MacroChip(label: 'F', value: foodEntry.fat, color: const Color(0xFFFFD93D)),
          ],
        ),
      ],
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
