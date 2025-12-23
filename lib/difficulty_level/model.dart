import 'package:isar_community/isar.dart';

part 'model.g.dart';

@collection
class DifficultyLevel {
  late Id id;
  final String name;
  final String description;

  DifficultyLevel({
    required this.id,
    required this.name,
    required this.description,
  });
}
