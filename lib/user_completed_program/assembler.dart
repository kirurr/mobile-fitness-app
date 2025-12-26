import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_completed_exercise/mapper.dart';
import 'package:mobile_fitness_app/user_completed_program/data/local_ds.dart';
import 'package:mobile_fitness_app/user_completed_program/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_completed_program/mapper.dart';
import 'package:mobile_fitness_app/user_completed_program/repository.dart';

class UserCompletedProgramAssembler {
  static UserCompletedProgramRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final completedExerciseMapper = UserCompletedExerciseMapper(isar: isar);
    final mapper = UserCompletedProgramMapper(
      isar: isar,
      completedExerciseMapper: completedExerciseMapper,
    );
    final local = UserCompletedProgramLocalDataSource(isar);
    final remote = UserCompletedProgramRemoteDataSource(api, mapper);

    return UserCompletedProgramRepository(local: local, remote: remote);
  }
}
