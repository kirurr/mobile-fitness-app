import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';

class DifficultyLevelLocalDataSource {
  late Isar db;

  IsarCollection<DifficultyLevel> get _collection => db.difficultyLevels;

  DifficultyLevelLocalDataSource(this.db);

  Stream<List<DifficultyLevel>> watchAll() {
    return _collection.where().watch(fireImmediately: true);
  }

  Future<List<DifficultyLevel>> getAll() {
    return _collection.where().findAll();
  }

  Future<DifficultyLevel?> getById(int id) async {
    return await _collection.get(id);
  }

  Future<void> replaceAll(List<DifficultyLevel> levels) async {
    await db.writeTxn(() async {
      await _collection.clear();
      await _collection.putAll(levels);
    });
  }
}
