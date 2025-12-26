import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/planned_exercise_program/data/local_ds.dart';
import 'package:mobile_fitness_app/planned_exercise_program/data/remote_ds.dart';
import 'package:mobile_fitness_app/planned_exercise_program/mapper.dart';
import 'package:mobile_fitness_app/planned_exercise_program/repository.dart';

class PlannedExerciseProgramAssembler {
  static PlannedExerciseProgramRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final mapper = PlannedExerciseProgramMapper(isar: isar);
    final local = PlannedExerciseProgramLocalDataSource(isar);
    final remote = PlannedExerciseProgramRemoteDataSource(api, mapper);

    return PlannedExerciseProgramRepository(local: local, remote: remote);
  }
}
