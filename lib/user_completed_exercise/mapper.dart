import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/user_completed_exercise/dto.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';

class UserCompletedExerciseMapper {
  final Isar isar;

  UserCompletedExerciseMapper({required this.isar});

  Future<UserCompletedExercise> fromDto(UserCompletedExerciseDTO dto) async {
    final model = UserCompletedExercise(
      id: dto.id,
      completedProgramId: dto.completedProgramId,
      programExerciseId: dto.programExerciseId,
      exerciseId: dto.exerciseId,
      sets: dto.sets,
      reps: dto.reps,
      duration: dto.duration,
      weight: dto.weight,
      restDuration: dto.restDuration,
      synced: true,
      pendingDelete: false,
      isLocalOnly: false,
    );

    if (dto.exerciseId != null) {
      model.exercise.value = await isar.exercises.get(dto.exerciseId!);
    }
    if (dto.programExerciseId != null) {
      model.programExercise.value = await isar.programExercises.get(
        dto.programExerciseId!,
      );
    }

    return model;
  }

  Future<UserCompletedExerciseDTO> toDto(UserCompletedExercise model) async {
    await model.exercise.load();
    await model.programExercise.load();

    return UserCompletedExerciseDTO(
      id: model.id,
      completedProgramId: model.completedProgramId,
      programExerciseId: model.programExercise.value?.id,
      exerciseId: model.exercise.value?.id,
      sets: model.sets,
      reps: model.reps,
      duration: model.duration,
      weight: model.weight,
      restDuration: model.restDuration,
    );
  }
}
