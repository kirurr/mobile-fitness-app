import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';
import 'package:mobile_fitness_app/user_completed_exercise/mapper.dart';
import 'package:mobile_fitness_app/user_completed_program/dto.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';

class UserCompletedProgramMapper {
  final Isar isar;
  final UserCompletedExerciseMapper completedExerciseMapper;

  UserCompletedProgramMapper({
    required this.isar,
    required this.completedExerciseMapper,
  });

  Future<UserCompletedProgram> fromDto(UserCompletedProgramDTO dto) async {
    late UserCompletedProgram model;

    await isar.writeTxn(() async {
      model = UserCompletedProgram(
        id: dto.id,
        userId: dto.userId,
        programId: dto.programId,
        startDate: dto.startDate,
        endDate: dto.endDate,
        synced: true,
        pendingDelete: false,
        isLocalOnly: false,
      );

      await isar.userCompletedPrograms.put(model);

      model.program.value = await isar.exercisePrograms.get(dto.programId);

      final exercises = await Future.wait(
        dto.completedExercises.map(completedExerciseMapper.fromDto),
      );
      if (exercises.isNotEmpty) {
        await isar.userCompletedExercises.putAll(exercises);
        model.completedExercises.addAll(exercises);
        await model.completedExercises.save();
      }

      await model.program.save();
    });

    return model;
  }

  Future<UserCompletedProgramDTO> toDto(UserCompletedProgram model) async {
    await model.program.load();
    await model.completedExercises.load();

    final exercises = await Future.wait(
      model.completedExercises.map(completedExerciseMapper.toDto),
    );

    return UserCompletedProgramDTO(
      id: model.id,
      userId: model.userId,
      programId: model.program.value?.id ?? model.programId,
      startDate: model.startDate,
      endDate: model.endDate,
      completedExercises: exercises,
    );
  }
}
