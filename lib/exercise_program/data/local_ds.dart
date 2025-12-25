import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/exercise/model.dart';

class ExerciseProgramLocalDataSource {
  late Isar db;

  IsarCollection<ExerciseProgram> get _collection => db.exercisePrograms;
  IsarCollection<ProgramExercise> get _programExercises =>
      db.programExercises;

  ExerciseProgramLocalDataSource(this.db);

  Stream<List<ExerciseProgram>> watchAll() {
    return _collection.where().watch(fireImmediately: true).asyncMap((items) async {
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
      await upsert(item);
    }
  }

  Future<void> upsert(ExerciseProgram item) async {
    // Remove existing program exercises linked to this program id to avoid duplicates.
    await db.writeTxn(() async {
      await _programExercises.filter().program((q) => q.idEqualTo(item.id)).deleteAll();
    });

    // Persist program to get a managed instance.
    final programId = await db.writeTxn(() async => _collection.put(item));
    final managedProgram = await _collection.get(programId);
    if (managedProgram == null) return;

    // Copy scalar links onto managed object.
    managedProgram.difficultyLevel.value = item.difficultyLevel.value;
    managedProgram.subscription.value = item.subscription.value;
    managedProgram.fitnessGoals.addAll(item.fitnessGoals);

    // Prepare program exercises with links.
    final preparedProgramExercises = <ProgramExercise>[];
    for (final pe in item.programExercises) {
      pe.program.value = managedProgram;
      pe.exercise.value ??=
          await db.exercises.where().idEqualTo(pe.exerciseId).findFirst();
      preparedProgramExercises.add(pe);
    }

    // Persist program exercises and links in a dedicated transaction.
    await db.writeTxn(() async {
      final peIds = await _programExercises.putAll(preparedProgramExercises);
      final managedPEs = await _programExercises.getAll(peIds);

      managedProgram.programExercises.clear();
      managedProgram.programExercises.addAll(
        managedPEs.whereType<ProgramExercise>(),
      );

      await managedProgram.difficultyLevel.save();
      await managedProgram.subscription.save();
      await managedProgram.fitnessGoals.save();
      await managedProgram.programExercises.save();
    });
  }

  Future<void> deleteById(int id) async {
    await db.writeTxn(() async {
      await _programExercises.filter().program((q) => q.idEqualTo(id)).deleteAll();
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
