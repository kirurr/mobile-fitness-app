import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';

class FitnessGoalLocalDataSource {
  late Isar db;

  IsarCollection<FitnessGoal> get _collection => db.fitnessGoals;

  FitnessGoalLocalDataSource(this.db);

  Stream<List<FitnessGoal>> watchAll() {
    return _collection.where().watch(fireImmediately: true);
  }

  Future<List<FitnessGoal>> getAll() {
    return _collection.where().findAll();
  }

  Future<FitnessGoal?> getById(int id) async {
    return await _collection.get(id);
  }

  Future<void> replaceAll(List<FitnessGoal> goals) async {
    await db.writeTxn(() async {
      await _collection.clear();
      await _collection.putAll(goals);
    });
  }
}
