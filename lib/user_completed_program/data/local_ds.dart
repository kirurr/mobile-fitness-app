import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';

class UserCompletedProgramLocalDataSource {
  late Isar db;

  IsarCollection<UserCompletedProgram> get _collection =>
      db.userCompletedPrograms;
  IsarCollection<UserCompletedExercise> get _completedExercises =>
      db.userCompletedExercises;

  UserCompletedProgramLocalDataSource(this.db);

  Stream<List<UserCompletedProgram>> watchAll() {
    return _collection
        .filter()
        .pendingDeleteEqualTo(false)
        .watch(fireImmediately: true)
        .asyncMap((
      items,
    ) async {
      for (final item in items) {
        await _loadLinks(item);
      }
      return items;
    });
  }

  Future<List<UserCompletedProgram>> getAll() async {
    final items =
        await _collection.filter().pendingDeleteEqualTo(false).findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<UserCompletedProgram?> getById(int id) async {
    final item = await _collection.get(id);
    if (item == null) return null;
    await _loadLinks(item);
    return item;
  }

  Future<List<UserCompletedProgram>> getUnsynced() async {
    final items = await _collection.filter().syncedEqualTo(false).findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<List<UserCompletedProgram>> getPendingDeletes() async {
    final items = await _collection
        .filter()
        .pendingDeleteEqualTo(true)
        .findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<void> upsert(
    UserCompletedProgram item, {
    List<UserCompletedExercise>? completedExercisesOverride,
    bool forceReplaceExercises = false,
  }) async {
    final exercises =
        completedExercisesOverride ?? item.completedExercises.toList();
    final shouldReplaceExercises =
        forceReplaceExercises || exercises.isNotEmpty;

    await db.writeTxn(() async {
      await _collection.put(item);
    });

    final programId = item.id;

    final preparedExercises = exercises
        .map(
          (exercise) =>
              UserCompletedExercise(
                  id: exercise.id,
                  completedProgramId: programId,
                  programExerciseId: exercise.programExerciseId,
                  exerciseId: exercise.exerciseId,
                  sets: exercise.sets,
                  reps: exercise.reps,
                  duration: exercise.duration,
                  weight: exercise.weight,
                  restDuration: exercise.restDuration,
                  synced: exercise.synced,
                  pendingDelete: exercise.pendingDelete,
                  isLocalOnly: exercise.isLocalOnly,
                )
                ..programExercise.value = exercise.programExercise.value
                ..exercise.value = exercise.exercise.value,
        )
        .toList();

    if (shouldReplaceExercises) {
      await db.writeTxn(() async {
        await _completedExercises
            .filter()
            .completedProgramIdEqualTo(programId)
            .deleteAll();
        await _completedExercises.putAll(preparedExercises);
      });

      final managedProgram = await _collection.get(programId);
      if (managedProgram == null) return;

      final savedExercises = await _completedExercises
          .filter()
          .completedProgramIdEqualTo(programId)
          .findAll();

      for (final exercise in savedExercises) {
        if (exercise.exercise.value == null && exercise.exerciseId != null) {
          exercise.exercise.value = await db.exercises.get(exercise.exerciseId!);
        }
        if (exercise.programExercise.value == null &&
            exercise.programExerciseId != null) {
          exercise.programExercise.value =
              await db.programExercises.get(exercise.programExerciseId!);
        }
      }

      managedProgram.program.value = item.program.value;
      managedProgram.completedExercises
        ..clear()
        ..addAll(savedExercises);

      await db.writeTxn(() async {
        for (final exercise in savedExercises) {
          if (exercise.exercise.value != null) {
            await exercise.exercise.save();
          }
          if (exercise.programExercise.value != null) {
            await exercise.programExercise.save();
          }
        }
        await managedProgram.program.save();
        await managedProgram.completedExercises.save();
      });
    } else {
      final managedProgram = await _collection.get(programId);
      if (managedProgram == null) return;
      managedProgram.program.value = item.program.value;
      await db.writeTxn(() async {
        await managedProgram.program.save();
      });
    }
  }

  Future<void> attachCompletedExercises(int programId) async {
    final program = await _collection.get(programId);
    if (program == null) return;
    final exercises = await _completedExercises
        .filter()
        .completedProgramIdEqualTo(programId)
        .findAll();
    program.completedExercises
      ..clear()
      ..addAll(exercises);
    await db.writeTxn(() async {
      await program.completedExercises.save();
    });
  }

  Future<void> deleteById(int id) async {
    await db.writeTxn(() async {
      await _completedExercises
          .filter()
          .completedProgramIdEqualTo(id)
          .deleteAll();
      await _collection.delete(id);
    });
  }

  Future<void> replaceAll(List<UserCompletedProgram> items) async {
    final incomingIds = items.map((item) => item.id).toSet();
    final existing = await _collection.where().findAll();
    final existingById = {for (final item in existing) item.id: item};

    for (final item in items) {
      final localItem = existingById[item.id];
      if (localItem != null && await _isSameProgram(localItem, item)) {
        continue;
      }
      await upsert(item, forceReplaceExercises: true);
    }

    if (incomingIds.isEmpty) {
      await db.writeTxn(() async {
        await _completedExercises.clear();
        await _collection.clear();
      });
      return;
    }

    for (final item in existing) {
      if (!incomingIds.contains(item.id)) {
        await deleteById(item.id);
      }
    }
  }

  Future<void> _loadLinks(UserCompletedProgram item) async {
    await item.program.load();
    final exercises = await _completedExercises
        .filter()
        .completedProgramIdEqualTo(item.id)
        .findAll();
    for (final exercise in exercises) {
      await exercise.exercise.load();
      await exercise.programExercise.load();
    }
    item.completedExercises
      ..clear()
      ..addAll(exercises);
  }

  Future<bool> _isSameProgram(
    UserCompletedProgram existing,
    UserCompletedProgram incoming,
  ) async {
    await _loadLinks(existing);

    if (existing.userId != incoming.userId ||
        existing.programId != incoming.programId ||
        existing.startDate != incoming.startDate ||
        existing.endDate != incoming.endDate) {
      return false;
    }

    final existingExercises = existing.completedExercises
        .map(_completedExerciseKey)
        .toList()
      ..sort();
    final incomingExercises = incoming.completedExercises
        .map(_completedExerciseKey)
        .toList()
      ..sort();
    return _listEquals(existingExercises, incomingExercises);
  }

  String _completedExerciseKey(UserCompletedExercise item) {
    return '${item.id}|${item.programExerciseId}|${item.exerciseId}|'
        '${item.sets}|${item.reps}|${item.duration}|${item.weight}|'
        '${item.restDuration}';
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
