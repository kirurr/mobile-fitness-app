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
    final programExercises = created.programExercises.toList();
    await local.create(created, programExercises: programExercises);
    return created;
  }

  Future<ExerciseProgram> updateProgram(int id, ExerciseProgramPayloadDTO payload) async {
    print(
      'ExerciseProgramRepository.updateProgram: '
      'id=$id payloadExercises=${payload.exercises.length}',
    );
    final updated = await remote.update(id, payload);
    final programExercises = updated.programExercises.toList();
    await local.updateFromProgram(updated, programExercises);
    return updated;
  }

  Future<void> deleteProgram(int id) async {
    await remote.delete(id);
    await local.deleteById(id);
  }

}
