import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/muscle_group/data/local_ds.dart';
import 'package:mobile_fitness_app/muscle_group/data/remote_ds.dart';
import 'package:mobile_fitness_app/muscle_group/repository.dart';

class MuscleGroupAssembler {
  static MuscleGroupRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final local = MuscleGroupLocalDataSource(isar);
    final remote = MuscleGroupRemoteDataSource(api);

    return MuscleGroupRepository(local: local, remote: remote);
  }
}
