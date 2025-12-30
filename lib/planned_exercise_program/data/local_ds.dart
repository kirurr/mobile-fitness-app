import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/planned_exercise_program/model.dart';

class PlannedExerciseProgramLocalDataSource {
  late Isar db;

  IsarCollection<PlannedExerciseProgram> get _collection =>
      db.plannedExercisePrograms;
  IsarCollection<PlannedExerciseProgramDate> get _dates =>
      db.plannedExerciseProgramDates;

  PlannedExerciseProgramLocalDataSource(this.db);

  Stream<List<PlannedExerciseProgram>> watchAll() {
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

  Future<List<PlannedExerciseProgram>> getAll() async {
    final items =
        await _collection.filter().pendingDeleteEqualTo(false).findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<PlannedExerciseProgram?> getById(int id) async {
    final item = await _collection.get(id);
    if (item == null) return null;
    await _loadLinks(item);
    return item;
  }

  Future<List<PlannedExerciseProgram>> getUnsynced() async {
    final items = await _collection.filter().syncedEqualTo(false).findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<List<PlannedExerciseProgram>> getPendingDeletes() async {
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
    PlannedExerciseProgram item, {
    List<String>? datesOverride,
  }) async {
    final dates = datesOverride != null
        ? datesOverride
              .map(
                (d) => PlannedExerciseProgramDate(
                  id: Isar.autoIncrement,
                  plannedExerciseProgramId: item.id,
                  date: d,
                )..plannedProgram.value = item,
              )
              .toList()
        : item.dates.toList();

    final programId = await db.writeTxn(() async => _collection.put(item));
    item.id = programId;

    final preparedDates = dates
        .map(
          (date) => PlannedExerciseProgramDate(
            id: date.id,
            plannedExerciseProgramId: programId,
            date: date.date,
          )..plannedProgram.value = item,
        )
        .toList();

    await db.writeTxn(() async {
      await _dates
          .filter()
          .plannedExerciseProgramIdEqualTo(programId)
          .deleteAll();
      await _dates.putAll(preparedDates);
    });

    final managedProgram = await _collection.get(programId);
    if (managedProgram == null) return;

    final savedDates = await _dates
        .filter()
        .plannedExerciseProgramIdEqualTo(programId)
        .findAll();

    managedProgram.program.value = item.program.value;
    managedProgram.dates
      ..clear()
      ..addAll(savedDates);

    await db.writeTxn(() async {
      await managedProgram.program.save();
      await managedProgram.dates.save();
    });
  }

  Future<void> deleteById(int id) async {
    await db.writeTxn(() async {
      await _dates.filter().plannedExerciseProgramIdEqualTo(id).deleteAll();
      await _collection.delete(id);
    });
  }

  Future<void> replaceAll(List<PlannedExerciseProgram> items) async {
    final incomingIds = items.map((item) => item.id).toSet();
    final existing = await _collection.where().findAll();
    final existingById = {for (final item in existing) item.id: item};

    for (final item in items) {
      final localItem = existingById[item.id];
      if (localItem != null && await _isSameProgram(localItem, item)) {
        continue;
      }
      await upsert(item);
    }

    if (incomingIds.isEmpty) {
      await db.writeTxn(() async {
        await _dates.clear();
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

  Future<void> _loadLinks(PlannedExerciseProgram item) async {
    await item.program.load();
    final dates = await _dates
        .filter()
        .plannedExerciseProgramIdEqualTo(item.id)
        .findAll();
    item.dates
      ..clear()
      ..addAll(dates);
  }

  Future<bool> _isSameProgram(
    PlannedExerciseProgram existing,
    PlannedExerciseProgram incoming,
  ) async {
    await _loadLinks(existing);
    if (existing.programId != incoming.programId) return false;

    final existingDates = existing.dates.map((d) => d.date).toList()..sort();
    final incomingDates = incoming.dates.map((d) => d.date).toList()..sort();
    return _listEquals(existingDates, incomingDates);
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i += 1) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
