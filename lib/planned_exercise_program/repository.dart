import 'package:mobile_fitness_app/planned_exercise_program/data/local_ds.dart';
import 'package:mobile_fitness_app/planned_exercise_program/data/remote_ds.dart';
import 'package:mobile_fitness_app/planned_exercise_program/dto.dart';
import 'package:mobile_fitness_app/planned_exercise_program/model.dart';
import 'dart:async';

class PlannedExerciseProgramRepository {
  final PlannedExerciseProgramLocalDataSource local;
  final PlannedExerciseProgramRemoteDataSource remote;

  PlannedExerciseProgramRepository({required this.local, required this.remote});

  Stream<List<PlannedExerciseProgram>> watchPlannedPrograms() {
    return local.watchAll();
  }

  Future<List<PlannedExerciseProgram>> getLocalPlannedPrograms() {
    return local.getAll();
  }

  Future<PlannedExerciseProgram?> getLocalPlannedProgramById(int id) {
    return local.getById(id);
  }

  Future<void> refreshPlannedPrograms() async {
    try {
      final remoteItems = await remote.getAll();
      await local.replaceAll(remoteItems);
    } catch (e) {
      print('Error refreshing planned exercise programs: $e');
      rethrow;
    }
  }

  Future<void> create(
    PlannedExerciseProgramPayloadDTO payload, {
    int? id,
  }) async {
    final programId = id ?? _generateLocalId();
    final created = PlannedExerciseProgram(
      id: programId,
      programId: payload.programId,
      synced: false,
      pendingDelete: false,
      isLocalOnly: true,
    );
    created.dates.addAll(
      payload.dates.asMap().entries.map((entry) {
        final idx = entry.key;
        final date = entry.value;
        return PlannedExerciseProgramDate(
          id: programId + idx + 1,
          plannedExerciseProgramId: created.id,
          date: date,
        )..plannedProgram.value = created;
      }).toList(),
    );
    await local.upsert(created, datesOverride: payload.dates);
    unawaited(sync());
  }

  Future<void> update(int id, PlannedExerciseProgramPayloadDTO payload) async {
    final existing = await local.getById(id);
    if (existing == null) {
      final programId = id;
      final created = PlannedExerciseProgram(
        id: programId,
        programId: payload.programId,
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      );
      created.dates.addAll(
        payload.dates.asMap().entries.map((entry) {
          final idx = entry.key;
          final date = entry.value;
          return PlannedExerciseProgramDate(
            id: programId + idx + 1,
            plannedExerciseProgramId: created.id,
            date: date,
          )..plannedProgram.value = created;
        }).toList(),
      );
      await local.upsert(created, datesOverride: payload.dates);
      unawaited(sync());
      return;
    }

    final updatedLocal = PlannedExerciseProgram(
      id: existing.id,
      programId: payload.programId,
      synced: false,
      pendingDelete: existing.pendingDelete,
      isLocalOnly: existing.isLocalOnly,
    );
    updatedLocal.program.value = existing.program.value;
    updatedLocal.dates.addAll(
      payload.dates.asMap().entries.map((entry) {
        final idx = entry.key;
        final date = entry.value;
        return PlannedExerciseProgramDate(
          id: existing.id + idx + 1,
          plannedExerciseProgramId: existing.id,
          date: date,
        )..plannedProgram.value = existing;
      }).toList(),
    );
    await local.upsert(updatedLocal, datesOverride: payload.dates);
    unawaited(sync());
  }

  Future<void> delete(int id) async {
    try {
      await remote.delete(id);
      await local.deleteById(id);
    } catch (e) {
      final existing = await local.getById(id);
      if (existing != null) {
        final updatedLocal = PlannedExerciseProgram(
          id: existing.id,
          programId: existing.programId,
          synced: false,
          pendingDelete: true,
          isLocalOnly: existing.isLocalOnly,
        );
        updatedLocal.program.value = existing.program.value;
        updatedLocal.dates.addAll(existing.dates);
        await local.upsert(updatedLocal);
      }
    }
  }

  Future<void> sync() async {
    final pendingDeletes = await local.getPendingDeletes();
    for (final item in pendingDeletes) {
      final payload = PlannedExerciseProgramPayloadDTO(
        programId: item.programId,
        dates: item.dates.map((d) => d.date).toList(),
      );
      try {
        await remote.delete(item.id);
        await local.deleteById(item.id);
      } catch (_) {
        try {
          final created = await remote.create(payload);
          await remote.delete(created.id);
          await local.deleteById(item.id);
        } catch (_) {
          continue;
        }
      }
    }

    final unsynced = await local.getUnsynced();
    for (final item in unsynced) {
      if (item.pendingDelete) continue;
      final payload = PlannedExerciseProgramPayloadDTO(
        programId: item.programId,
        dates: item.dates.map((d) => d.date).toList(),
      );
      try {
        if (item.isLocalOnly) {
          final created = await remote.create(payload);
          created.program.value ??= item.program.value;
          created.dates.addAll(item.dates);
          await local.deleteById(item.id);
          await local.upsert(created);
        } else {
          final updated = await remote.update(item.id, payload);
          updated.program.value ??= item.program.value;
          updated.dates.addAll(item.dates);
          await local.upsert(updated);
        }
      } catch (_) {
        continue;
      }
    }
  }

  int _generateLocalId() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}
