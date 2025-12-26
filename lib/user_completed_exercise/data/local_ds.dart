import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';

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
        .map((items) => items);
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
    final id = await db.writeTxn(() async => _collection.put(item));
    final managed = await _collection.get(id);
    if (managed == null) return;

    await _attachLinks(managed);
    await db.writeTxn(() async {
      if (managed.exercise.value != null) {
        await managed.exercise.save();
      }
      if (managed.programExercise.value != null) {
        await managed.programExercise.save();
      }
    });
    await _attachToCompletedProgram(managed.completedProgramId);
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
    final ids = items.map((item) => item.id).toList(growable: false);
    await db.writeTxn(() async {
      await _collection
          .filter()
          .completedProgramIdEqualTo(completedProgramId)
          .deleteAll();
      await _collection.putAll(items);
    });
    if (ids.isEmpty) return;
    final managedItems = (await _collection.getAll(ids))
        .whereType<UserCompletedExercise>()
        .toList();
    for (final item in managedItems) {
      await _attachLinks(item);
    }
    await db.writeTxn(() async {
      for (final item in managedItems) {
        if (item.exercise.value != null) {
          await item.exercise.save();
        }
        if (item.programExercise.value != null) {
          await item.programExercise.save();
        }
      }
    });
    await _attachToCompletedProgram(completedProgramId);
  }

  Future<void> _attachLinks(UserCompletedExercise item) async {
    if (item.exercise.value == null && item.exerciseId != null) {
      item.exercise.value = await db.exercises.get(item.exerciseId!);
    }
    if (item.programExercise.value == null && item.programExerciseId != null) {
      item.programExercise.value =
          await db.programExercises.get(item.programExerciseId!);
    }
  }

  Future<void> _loadLinks(UserCompletedExercise item) async {
    await item.exercise.load();
    await item.programExercise.load();
  }

  Future<void> _attachToCompletedProgram(int completedProgramId) async {
    final program = await db.userCompletedPrograms.get(completedProgramId);
    if (program == null) return;
    final exercises = await _collection
        .filter()
        .completedProgramIdEqualTo(completedProgramId)
        .findAll();
    program.completedExercises
      ..clear()
      ..addAll(exercises);
    await db.writeTxn(() async {
      await program.completedExercises.save();
    });
  }
}
