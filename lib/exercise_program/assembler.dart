import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/exercise_program/data/local_ds.dart';
import 'package:mobile_fitness_app/exercise_program/data/remote_ds.dart';
import 'package:mobile_fitness_app/exercise_program/mapper.dart';
import 'package:mobile_fitness_app/exercise_program/repository.dart';

class ExerciseProgramAssembler {
  static ExerciseProgramRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final local = ExerciseProgramLocalDataSource(isar);
    final mapper = ExerciseProgramMapper(isar: isar);
    final remote = ExerciseProgramRemoteDataSource(api, mapper);

    return ExerciseProgramRepository(local: local, remote: remote);
  }
}
