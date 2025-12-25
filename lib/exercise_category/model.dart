import 'package:isar_community/isar.dart';

part 'model.g.dart';

@collection
class ExerciseCategory {
  late Id id;
  final String name;
  final String description;

  ExerciseCategory({
    required this.id,
    required this.name,
    required this.description,
  });
}
