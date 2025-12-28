import 'package:mobile_fitness_app/exercise/data/local_ds.dart';
import 'package:mobile_fitness_app/exercise/data/remote_ds.dart';
import 'package:mobile_fitness_app/exercise/model.dart';

class ExerciseRepository {
  final ExerciseLocalDataSource local;
  final ExerciseRemoteDataSource remote;

  ExerciseRepository({
    required this.local,
    required this.remote,
  });

  Stream<List<Exercise>> watchExercises() {
    return local.watchAll();
  }

  Future<List<Exercise>> getLocalExercises() {
    return local.getAll();
  }

  Future<void> refreshExercises({
    int? categoryId,
    int? muscleGroupId,
    int? difficultyLevelId,
  }) async {
    try {
      final remoteExercises = await remote.getAll(
        categoryId: categoryId,
        muscleGroupId: muscleGroupId,
        difficultyLevelId: difficultyLevelId,
      );

      await local.replaceAll(remoteExercises);
    } catch (e) {
      rethrow;
    }
  }
}
