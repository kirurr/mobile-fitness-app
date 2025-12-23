import 'package:isar_community/isar.dart';

part 'model.g.dart';

@collection
class DifficultyLevel {
  final Id id;
  final String name;
  final String description;

  const DifficultyLevel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory DifficultyLevel.fromJson(Map<String, dynamic> json) {
    return DifficultyLevel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
