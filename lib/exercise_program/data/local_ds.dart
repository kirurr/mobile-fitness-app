import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/exercise/model.dart';

class ExerciseProgramLocalDataSource {
  late Isar db;

  IsarCollection<ExerciseProgram> get _collection => db.exercisePrograms;
  IsarCollection<ProgramExercise> get _programExercises => db.programExercises;

  ExerciseProgramLocalDataSource(this.db);

  Stream<List<ExerciseProgram>> watchAll() {
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

  Future<List<ExerciseProgram>> getAll() async {
    final items =
        await _collection.filter().pendingDeleteEqualTo(false).findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<ExerciseProgram?> getById(int id) async {
    final item = await _collection.get(id);
    if (item == null) return null;
    await _loadLinks(item);
    return item;
  }

  Future<List<ExerciseProgram>> getUnsynced() async {
    final items = await _collection.filter().syncedEqualTo(false).findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<List<ExerciseProgram>> getPendingDeletes() async {
    final items = await _collection
        .filter()
        .pendingDeleteEqualTo(true)
        .findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<void> replaceAll(List<ExerciseProgram> items) async {
    final incomingIds = items.map((item) => item.id).toSet();
    final existing = await _collection.where().findAll();
    final existingById = {for (final item in existing) item.id: item};

    for (final item in items) {
      final localItem = existingById[item.id];
      if (localItem != null && await _isSameProgram(localItem, item)) {
        continue;
      }
      await _saveProgram(
        item,
        clearExistingExercises: true,
        programExercisesOverride: item.programExercises.toList(),
        forceReplaceProgramExercises: true,
      );
    }

    if (incomingIds.isEmpty) {
      await db.writeTxn(() async {
        await _programExercises.clear();
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

  // Future<void> upsert(ExerciseProgram item) async {
  //   // Clear old program exercises first to avoid duplicates on re-save.
  //   await db.writeTxn(() async {
  //     await _programExercises
  //         .filter()
  //         .program((q) => q.idEqualTo(item.id))
  //         .deleteAll();
  //   });

  //   // Save program and get a managed instance.
  //   final programId = await db.writeTxn(() async => _collection.put(item));
  //   final managedProgram = await _collection.get(programId);
  //   if (managedProgram == null) return;

  //   // Update program links from the incoming model.
  //   managedProgram.difficultyLevel.value = item.difficultyLevel.value;
  //   managedProgram.subscription.value = item.subscription.value;
  //   managedProgram.fitnessGoals
  //     ..clear()
  //     ..addAll(item.fitnessGoals);

  //   // Ensure exercises for program exercises are linked before persisting.
  //   final preparedProgramExercises = <ProgramExercise>[];
  //   final exerciseIds = <int>{};
  //   for (final pe in item.programExercises) {
  //     pe.program.value = managedProgram;
  //     exerciseIds.add(pe.exerciseId);
  //     pe.exercise.value ??= await db.exercises.get(pe.exerciseId);
  //     preparedProgramExercises.add(pe);
  //   }

  //   final exerciseMap = exerciseIds.isEmpty
  //       ? <int, Exercise>{}
  //       : {
  //           for (final ex in await db.exercises
  //               .where()
  //               .anyOf(exerciseIds.toList(), (q, id) => q.idEqualTo(id))
  //               .findAll())
  //             ex.id: ex
  //         };

  //   await db.writeTxn(() async {
  //     final peIds = await _programExercises.putAll(preparedProgramExercises);
  //     final managedPEs =
  //         (await _programExercises.getAll(peIds)).whereType<ProgramExercise>().toList();

  //     managedProgram.programExercises
  //       ..clear()
  //       ..addAll(managedPEs);

  //     for (final pe in managedPEs) {
  //       final exercise = exerciseMap[pe.exerciseId];
  //       if (exercise != null) {
  //         pe.exercise.value = exercise;
  //         await pe.exercise.save();
  //       }
  //       pe.program.value = managedProgram;
  //       await pe.program.save();
  //     }

  //     await managedProgram.difficultyLevel.save();
  //     await managedProgram.subscription.save();
  //     await managedProgram.fitnessGoals.save();
  //     await managedProgram.programExercises.save();
  //   });
  // }

  Future<void> create(
    ExerciseProgram item, {
    List<ProgramExercise>? programExercises,
  }) async {
    await _saveProgram(
      item,
      clearExistingExercises: false,
      programExercisesOverride: programExercises,
    );
  }

  Future<void> update(
    ExerciseProgram item, {
    List<ProgramExercise>? programExercises,
  }) async {
    await _saveProgram(
      item,
      clearExistingExercises: true,
      programExercisesOverride: programExercises,
    );
  }

  Future<void> updateFromProgram(ExerciseProgram program,
    List<ProgramExercise>? programExercises,
  ) async {
    await _saveProgram(
      program,
      clearExistingExercises: true,
      programExercisesOverride: programExercises,
    );
  }

  Future<void> _saveProgram(
    ExerciseProgram item, {
    required bool clearExistingExercises,
    List<ProgramExercise>? programExercisesOverride,
    bool forceReplaceProgramExercises = false,
  }) async {
    try {
      final incomingProgramExercises =
          programExercisesOverride ?? item.programExercises.toList();
      final shouldUpdateProgramExercises =
          forceReplaceProgramExercises || incomingProgramExercises.isNotEmpty;
      final difficulty =
          item.difficultyLevel.isNotEmpty
              ? item.difficultyLevel.first
              : null;
      final subscription =
          item.subscription.isNotEmpty ? item.subscription.first : null;
      final fitnessGoals = item.fitnessGoals.toList();

      final exerciseIds = incomingProgramExercises
          .map((pe) => pe.exerciseId)
          .toSet()
          .toList();
      final exerciseMap = exerciseIds.isEmpty
          ? <int, Exercise>{}
          : {
              for (final ex
                  in await db.exercises
                      .where()
                      .anyOf(exerciseIds, (q, id) => q.idEqualTo(id))
                      .findAll())
                ex.id: ex,
            };

      final createdProgramExercises = incomingProgramExercises
          .map(
            (pe) => ProgramExercise(
              id: pe.id,
              exerciseId: pe.exerciseId,
              order: pe.order,
              sets: pe.sets,
              reps: pe.reps,
              duration: pe.duration,
              restDuration: pe.restDuration,
            ),
          )
          .toList();

      await db.writeTxn(() async {
        final programId = await _collection.put(item);
        item.id = programId;
        final managedProgram = item;

        if (shouldUpdateProgramExercises) {
          if (clearExistingExercises) {
            await _programExercises
                .filter()
                .program((q) => q.idEqualTo(item.id))
                .deleteAll();
          }

          // 1) Create ProgramExercise rows first (no links yet).
          final peIds = await _programExercises.putAll(createdProgramExercises);
          final managedPEs = (await _programExercises.getAll(peIds))
              .whereType<ProgramExercise>()
              .toList();

          // 2) Attach relations to ProgramExercise and save links.
          for (final pe in managedPEs) {
            pe.program.value = managedProgram;
            await pe.program.save();

            final exercise = exerciseMap[pe.exerciseId];
            if (exercise != null) {
              pe.exercise.value = exercise;
              await pe.exercise.save();
            }
          }

          // 3) Attach ProgramExercise list to ExerciseProgram and save links.
          managedProgram.programExercises
            ..clear()
            ..addAll(managedPEs);
        }
        managedProgram.difficultyLevel
          .clear();
        if (difficulty != null) {
          managedProgram.difficultyLevel.add(difficulty);
        }
        managedProgram.subscription
          .clear();
        if (subscription != null) {
          managedProgram.subscription.add(subscription);
        }
        managedProgram.fitnessGoals
          ..clear()
          ..addAll(fitnessGoals);

        await managedProgram.difficultyLevel.save();
        await managedProgram.subscription.save();
        await managedProgram.fitnessGoals.save();
        if (shouldUpdateProgramExercises) {
          await managedProgram.programExercises.save();
        }
      });
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteById(int id) async {
    await db.writeTxn(() async {
      await _programExercises
          .filter()
          .program((q) => q.idEqualTo(id))
          .deleteAll();
      await _collection.delete(id);
    });
  }

  Future<void> _loadLinks(ExerciseProgram item) async {
    await item.difficultyLevel.load();
    await item.subscription.load();
    await item.fitnessGoals.load();
    await item.programExercises.load();
    for (final pe in item.programExercises) {
      await pe.exercise.load();
    }
  }

  Future<bool> _isSameProgram(
    ExerciseProgram existing,
    ExerciseProgram incoming,
  ) async {
    await _loadLinks(existing);

    if (existing.userId != incoming.userId ||
        existing.name != incoming.name ||
        existing.description != incoming.description ||
        existing.isUserAdded != incoming.isUserAdded) {
      return false;
    }

    final existingDifficultyId =
        existing.difficultyLevel.isNotEmpty
            ? existing.difficultyLevel.first.id
            : null;
    final incomingDifficultyId =
        incoming.difficultyLevel.isNotEmpty
            ? incoming.difficultyLevel.first.id
            : null;
    if (existingDifficultyId != incomingDifficultyId) {
      return false;
    }

    final existingSubscriptionId =
        existing.subscription.isNotEmpty
            ? existing.subscription.first.id
            : null;
    final incomingSubscriptionId =
        incoming.subscription.isNotEmpty
            ? incoming.subscription.first.id
            : null;
    if (existingSubscriptionId != incomingSubscriptionId) {
      return false;
    }

    final existingGoals = existing.fitnessGoals
        .map((goal) => goal.id)
        .toList()
      ..sort();
    final incomingGoals = incoming.fitnessGoals
        .map((goal) => goal.id)
        .toList()
      ..sort();
    if (!_listEquals(existingGoals, incomingGoals)) {
      return false;
    }

    final existingExercises = existing.programExercises
        .map(_programExerciseKey)
        .toList()
      ..sort();
    final incomingExercises = incoming.programExercises
        .map(_programExerciseKey)
        .toList()
      ..sort();
    if (!_listEquals(existingExercises, incomingExercises)) {
      return false;
    }

    return true;
  }

  String _programExerciseKey(ProgramExercise item) {
    return '${item.id}|${item.exerciseId}|${item.order}|${item.sets}|'
        '${item.reps}|${item.duration}|${item.restDuration}';
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
