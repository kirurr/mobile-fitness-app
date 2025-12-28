import 'package:mobile_fitness_app/exercise_category/data/local_ds.dart';
import 'package:mobile_fitness_app/exercise_category/data/remote_ds.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';

class ExerciseCategoryRepository {
  final ExerciseCategoryLocalDataSource local;
  final ExerciseCategoryRemoteDataSource remote;

  ExerciseCategoryRepository({
    required this.local,
    required this.remote,
  });

  Stream<List<ExerciseCategory>> watchCategories() {
    return local.watchAll();
  }

  Future<List<ExerciseCategory>> getLocalCategories() {
    return local.getAll();
  }

  Future<void> refreshCategories() async {
    try {
      final remoteCategories = await remote.getAll();

      await local.replaceAll(remoteCategories);
    } catch (e) {
      rethrow;
    }
  }
}
