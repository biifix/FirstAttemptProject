import '../models/weight_entry.dart';

/// Repository interface for weight data persistence (Dependency Inversion Principle)
abstract class IWeightRepository {
  /// Get all weight entries sorted by date
  List<WeightEntry> getAllEntries();

  /// Get weight entry for a specific date
  WeightEntry? getEntryForDate(DateTime date);

  /// Add or update a weight entry
  void saveEntry(WeightEntry entry);

  /// Delete a weight entry
  void deleteEntry(String id);

  /// Get latest weight entry
  WeightEntry? getLatestEntry();
}
