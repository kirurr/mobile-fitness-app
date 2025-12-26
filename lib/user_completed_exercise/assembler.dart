import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_completed_exercise/data/local_ds.dart';
import 'package:mobile_fitness_app/user_completed_exercise/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_completed_exercise/mapper.dart';
import 'package:mobile_fitness_app/user_completed_exercise/repository.dart';

class UserCompletedExerciseAssembler {
  static UserCompletedExerciseRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final mapper = UserCompletedExerciseMapper(isar: isar);
    final local = UserCompletedExerciseLocalDataSource(isar);
    final remote = UserCompletedExerciseRemoteDataSource(api, mapper);

    return UserCompletedExerciseRepository(local: local, remote: remote);
  }
}
