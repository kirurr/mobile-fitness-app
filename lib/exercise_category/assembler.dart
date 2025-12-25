import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/exercise_category/data/local_ds.dart';
import 'package:mobile_fitness_app/exercise_category/data/remote_ds.dart';
import 'package:mobile_fitness_app/exercise_category/repository.dart';

class ExerciseCategoryAssembler {
  static ExerciseCategoryRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final local = ExerciseCategoryLocalDataSource(isar);
    final remote = ExerciseCategoryRemoteDataSource(api);

    return ExerciseCategoryRepository(local: local, remote: remote);
  }
}
