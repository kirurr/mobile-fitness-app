import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';

class MuscleGroupLocalDataSource {
  late Isar db;

  IsarCollection<MuscleGroup> get _collection => db.muscleGroups;

  MuscleGroupLocalDataSource(this.db);

  Stream<List<MuscleGroup>> watchAll() {
    return _collection.where().watch(fireImmediately: true);
  }

  Future<List<MuscleGroup>> getAll() {
    return _collection.where().findAll();
  }

  Future<MuscleGroup?> getById(int id) async {
    return await _collection.get(id);
  }

  Future<void> replaceAll(List<MuscleGroup> groups) async {
    await db.writeTxn(() async {
      await _collection.clear();
      await _collection.putAll(groups);
    });
  }
}
