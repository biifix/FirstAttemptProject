/// Domain model representing a weight measurement
class WeightEntry {
  final String id;
  final DateTime date;
  final double weight; // kg
  final double? bodyFat; // percentage

  const WeightEntry({
    required this.id,
    required this.date,
    required this.weight,
    this.bodyFat,
  });

  WeightEntry copyWith({
    String? id,
    DateTime? date,
    double? weight,
    double? bodyFat,
  }) {
    return WeightEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      weight: weight ?? this.weight,
      bodyFat: bodyFat ?? this.bodyFat,
    );
  }
}
