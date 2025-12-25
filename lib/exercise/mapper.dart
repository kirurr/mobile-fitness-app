import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise/dto.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';

class ExerciseMapper {
  final Isar isar;

  ExerciseMapper({required this.isar});

  Future<Exercise> fromDto(ExerciseDTO dto) async {
    final exercise = Exercise(
      id: dto.id,
      name: dto.name,
      type: dto.type,
    );

    exercise.category.value = await isar.exerciseCategorys.get(dto.categoryId);
    exercise.muscleGroup.value = await isar.muscleGroups.get(dto.muscleGroupId);
    exercise.difficultyLevel.value =
        await isar.difficultyLevels.get(dto.difficultyLevelId);

    return exercise;
  }

  Future<ExerciseDTO> toDto(Exercise model) async {
    await model.category.load();
    await model.muscleGroup.load();
    await model.difficultyLevel.load();

    return ExerciseDTO(
      id: model.id,
      name: model.name,
      categoryId: model.category.value!.id,
      muscleGroupId: model.muscleGroup.value!.id,
      difficultyLevelId: model.difficultyLevel.value!.id,
      type: model.type,
    );
  }
}
