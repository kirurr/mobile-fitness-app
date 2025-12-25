import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';

part 'model.g.dart';

@collection
class Exercise {
  late Id id;
  final String name;
  final String type;

  final category = IsarLink<ExerciseCategory>();
  final muscleGroup = IsarLink<MuscleGroup>();
  final difficultyLevel = IsarLink<DifficultyLevel>();

  Exercise({
    required this.id,
    required this.name,
    required this.type,
  });
}
