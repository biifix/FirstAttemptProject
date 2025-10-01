import 'package:flutter/foundation.dart';
import '../../domain/models/weight_entry.dart';
import '../../domain/repositories/i_weight_repository.dart';

/// State management for weight tracking (Open/Closed Principle - open for extension)
class WeightState extends ChangeNotifier {
  final IWeightRepository _weightRepository;

  WeightState({required IWeightRepository weightRepository})
      : _weightRepository = weightRepository;

  // Getters
  List<WeightEntry> get allEntries => _weightRepository.getAllEntries();
  WeightEntry? get latestEntry => _weightRepository.getLatestEntry();

  // Actions
  void addEntry(double weight, double? bodyFat) {
    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      weight: weight,
      bodyFat: bodyFat,
    );
    _weightRepository.saveEntry(entry);
    notifyListeners();
  }

  void addEntryForDate(DateTime date, double weight, double? bodyFat) {
    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      weight: weight,
      bodyFat: bodyFat,
    );
    _weightRepository.saveEntry(entry);
    notifyListeners();
  }

  void updateEntry(String id, double weight, double? bodyFat) {
    // Find the existing entry to preserve its date
    final existingEntry = allEntries.firstWhere((e) => e.id == id);
    final updatedEntry = WeightEntry(
      id: id,
      date: existingEntry.date,
      weight: weight,
      bodyFat: bodyFat,
    );
    _weightRepository.saveEntry(updatedEntry);
    notifyListeners();
  }

  void deleteEntry(String id) {
    _weightRepository.deleteEntry(id);
    notifyListeners();
  }

  WeightEntry? getEntryForDate(DateTime date) {
    return _weightRepository.getEntryForDate(date);
  }
}
