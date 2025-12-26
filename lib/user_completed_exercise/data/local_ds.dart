import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';

class UserCompletedExerciseLocalDataSource {
  late Isar db;

  IsarCollection<UserCompletedExercise> get _collection =>
      db.userCompletedExercises;

  UserCompletedExerciseLocalDataSource(this.db);

  Stream<List<UserCompletedExercise>> watchByCompletedProgramId(
    int completedProgramId,
  ) {
    return _collection
        .filter()
        .completedProgramIdEqualTo(completedProgramId)
        .watch(fireImmediately: true)
        .asyncMap((items) async {
          for (final item in items) {
            await _loadLinks(item);
          }
          return items;
        });
  }

  Future<List<UserCompletedExercise>> getByCompletedProgramId(
    int completedProgramId,
  ) async {
    final items = await _collection
        .filter()
        .completedProgramIdEqualTo(completedProgramId)
        .findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<List<UserCompletedExercise>> getUnsynced() async {
    final items = await _collection.filter().syncedEqualTo(false).findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<UserCompletedExercise?> getById(int id) async {
    final item = await _collection.get(id);
    if (item == null) return null;
    await _loadLinks(item);
    return item;
  }

  Future<List<UserCompletedExercise>> getPendingDeletes() async {
    final items = await _collection
        .filter()
        .pendingDeleteEqualTo(true)
        .findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<void> upsert(UserCompletedExercise item) async {
    await db.writeTxn(() async {
      await _collection.put(item);
    });
  }

  Future<void> deleteById(int id) async {
    await db.writeTxn(() async {
      await _collection.delete(id);
    });
  }

  Future<void> replaceForProgram(
    int completedProgramId,
    List<UserCompletedExercise> items,
  ) async {
    await db.writeTxn(() async {
      await _collection
          .filter()
          .completedProgramIdEqualTo(completedProgramId)
          .deleteAll();
      await _collection.putAll(items);
    });
  }

  Future<void> _loadLinks(UserCompletedExercise item) async {
    await item.exercise.load();
    await item.programExercise.load();
  }
}
