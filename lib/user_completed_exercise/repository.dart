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

  Future<UserCompletedExercise> create(
    UserCompletedExercisePayloadDTO payload,
  ) async {
      final created = await remote.create(payload);
      final merged = _mergeWithPayload(created, payload);
      await local.upsert(merged);
      print('merged create');
      print(merged.programExerciseId);
      print(merged.programExercise);
      return merged;
  }

  Future<UserCompletedExercise?> update(
    int id,
    UserCompletedExercisePayloadDTO payload,
  ) async {
    final existing = await local.getById(id);
    final updated = await remote.update(id, payload);
    final merged = _mergeWithPayload(updated, payload, existing: existing);
    await local.upsert(merged);
    print('merged update');
    print(merged.programExerciseId);
    print(merged.programExercise);
    return merged;
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
          final merged = _mergeWithPayload(created, payload, existing: item);
          merged.exercise.value ??= item.exercise.value;
          merged.programExercise.value ??= item.programExercise.value;
          await local.deleteById(item.id);
          await local.upsert(merged);
        } else {
          final updated = await remote.update(item.id, payload);
          final merged = _mergeWithPayload(updated, payload, existing: item);
          merged.exercise.value ??= item.exercise.value;
          merged.programExercise.value ??= item.programExercise.value;
          await local.upsert(merged);
        }
      } catch (_) {
        continue;
      }
    }
  }

  UserCompletedExercise _mergeWithPayload(
    UserCompletedExercise remoteItem,
    UserCompletedExercisePayloadDTO payload, {
    UserCompletedExercise? existing,
  }) {
    final merged = UserCompletedExercise(
      id: remoteItem.id,
      completedProgramId: remoteItem.completedProgramId,
      programExerciseId:
          remoteItem.programExerciseId ??
          payload.programExerciseId ??
          existing?.programExerciseId,
      exerciseId:
          remoteItem.exerciseId ?? payload.exerciseId ?? existing?.exerciseId,
      sets: remoteItem.sets,
      reps: remoteItem.reps,
      duration: remoteItem.duration,
      weight: remoteItem.weight,
      restDuration: remoteItem.restDuration,
      synced: remoteItem.synced,
      pendingDelete: remoteItem.pendingDelete,
      isLocalOnly: remoteItem.isLocalOnly,
    );
    merged.exercise.value =
        remoteItem.exercise.value ?? existing?.exercise.value;
    merged.programExercise.value =
        remoteItem.programExercise.value ?? existing?.programExercise.value;
    return merged;
  }
}
