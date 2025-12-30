import 'package:mobile_fitness_app/user_completed_exercise/data/local_ds.dart';
import 'package:mobile_fitness_app/user_completed_exercise/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_completed_exercise/dto.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';
import 'dart:async';
import 'package:mobile_fitness_app/user_completed_program/model.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';

class UserCompletedExerciseRepository {
  final UserCompletedExerciseLocalDataSource local;
  final UserCompletedExerciseRemoteDataSource remote;

  UserCompletedExerciseRepository({required this.local, required this.remote});

  Stream<List<UserCompletedExercise>> watchCompletedExercises(
    int completedProgramId,
  ) {
    return local.watchByCompletedProgramId(completedProgramId);
  }

  Future<List<UserCompletedExercise>> getLocalCompletedExercises(
    int completedProgramId,
  ) {
    return local.getByCompletedProgramId(completedProgramId);
  }

  Future<void> refreshCompletedExercises(int completedProgramId) async {
    try {
      final remoteItems = await remote.getAll(completedProgramId);
      await local.replaceForProgram(completedProgramId, remoteItems);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCompletedExercise> create(
    UserCompletedExercisePayloadDTO payload, {
    int? id,
    bool triggerSync = true,
  }) async {
    final localId = id ?? _generateLocalId();
    final created = UserCompletedExercise(
      id: localId,
      completedProgramId: payload.completedProgramId,
      programExerciseId: payload.programExerciseId,
      exerciseId: payload.exerciseId,
      sets: payload.sets,
      reps: payload.reps,
      duration: payload.duration,
      weight: payload.weight,
      restDuration: payload.restDuration,
      synced: false,
      pendingDelete: false,
      isLocalOnly: true,
    );
    await local.upsert(created);
    if (triggerSync) {
      unawaited(sync());
    }
    return created;
  }

  Future<UserCompletedExercise?> update(
    int id,
    UserCompletedExercisePayloadDTO payload, {
    bool triggerSync = true,
  }) async {
    final existing = await local.getById(id);
    if (existing == null) {
      final created = UserCompletedExercise(
        id: id,
        completedProgramId: payload.completedProgramId,
        programExerciseId: payload.programExerciseId,
        exerciseId: payload.exerciseId,
        sets: payload.sets,
        reps: payload.reps,
        duration: payload.duration,
        weight: payload.weight,
        restDuration: payload.restDuration,
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      );
      await local.upsert(created);
      if (triggerSync) {
        unawaited(sync());
      }
      return created;
    }

    final updatedLocal = UserCompletedExercise(
      id: existing.id,
      completedProgramId: payload.completedProgramId,
      programExerciseId:
          payload.programExerciseId ?? existing.programExerciseId,
      exerciseId: payload.exerciseId ?? existing.exerciseId,
      sets: payload.sets,
      reps: payload.reps ?? existing.reps,
      duration: payload.duration ?? existing.duration,
      weight: payload.weight ?? existing.weight,
      restDuration: payload.restDuration ?? existing.restDuration,
      synced: false,
      pendingDelete: existing.pendingDelete,
      isLocalOnly: existing.isLocalOnly,
    );
    updatedLocal.programExercise.value = existing.programExercise.value;
    updatedLocal.exercise.value = existing.exercise.value;
    await local.upsert(updatedLocal);
    if (triggerSync) {
      unawaited(sync());
    }
    return updatedLocal;
  }

  Future<void> delete(int id) async {
    try {
      await remote.delete(id);
      await local.deleteById(id);
    } catch (e) {
      final existing = await local.getById(id);
      if (existing != null) {
        final updatedLocal = UserCompletedExercise(
          id: existing.id,
          completedProgramId: existing.completedProgramId,
          programExerciseId: existing.programExerciseId,
          exerciseId: existing.exerciseId,
          sets: existing.sets,
          reps: existing.reps,
          duration: existing.duration,
          weight: existing.weight,
          restDuration: existing.restDuration,
          synced: false,
          pendingDelete: true,
          isLocalOnly: existing.isLocalOnly,
        );
        updatedLocal.programExercise.value = existing.programExercise.value;
        updatedLocal.exercise.value = existing.exercise.value;
        await local.upsert(updatedLocal);
      }
    }
  }

  Future<void> sync() async {
    final pendingDeletes = await local.getPendingDeletes();
    for (final item in pendingDeletes) {
      try {
        await remote.delete(item.id);
        await local.deleteById(item.id);
      } catch (_) {
        continue;
      }
    }

    final unsynced = await local.getUnsynced();
    for (final item in unsynced) {
      if (item.pendingDelete) continue;
      if (!await _isCompletedProgramSynced(item.completedProgramId)) {
        continue;
      }
      final normalized = await _normalizeProgramExercise(item);
      final payload = UserCompletedExercisePayloadDTO(
        id: normalized.id,
        completedProgramId: normalized.completedProgramId,
        programExerciseId: normalized.programExerciseId,
        exerciseId: normalized.exerciseId,
        sets: normalized.sets,
        reps: normalized.reps,
        duration: normalized.duration,
        weight: normalized.weight,
        restDuration: normalized.restDuration,
      );
      try {
        if (normalized.isLocalOnly) {
          await remote.create(payload);
        } else {
          await remote.update(normalized.id, payload);
        }
        normalized.synced = true;
        normalized.isLocalOnly = false;
        await local.upsert(normalized);
      } catch (_) {
        continue;
      }
    }
  }

  int _generateLocalId() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  Future<bool> _isCompletedProgramSynced(int completedProgramId) async {
    final program = await local.db.userCompletedPrograms.get(completedProgramId);
    if (program == null) return true;
    return program.synced && !program.isLocalOnly;
  }

  Future<UserCompletedExercise> _normalizeProgramExercise(
    UserCompletedExercise item,
  ) async {
    final programExerciseId = item.programExerciseId;
    if (programExerciseId != null) {
      final exists = await local.db.programExercises.get(programExerciseId);
      if (exists != null) return item;
    }

    final resolvedProgramExerciseId =
        await _resolveProgramExerciseId(item);
    if (resolvedProgramExerciseId == null &&
        programExerciseId == null) {
      return item;
    }

    final resolvedExerciseId = item.exerciseId ?? item.exercise.value?.id;
    final updated = UserCompletedExercise(
      id: item.id,
      completedProgramId: item.completedProgramId,
      programExerciseId: resolvedProgramExerciseId,
      exerciseId: resolvedExerciseId,
      sets: item.sets,
      reps: item.reps,
      duration: item.duration,
      weight: item.weight,
      restDuration: item.restDuration,
      synced: false,
      pendingDelete: item.pendingDelete,
      isLocalOnly: item.isLocalOnly,
    );
    updated.exercise.value = item.exercise.value;
    await local.upsert(updated);
    return updated;
  }

  Future<int?> _resolveProgramExerciseId(
    UserCompletedExercise item,
  ) async {
    final completedProgram =
        await local.db.userCompletedPrograms.get(item.completedProgramId);
    if (completedProgram == null) return null;
    final program =
        await local.db.exercisePrograms.get(completedProgram.programId);
    if (program == null) return null;
    if (!program.synced || program.isLocalOnly) return null;
    await program.programExercises.load();
    final exerciseId = item.exerciseId ?? item.exercise.value?.id;
    if (exerciseId == null) return null;
    for (final pe in program.programExercises) {
      if (pe.exerciseId == exerciseId) return pe.id;
    }
    return null;
  }
}
