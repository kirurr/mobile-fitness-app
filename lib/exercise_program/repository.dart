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

  Future<void> createProgram(ExerciseProgramPayloadDTO payload) async {
    final created = await remote.create(payload);
    await local.upsert(created);
  }

  Future<void> updateProgram(int id, ExerciseProgramPayloadDTO payload) async {
    final updated = await remote.update(id, payload);
    await local.upsert(updated);
  }

  Future<void> deleteProgram(int id) async {
    await remote.delete(id);
    await local.deleteById(id);
  }
}
