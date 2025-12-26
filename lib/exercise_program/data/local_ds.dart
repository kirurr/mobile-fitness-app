import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise_program/dto.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/subscription/model.dart';

class ExerciseProgramLocalDataSource {
  late Isar db;

  IsarCollection<ExerciseProgram> get _collection => db.exercisePrograms;
  IsarCollection<ProgramExercise> get _programExercises => db.programExercises;

  ExerciseProgramLocalDataSource(this.db);

  Stream<List<ExerciseProgram>> watchAll() {
    return _collection.where().watch(fireImmediately: true).asyncMap((
      items,
    ) async {
      for (final item in items) {
        await _loadLinks(item);
      }
      return items;
    });
  }

  Future<List<ExerciseProgram>> getAll() async {
    final items = await _collection.where().findAll();
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

  Future<void> replaceAll(List<ExerciseProgram> items) async {
    // Clear existing data in one transaction.
    await db.writeTxn(() async {
      await _collection.clear();
      await _programExercises.clear();
    });

    // Save each program and its links in isolated transactions to avoid nested tx issues.
    for (final item in items) {
      await create(item);
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

  // Future<void> testUpdate(int id, ExerciseProgramPayloadDTO payload) async {
  //   await db.writeTxn(() async {
  //     final existing = await _collection.get(id);

  //     if (existing == null) {
  //       print('existing is null');
  //       return;
  //     }

  //     // Перезаписываем объект (delete не обязателен, но пусть остаётся)
  //     await _collection.delete(id);

  //     final newProgram = ExerciseProgram(
  //       id: id,
  //       userId: existing.userId,
  //       name: payload.name,
  //       description: payload.description,
  //     );

  //     // сохраняем, чтобы объект был attached
  //     await _collection.put(newProgram);

  //     // ---- ссылки ----

  //     // difficulty level
  //     if (payload.difficultyLevelId != null) {
  //       newProgram.difficultyLevel.value = await db.difficultyLevels.get(
  //         payload.difficultyLevelId!,
  //       );
  //     } else {
  //       newProgram.difficultyLevel.value = null;
  //     }

  //     // subscription
  //     if (payload.subscriptionId != null) {
  //       newProgram.subscription.value = await db.subscriptions.get(
  //         payload.subscriptionId!,
  //       );
  //     } else {
  //       newProgram.subscription.value = null;
  //     }

  //     // fitness goals
  //     if (payload.fitnessGoalIds.isNotEmpty) {
  //       final goals = await db.fitnessGoals
  //           .where()
  //           .anyOf(payload.fitnessGoalIds, (q, id) => q.idEqualTo(id))
  //           .findAll();

  //       newProgram.fitnessGoals
  //         ..clear()
  //         ..addAll(goals);
  //     }

  //     // exercises (Фильтруем null ids!)
  //     final exerciseIds = payload.exercises
  //         .map((e) => e.id)
  //         .whereType<int>() // ← убирает null
  //         .toList();

  //     if (exerciseIds.isNotEmpty) {
  //       final programExercises = await db.programExercises
  //           .where()
  //           .anyOf(exerciseIds, (q, id) => q.idEqualTo(id))
  //           .findAll();

  //       newProgram.programExercises
  //         ..clear()
  //         ..addAll(programExercises);
  //     }

  //     // ---- сохраняем ссылки ----
  //     await newProgram.difficultyLevel.save();
  //     await newProgram.subscription.save();
  //     await newProgram.fitnessGoals.save();
  //     await newProgram.programExercises.save();
  //   });
  // }

  Future<void> updateFromPayload(
    int id,
    ExerciseProgramPayloadDTO payload,
  ) async {
    final existing = await _collection.get(id);
    final userId = payload.userId ?? existing?.userId;

    final difficulty = await db.difficultyLevels.get(payload.difficultyLevelId);
    final subscription = payload.subscriptionId == null
        ? null
        : await db.subscriptions.get(payload.subscriptionId!);
    final goals = payload.fitnessGoalIds.isEmpty
        ? <FitnessGoal>[]
        : await db.fitnessGoals
              .where()
              .anyOf(payload.fitnessGoalIds, (q, id) => q.idEqualTo(id))
              .findAll();

    final program = ExerciseProgram(
      id: id,
      userId: userId,
      name: payload.name,
      description: payload.description,
    );

    if (difficulty != null) {
      program.difficultyLevel.value = difficulty;
    }
    if (subscription != null) {
      program.subscription.value = subscription;
    }
    program.fitnessGoals.addAll(goals);

    final programExercises = payload.exercises
        .map(
          (e) => ProgramExercise(
            id: e.id ?? Isar.autoIncrement,
            exerciseId: e.exerciseId,
            order: e.order,
            sets: e.sets,
            reps: e.reps,
            duration: e.duration,
            restDuration: e.restDuration,
          ),
        )
        .toList();

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
  }) async {
    try {
      final incomingProgramExercises =
          programExercisesOverride ?? item.programExercises.toList();
      print(
        'ExerciseProgramLocalDataSource._saveProgram: programId=${item.id}, '
        'incomingExercises=${incomingProgramExercises.length}, '
        'clearExisting=$clearExistingExercises',
      );
      final difficulty = item.difficultyLevel.value;
      final subscription = item.subscription.value;
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
      print(
        'ExerciseProgramLocalDataSource._saveProgram: '
        'exerciseIds=${exerciseIds.length}, exerciseMap=${exerciseMap.length}',
      );

      final createdProgramExercises = incomingProgramExercises
          .map(
            (pe) => ProgramExercise(
              id: Isar.autoIncrement,
              exerciseId: pe.exerciseId,
              order: pe.order,
              sets: pe.sets,
              reps: pe.reps,
              duration: pe.duration,
              restDuration: pe.restDuration,
            ),
          )
          .toList();
      print(
        'ExerciseProgramLocalDataSource._saveProgram: '
        'createdProgramExercises=${createdProgramExercises.length}',
      );

      await db.writeTxn(() async {
        final programId = await _collection.put(item);
        final managedProgram = await _collection.get(programId);
        if (managedProgram == null) return;

        if (clearExistingExercises) {
          await _programExercises
              .filter()
              .program((q) => q.idEqualTo(item.id))
              .deleteAll();
        }

        // 1) Create ProgramExercise rows first (no links yet).
        final peIds = await _programExercises.putAll(createdProgramExercises);
        print(
          'ExerciseProgramLocalDataSource._saveProgram: '
          'putAllIds=${peIds.length}',
        );
        final managedPEs = (await _programExercises.getAll(peIds))
            .whereType<ProgramExercise>()
            .toList();
        print(
          'ExerciseProgramLocalDataSource._saveProgram: '
          'managedPEs=${managedPEs.length}',
        );

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
        managedProgram.difficultyLevel.value = difficulty;
        managedProgram.subscription.value = subscription;
        managedProgram.fitnessGoals
          ..clear()
          ..addAll(fitnessGoals);

        await managedProgram.difficultyLevel.save();
        await managedProgram.subscription.save();
        await managedProgram.fitnessGoals.save();
        await managedProgram.programExercises.save();
      });
    } catch (e, stackTrace) {
      print('ExerciseProgramLocalDataSource._saveProgram failed: $e');
      print(stackTrace);
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
}
