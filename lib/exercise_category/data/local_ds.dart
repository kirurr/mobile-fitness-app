import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';

class ExerciseCategoryLocalDataSource {
  late Isar db;

  IsarCollection<ExerciseCategory> get _collection => db.exerciseCategorys;

  ExerciseCategoryLocalDataSource(this.db);

  Stream<List<ExerciseCategory>> watchAll() {
    return _collection.where().watch(fireImmediately: true);
  }

  Future<List<ExerciseCategory>> getAll() {
    return _collection.where().findAll();
  }

  Future<ExerciseCategory?> getById(int id) async {
    return await _collection.get(id);
  }

  Future<void> replaceAll(List<ExerciseCategory> categories) async {
    await db.writeTxn(() async {
      await _collection.clear();
      await _collection.putAll(categories);
    });
  }
}
