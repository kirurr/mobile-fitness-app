import 'package:isar_community/isar.dart';

import 'data/local_ds.dart';
import 'data/remote_ds.dart';
import 'repository.dart';
import '../app/dio.dart';

class FitnessGoalAssembler {
  static FitnessGoalRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final local = FitnessGoalLocalDataSource(isar);
    final remote = FitnessGoalRemoteDataSource(api);

    return FitnessGoalRepository(
      local: local,
      remote: remote,
    );
  }
}