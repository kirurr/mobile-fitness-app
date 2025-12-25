import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/exercise/data/remote_ds.dart';
import 'package:mobile_fitness_app/exercise/data/local_ds.dart';
import 'package:mobile_fitness_app/exercise/repository.dart';
import 'package:mobile_fitness_app/exercise/mapper.dart';

class ExerciseAssembler {
  static ExerciseRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final local = ExerciseLocalDataSource(isar);
    final mapper = ExerciseMapper(isar: isar);
    final remote = ExerciseRemoteDataSource(api, mapper);

    return ExerciseRepository(local: local, remote: remote);
  }
}
