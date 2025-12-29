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
    late ExerciseProgram model;

    await isar.writeTxn(() async {
      model = ExerciseProgram(
        id: dto.id,
        userId: dto.userId,
        name: dto.name,
        description: dto.description,
        isUserAdded: dto.isUserAdded,
        synced: true,
        pendingDelete: false,
        isLocalOnly: false,
      );

      // сначала сохраняем модель — иначе она не attached
      await isar.exercisePrograms.put(model);

      final hasExercises = dto.exercises.isNotEmpty;
      final programExercises = hasExercises
          ? dto.exercises
                .map(
                  (e) => ProgramExercise(
                    id: e.id!,
                    exerciseId: e.exerciseId,
                    order: e.order,
                    sets: e.sets,
                    reps: e.reps,
                    duration: e.duration,
                    restDuration: e.restDuration,
                  ),
                )
                .toList()
          : <ProgramExercise>[];

      if (hasExercises) {
        await isar.programExercises.putAll(programExercises);
      }

      // -------- LINKS --------

      final difficultyLevel = await isar.difficultyLevels.get(
        dto.difficultyLevelId,
      );
      if (difficultyLevel != null) {
        model.difficultyLevel
          ..clear()
          ..add(difficultyLevel);
        await model.difficultyLevel.save();
      }

      if (dto.subscriptionId != null) {
        final subscription = await isar.subscriptions.get(dto.subscriptionId!);
        if (subscription != null) {
          model.subscription
            ..clear()
            ..add(subscription);
          await model.subscription.save();
        }
      }

      // goals
      final goals = await isar.fitnessGoals
          .where()
          .anyOf(dto.fitnessGoalIds, (q, id) => q.idEqualTo(id))
          .findAll();

      model.fitnessGoals.addAll(goals);

      // exercises
      if (hasExercises) {
        final exerciseIds = dto.exercises.map((e) => e.exerciseId).toList();

        final exercises = await isar.exercises
            .where()
            .anyOf(exerciseIds, (q, id) => q.idEqualTo(id))
            .findAll();

        for (final pe in programExercises) {
          final exerciseMatch = exercises.firstWhere(
            (ex) => ex.id == pe.exerciseId,
          );
          pe.exercise.value = exerciseMatch;
          pe.program.value = model;
        }

        model.programExercises.addAll(programExercises);
      }

      // -------- SAVE LINKS --------

      await model.fitnessGoals.save();
      if (hasExercises) {
        await model.programExercises.save();

        for (final pe in programExercises) {
          await pe.exercise.save();
          await pe.program.save();
        }
      }
    });

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
          ),
        )
        .toList();

    return ExerciseProgramDTO(
      id: model.id,
      userId: model.userId,
      name: model.name,
      description: model.description,
      isUserAdded: model.isUserAdded,
      difficultyLevelId:
          model.difficultyLevel.isNotEmpty
              ? model.difficultyLevel.first.id
              : 0,
      subscriptionId:
          model.subscription.isNotEmpty
              ? model.subscription.first.id
              : null,
      fitnessGoalIds: model.fitnessGoals
          .map((goal) => goal.id)
          .toList(growable: false),
      exercises: programExercises,
    );
  }
}
