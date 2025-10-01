import '../../domain/models/weight_entry.dart';
import '../../domain/repositories/i_weight_repository.dart';

/// In-memory implementation of weight repository
class InMemoryWeightRepository implements IWeightRepository {
  final Map<String, WeightEntry> _entries = {};

  InMemoryWeightRepository({Map<String, WeightEntry>? initialData}) {
    if (initialData != null) {
      _entries.addAll(initialData);
    }
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  List<WeightEntry> getAllEntries() {
    final entries = _entries.values.toList();
    entries.sort((a, b) => a.date.compareTo(b.date));
    return List.unmodifiable(entries);
  }

  @override
  WeightEntry? getEntryForDate(DateTime date) {
    return _entries[_dateKey(date)];
  }

  @override
  void saveEntry(WeightEntry entry) {
    _entries[_dateKey(entry.date)] = entry;
  }

  @override
  void deleteEntry(String id) {
    _entries.removeWhere((key, entry) => entry.id == id);
  }

  @override
  WeightEntry? getLatestEntry() {
    if (_entries.isEmpty) return null;
    final entries = getAllEntries();
    return entries.last;
  }
}
