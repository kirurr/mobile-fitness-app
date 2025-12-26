import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/user_completed_exercise/data/local_ds.dart';
import 'package:mobile_fitness_app/user_completed_exercise/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_completed_exercise/dto.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';

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
      print('Error refreshing completed exercises: $e');
      rethrow;
    }
  }

  Future<void> create(UserCompletedExercisePayloadDTO payload) async {
    try {
      final created = await remote.create(payload);
      await local.upsert(created);
    } catch (e) {
      final fallback = UserCompletedExercise(
        id: Isar.autoIncrement,
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
      await local.upsert(fallback);
    }
  }

  Future<void> update(int id, UserCompletedExercisePayloadDTO payload) async {
    try {
      final updated = await remote.update(id, payload);
      await local.upsert(updated);
    } catch (e) {
      final existing = await local.getById(id);
      if (existing != null) {
        final updatedLocal = UserCompletedExercise(
          id: existing.id,
          completedProgramId: existing.completedProgramId,
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
      }
    }
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
      final payload = UserCompletedExercisePayloadDTO(
        completedProgramId: item.completedProgramId,
        programExerciseId: item.programExerciseId,
        exerciseId: item.exerciseId,
        sets: item.sets,
        reps: item.reps,
        duration: item.duration,
        weight: item.weight,
        restDuration: item.restDuration,
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
      final payload = UserCompletedExercisePayloadDTO(
        completedProgramId: item.completedProgramId,
        programExerciseId: item.programExerciseId,
        exerciseId: item.exerciseId,
        sets: item.sets,
        reps: item.reps,
        duration: item.duration,
        weight: item.weight,
        restDuration: item.restDuration,
      );
      try {
        if (item.isLocalOnly) {
          final created = await remote.create(payload);
          created.exercise.value ??= item.exercise.value;
          created.programExercise.value ??= item.programExercise.value;
          await local.deleteById(item.id);
          await local.upsert(created);
        } else {
          final updated = await remote.update(item.id, payload);
          updated.exercise.value ??= item.exercise.value;
          updated.programExercise.value ??= item.programExercise.value;
          await local.upsert(updated);
        }
      } catch (_) {
        continue;
      }
    }
  }
}
