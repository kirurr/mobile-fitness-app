import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise_program/data/local_ds.dart';
import 'package:mobile_fitness_app/exercise_program/data/remote_ds.dart';
import 'package:mobile_fitness_app/exercise_program/dto.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';

class ExerciseProgramRepository {
  final ExerciseProgramLocalDataSource local;
  final ExerciseProgramRemoteDataSource remote;

  ExerciseProgramRepository({
    required this.local,
    required this.remote,
  });

  Stream<List<ExerciseProgram>> watchPrograms() {
    return local.watchAll();
  }

  Future<List<ExerciseProgram>> getLocalPrograms() {
    return local.getAll();
  }

  Future<void> refreshPrograms({
    int? difficultyLevelId,
    int? subscriptionId,
    int? fitnessGoalId,
    int? userId,
  }) async {
    try {
      final remoteItems = await remote.getAll(
        difficultyLevelId: difficultyLevelId,
        subscriptionId: subscriptionId,
        fitnessGoalId: fitnessGoalId,
        userId: userId,
      );
      await local.replaceAll(remoteItems);
    } catch (e) {
      print('Error refreshing exercise programs: $e');
      rethrow;
    }
  }

  Future<ExerciseProgram> createProgram(ExerciseProgramPayloadDTO payload) async {
    final created = await remote.create(payload);
    final payloadExercises =
        payload.exercises.isNotEmpty ? _mapPayloadExercises(payload, created) : null;
    await local.create(created, programExercises: payloadExercises);
    return created;
  }

  Future<ExerciseProgram> updateProgram(int id, ExerciseProgramPayloadDTO payload) async {
    print(
      'ExerciseProgramRepository.updateProgram: '
      'id=$id payloadExercises=${payload.exercises.length}',
    );
    await local.updateFromPayload(id, payload);
    final updated = await remote.update(id, payload);
    return updated;
  }

  Future<void> deleteProgram(int id) async {
    await remote.delete(id);
    await local.deleteById(id);
  }

  List<ProgramExercise> _mapPayloadExercises(
    ExerciseProgramPayloadDTO payload,
    ExerciseProgram program,
  ) {
    return payload.exercises
        .map(
          (e) => ProgramExercise(
                id: e.id ?? Isar.autoIncrement,
                exerciseId: e.exerciseId,
                order: e.order,
                sets: e.sets,
                reps: e.reps,
                duration: e.duration,
                restDuration: e.restDuration,
              )..program.value = program,
        )
        .toList();
  }
}
