import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/user_completed_program/data/local_ds.dart';
import 'package:mobile_fitness_app/user_completed_program/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_completed_program/dto.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';

class UserCompletedProgramRepository {
  final UserCompletedProgramLocalDataSource local;
  final UserCompletedProgramRemoteDataSource remote;

  UserCompletedProgramRepository({required this.local, required this.remote});

  Stream<List<UserCompletedProgram>> watchCompletedPrograms() {
    return local.watchAll();
  }

  Future<List<UserCompletedProgram>> getLocalCompletedPrograms() {
    return local.getAll();
  }

  Future<void> refreshCompletedPrograms() async {
    try {
      final remoteItems = await remote.getAll();
      await local.replaceAll(remoteItems);
    } catch (e) {
      print('Error refreshing completed programs: $e');
      rethrow;
    }
  }

  Future<void> refreshLocalLinksForProgram(int programId) {
    return local.attachCompletedExercises(programId);
  }

  Future<UserCompletedProgram> create(UserCompletedProgramPayloadDTO payload) async {
    try {
      final created = await remote.create(payload);
      await local.upsert(created);
      return created;
    } catch (e) {
      final fallback = UserCompletedProgram(
        id: Isar.autoIncrement,
        userId: payload.userId,
        programId: payload.programId,
        startDate: payload.startDate ?? DateTime.now().toIso8601String(),
        endDate: payload.endDate,
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      );
      await local.upsert(fallback);
      return fallback;
    }
  }

  Future<UserCompletedProgram?> update(int id, UserCompletedProgramPayloadDTO payload) async {
    final existing = await local.getById(id);
    try {
      final updated = await remote.update(id, payload);
      if (existing != null) {
        updated.program.value ??= existing.program.value;
        updated.completedExercises.addAll(existing.completedExercises);
      }
      await local.upsert(updated);
      return updated;
    } catch (e) {
      if (existing != null) {
        final updatedLocal = UserCompletedProgram(
          id: existing.id,
          userId: existing.userId,
          programId: payload.programId,
          startDate: payload.startDate ?? existing.startDate,
          endDate: payload.endDate ?? existing.endDate,
          synced: false,
          pendingDelete: existing.pendingDelete,
          isLocalOnly: existing.isLocalOnly,
        );
        updatedLocal.program.value = existing.program.value;
        updatedLocal.completedExercises.addAll(existing.completedExercises);
        await local.upsert(updatedLocal);
        return updatedLocal;
      }
    }
    return null;
  }

  Future<void> delete(int id) async {
    try {
      await remote.delete(id);
      await local.deleteById(id);
    } catch (e) {
      final existing = await local.getById(id);
      if (existing != null) {
        final updatedLocal = UserCompletedProgram(
          id: existing.id,
          userId: existing.userId,
          programId: existing.programId,
          startDate: existing.startDate,
          endDate: existing.endDate,
          synced: false,
          pendingDelete: true,
          isLocalOnly: existing.isLocalOnly,
        );
        updatedLocal.program.value = existing.program.value;
        updatedLocal.completedExercises.addAll(existing.completedExercises);
        await local.upsert(updatedLocal);
      }
    }
  }

  Future<void> sync() async {
    final pendingDeletes = await local.getPendingDeletes();
    for (final item in pendingDeletes) {
      final payload = UserCompletedProgramPayloadDTO(
        userId: item.userId,
        programId: item.programId,
        startDate: item.startDate,
        endDate: item.endDate,
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
      final payload = UserCompletedProgramPayloadDTO(
        userId: item.userId,
        programId: item.programId,
        startDate: item.startDate,
        endDate: item.endDate,
      );
      try {
        if (item.isLocalOnly) {
          final created = await remote.create(payload);
          created.program.value ??= item.program.value;
          created.completedExercises.addAll(item.completedExercises);
          await local.deleteById(item.id);
          await local.upsert(created);
        } else {
          final updated = await remote.update(item.id, payload);
          updated.program.value ??= item.program.value;
          updated.completedExercises.addAll(item.completedExercises);
          await local.upsert(updated);
        }
      } catch (_) {
        continue;
      }
    }
  }
}
