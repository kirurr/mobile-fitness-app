import 'package:isar_community/isar.dart';

part 'model.g.dart';

@collection
class FitnessGoal {
  final Id id;
  final String name;

  const FitnessGoal({
    required this.id,
    required this.name,
  });

  /// JSON -> FitnessGoal
  factory FitnessGoal.fromJson(Map<String, dynamic> json) {
    return FitnessGoal(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
