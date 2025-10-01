import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../application/state/weight_state.dart';
import '../widgets/charts/weight_chart.dart';

/// Trends screen displaying weight tracking (Interface Segregation)
class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  int selectedPeriod = 1; // 0: Day, 1: Month, 2: Year

  @override
  Widget build(BuildContext context) {
    return Consumer<WeightState>(
      builder: (context, state, _) {
        final latestEntry = state.latestEntry;

        return CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildPeriodToggle(),
            _buildChart(state),
            _buildStatCards(latestEntry),
            _buildAddButton(context, state),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildAppBar() {
    return const SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: false,
      expandedHeight: 50,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Trends',
          style: TextStyle(
            color: Colors.black,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        titlePadding: EdgeInsets.only(left: 20, bottom: 16),
      ),
    );
  }

  Widget _buildPeriodToggle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _buildPeriodButton('Day', 0),
              _buildPeriodButton('Month', 1),
              _buildPeriodButton('Year', 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, int index) {
    final isSelected = selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChart(WeightState state) {
    return SliverToBoxAdapter(
      child: WeightChart(
        entries: state.allEntries,
        period: selectedPeriod,
        onDataPointTap: (entry) => _editWeightEntry(context, state, entry),
      ),
    );
  }

  Widget _buildStatCards(latestEntry) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Weight',
                latestEntry != null ? '${latestEntry.weight.toStringAsFixed(1)} kg' : '--',
                Icons.monitor_weight_outlined,
                const Color(0xFF34C759),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Body Fat',
                latestEntry?.bodyFat != null ? '${latestEntry!.bodyFat!.toStringAsFixed(1)}%' : '--',
                Icons.analytics_outlined,
                const Color(0xFF007AFF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, WeightState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ElevatedButton.icon(
          onPressed: () => _addWeightEntry(context, state),
          icon: const Icon(Icons.add),
          label: const Text('Add Weight Entry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }

  void _addWeightEntry(BuildContext context, WeightState state) {
    final weightController = TextEditingController();
    final bodyFatController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Weight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date selector
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
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
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateForDisplay(selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, size: 20, color: Color(0xFF007AFF)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyFatController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Body Fat (optional)',
                  suffixText: '%',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final weight = double.tryParse(weightController.text);
                final bodyFat = double.tryParse(bodyFatController.text);
                if (weight != null) {
                  state.addEntryForDate(selectedDate, weight, bodyFat);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateForDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);

    if (selected == today) {
      return 'Today';
    } else if (selected == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  void _editWeightEntry(BuildContext context, WeightState state, entry) {
    final weightController = TextEditingController(text: entry.weight.toString());
    final bodyFatController = TextEditingController(
      text: entry.bodyFat?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                'Edit Weight Entry',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF007AFF)),
                title: const Text('Edit Entry'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context, state, entry, weightController, bodyFatController);
                },
              ),
              Divider(height: 1, color: Colors.grey[200]),
              ListTile(
                leading: const Icon(Icons.delete, color: Color(0xFFFF3B30)),
                title: const Text(
                  'Delete Entry',
                  style: TextStyle(color: Color(0xFFFF3B30)),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Entry'),
                      content: const Text('Delete this weight entry?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Color(0xFFFF3B30)),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    state.deleteEntry(entry.id);
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WeightState state,
    entry,
    TextEditingController weightController,
    TextEditingController bodyFatController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Weight'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight',
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyFatController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Body Fat (optional)',
                suffixText: '%',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              final bodyFat = double.tryParse(bodyFatController.text);
              if (weight != null) {
                state.updateEntry(entry.id, weight, bodyFat);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
