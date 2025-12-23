import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';

import 'data/local_ds.dart';
import 'data/remote_ds.dart';
import 'repository.dart';

class DifficultyLevelAssembler {
  static DifficultyLevelRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final local = DifficultyLevelLocalDataSource(isar);
    final remote = DifficultyLevelRemoteDataSource(api);

    return DifficultyLevelRepository(local: local, remote: remote);
  }
}
