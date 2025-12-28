import 'package:mobile_fitness_app/difficulty_level/data/local_ds.dart';
import 'package:mobile_fitness_app/difficulty_level/data/remote_ds.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';

class DifficultyLevelRepository {
  final DifficultyLevelLocalDataSource local;
  final DifficultyLevelRemoteDataSource remote;

  DifficultyLevelRepository({required this.local, required this.remote});

  Stream<List<DifficultyLevel>> watchLevels() {
    return local.watchAll();
  }

  Future<List<DifficultyLevel>> getLocalLevels() {
    return local.getAll();
  }

  Future<void> refreshLevels() async {
    try {
      final remoteLevels = await remote.getAll();

      await local.replaceAll(remoteLevels);
    } catch (e) {
      rethrow;
    }
  }
}
