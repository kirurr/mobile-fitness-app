import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise/model.dart';

class ExerciseLocalDataSource {
  late Isar db;

  IsarCollection<Exercise> get _collection => db.exercises;

  ExerciseLocalDataSource(this.db);

  Stream<List<Exercise>> watchAll() {
    return _collection.where().watch(fireImmediately: true).asyncMap((items) async {
      for (final exercise in items) {
        await _loadLinks(exercise);
      }
      return items;
    });
  }

  Future<List<Exercise>> getAll() {
    return _collection.where().findAll().then((items) async {
      for (final exercise in items) {
        await _loadLinks(exercise);
      }
      return items;
    });
  }

  Future<Exercise?> getById(int id) async {
    final exercise = await _collection.get(id);
    if (exercise == null) {
      return null;
    }

    await _loadLinks(exercise);
    return exercise;
  }

  Future<void> replaceAll(List<Exercise> exercises) async {
    await db.writeTxn(() async {
      await _collection.clear();
      await _collection.putAll(exercises);
      for (final exercise in exercises) {
        await exercise.category.save();
        await exercise.muscleGroup.save();
        await exercise.difficultyLevel.save();
      }
    });
  }

  Future<void> _loadLinks(Exercise exercise) async {
    await exercise.category.load();
    await exercise.muscleGroup.load();
    await exercise.difficultyLevel.load();
  }
}
