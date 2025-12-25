import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_program/dto.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/subscription/model.dart';

class ExerciseProgramMapper {
  final Isar isar;

  ExerciseProgramMapper({required this.isar});

  Future<ExerciseProgram> fromDto(ExerciseProgramDTO dto) async {
    final model = ExerciseProgram(
      id: dto.id,
      userId: dto.userId,
      name: dto.name,
      description: dto.description,
    );

    final programExercises = dto.exercises
        .map(
          (e) => ProgramExercise(
            id: e.id ?? Isar.autoIncrement,
            exerciseId: e.exerciseId,
            order: e.order,
            sets: e.sets,
            reps: e.reps,
            duration: e.duration,
            restDuration: e.restDuration,
          ),
        )
        .toList();

    model.difficultyLevel.value =
        await isar.difficultyLevels.get(dto.difficultyLevelId);
    if (dto.subscriptionId != null) {
      model.subscription.value =
          await isar.subscriptions.get(dto.subscriptionId!);
    }

    final goals = await isar.fitnessGoals
        .where()
        .anyOf(dto.fitnessGoalIds, (q, id) => q.idEqualTo(id))
        .findAll();
    model.fitnessGoals.addAll(goals);

    final exerciseIds = dto.exercises.map((e) => e.exerciseId).toList();
    final exercises = await isar.exercises
        .where()
        .anyOf(exerciseIds, (q, id) => q.idEqualTo(id))
        .findAll();
    for (final pe in programExercises) {
      Exercise? exerciseMatch;
      for (final ex in exercises) {
        if (ex.id == pe.exerciseId) {
          exerciseMatch = ex;
          break;
        }
      }
      if (exerciseMatch != null) {
        pe.exercise.value = exerciseMatch;
      }
      pe.program.value = model;
    }

    model.programExercises.addAll(programExercises);

    return model;
  }

  Future<ExerciseProgramDTO> toDto(ExerciseProgram model) async {
    await model.difficultyLevel.load();
    await model.subscription.load();
    await model.fitnessGoals.load();
    await model.programExercises.load();

    final programExercises = model.programExercises
        .map(
          (e) => ProgramExerciseDTO(
                id: e.id,
                exerciseId: e.exerciseId,
                order: e.order,
                sets: e.sets,
                reps: e.reps,
                duration: e.duration,
                restDuration: e.restDuration,
              ))
        .toList();

    return ExerciseProgramDTO(
      id: model.id,
      userId: model.userId,
      name: model.name,
      description: model.description,
      difficultyLevelId: model.difficultyLevel.value?.id ?? 0,
      subscriptionId: model.subscription.value?.id,
      fitnessGoalIds:
          model.fitnessGoals.map((goal) => goal.id).toList(growable: false),
      exercises: programExercises,
    );
  }
}
