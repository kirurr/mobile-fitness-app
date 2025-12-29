import 'package:mobile_fitness_app/user_completed_program/data/local_ds.dart';
import 'package:mobile_fitness_app/user_completed_program/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_completed_program/dto.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';
import 'dart:async';

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

  Future<UserCompletedProgram?> getLocalCompletedProgramById(int id) {
    return local.getById(id);
  }

  Future<void> refreshCompletedPrograms() async {
    try {
      final remoteItems = await remote.getAll();
      final localItems = await local.getAll();
      final localById = {
        for (final item in localItems) item.id: item,
      };
      for (final item in remoteItems) {
        final localItem = localById[item.id];
        if (localItem == null) continue;
        item.program.value ??= localItem.program.value;
        if (item.completedExercises.isEmpty &&
            localItem.completedExercises.isNotEmpty) {
          item.completedExercises.addAll(localItem.completedExercises);
        }
      }
      await local.replaceAll(remoteItems);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshLocalLinksForProgram(int programId) {
    return local.attachCompletedExercises(programId);
  }

  Future<UserCompletedProgram> create(
    UserCompletedProgramPayloadDTO payload, {
    int? id,
    bool triggerSync = true,
  }) async {
    final localId = id ?? _generateLocalId();
    final startDate = _normalizeStartDate(payload.startDate);
    final created = UserCompletedProgram(
      id: localId,
      userId: payload.userId,
      programId: payload.programId,
      startDate: startDate,
      endDate: _normalizeEndDate(payload.endDate),
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

  Future<UserCompletedProgram?> update(
    int id,
    UserCompletedProgramPayloadDTO payload, {
    bool triggerSync = true,
  }) async {
    final existing = await local.getById(id);
    if (existing == null) {
      final startDate = _normalizeStartDate(payload.startDate);
      final created = UserCompletedProgram(
        id: id,
        userId: payload.userId,
        programId: payload.programId,
        startDate: startDate,
        endDate: _normalizeEndDate(payload.endDate),
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

    final updatedLocal = UserCompletedProgram(
      id: existing.id,
      userId: existing.userId,
      programId: payload.programId,
      startDate: _normalizeStartDate(
        payload.startDate,
        fallback: existing.startDate,
      ),
      endDate: _normalizeEndDate(
        payload.endDate,
        fallback: existing.endDate,
      ),
      synced: false,
      pendingDelete: existing.pendingDelete,
      isLocalOnly: existing.isLocalOnly,
    );
    updatedLocal.program.value = existing.program.value;
    updatedLocal.completedExercises.addAll(existing.completedExercises);

    await local.upsert(
      updatedLocal,
      completedExercisesOverride: existing.completedExercises.toList(),
    );
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
      final payload = UserCompletedProgramPayloadDTO(
        id: item.id,
        userId: item.userId,
        programId: item.programId,
        startDate: item.startDate,
        endDate: item.endDate,
      );
      try {
        if (item.isLocalOnly) {
          await remote.create(payload);
        } else {
          await remote.update(item.id, payload);
        }
        item.synced = true;
        item.isLocalOnly = false;
        item.pendingDelete = false;
        final exercisesOverride = item.completedExercises.toList();
        await local.upsert(
          item,
          completedExercisesOverride: exercisesOverride,
          forceReplaceExercises: exercisesOverride.isNotEmpty,
        );
      } catch (_) {
        continue;
      }
    }
  }

  int _generateLocalId() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  String _nowIso() {
    return DateTime.now().toUtc().toIso8601String();
  }

  String _normalizeStartDate(String? startDate, {String? fallback}) {
    final trimmed = startDate?.trim() ?? '';
    if (trimmed.isEmpty) {
      return fallback ?? _nowIso();
    }
    return trimmed;
  }

  String? _normalizeEndDate(String? endDate, {String? fallback}) {
    final trimmed = endDate?.trim() ?? '';
    if (trimmed.isEmpty) {
      return fallback;
    }
    return trimmed;
  }

}
