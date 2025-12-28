import 'dart:async';
import 'package:mobile_fitness_app/exercise_program/data/local_ds.dart';
import 'package:mobile_fitness_app/exercise_program/data/remote_ds.dart';
import 'package:mobile_fitness_app/exercise_program/dto.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';

class ExerciseProgramRepository {
  final ExerciseProgramLocalDataSource local;
  final ExerciseProgramRemoteDataSource remote;

  ExerciseProgramRepository({required this.local, required this.remote});

  Stream<List<ExerciseProgram>> watchPrograms() {
    return local.watchAll();
  }

  Future<List<ExerciseProgram>> getLocalPrograms() {
    return local.getAll();
  }

  Future<void> refreshPrograms({
    int? difficultyLevelId,
    int? subscriptionId,
    int? fitnessGoalId,
    int? userId,
  }) async {
    try {
      final remoteItems = await remote.getAll(
        difficultyLevelId: difficultyLevelId,
        subscriptionId: subscriptionId,
        fitnessGoalId: fitnessGoalId,
        userId: userId,
      );
      await local.replaceAll(remoteItems);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshProgramsIfSafe({
    int? difficultyLevelId,
    int? subscriptionId,
    int? fitnessGoalId,
    int? userId,
  }) async {
    final localPrograms = await getLocalPrograms();
    if (localPrograms.isEmpty) {
      await refreshPrograms(
        difficultyLevelId: difficultyLevelId,
        subscriptionId: subscriptionId,
        fitnessGoalId: fitnessGoalId,
        userId: userId,
      );
      return;
    }
    final hasPending = localPrograms.any(
      (program) =>
          !program.synced || program.pendingDelete || program.isLocalOnly,
    );
    if (hasPending) return;
    await refreshPrograms(
      difficultyLevelId: difficultyLevelId,
      subscriptionId: subscriptionId,
      fitnessGoalId: fitnessGoalId,
      userId: userId,
    );
  }

  Future<ExerciseProgram> createProgram(
    ExerciseProgramPayloadDTO payload, {
    int? id,
    bool triggerSync = true,
  }) async {
    final created = await _createLocalProgram(
      payload,
      id: id,
      triggerSync: triggerSync,
    );
    return created;
  }

  Future<ExerciseProgram> createLocalProgram(
    ExerciseProgramPayloadDTO payload, {
    int? id,
  }) async {
    return _createLocalProgram(payload, id: id, triggerSync: false);
  }

  Future<ExerciseProgram> updateProgram(
    int id,
    ExerciseProgramPayloadDTO payload, {
    bool triggerSync = true,
  }) async {
    final existing = await local.getById(id);
    if (existing == null) {
      return _createLocalProgram(payload, id: id, triggerSync: triggerSync);
    }

    final updatedLocal = ExerciseProgram(
      id: existing.id,
      userId: payload.userId ?? existing.userId,
      name: payload.name,
      description: payload.description,
      synced: false,
      pendingDelete: existing.pendingDelete,
      isLocalOnly: existing.isLocalOnly,
    );
    await _attachProgramLinks(updatedLocal, payload);
    final programExercises = payload.exercises.isEmpty
        ? existing.programExercises.toList()
        : _buildProgramExercises(payload.exercises);
    await local.updateFromProgram(updatedLocal, programExercises);
    if (triggerSync) {
      unawaited(sync());
    }
    return updatedLocal;
  }

  Future<ExerciseProgram> updateLocalProgram(
    int id,
    ExerciseProgramPayloadDTO payload,
  ) async {
    return updateProgram(id, payload, triggerSync: false);
  }

  Future<void> deleteProgram(int id, {bool triggerSync = true}) async {
    final existing = await local.getById(id);
    if (existing == null) return;
    if (existing.isLocalOnly) {
      await local.deleteById(id);
      return;
    }
    final updatedLocal = ExerciseProgram(
      id: existing.id,
      userId: existing.userId,
      name: existing.name,
      description: existing.description,
      synced: false,
      pendingDelete: true,
      isLocalOnly: existing.isLocalOnly,
    );
    updatedLocal.difficultyLevel
      ..clear()
      ..addAll(existing.difficultyLevel);
    updatedLocal.subscription
      ..clear()
      ..addAll(existing.subscription);
    updatedLocal.fitnessGoals.addAll(existing.fitnessGoals);
    updatedLocal.programExercises.addAll(existing.programExercises);
    await local.updateFromProgram(
      updatedLocal,
      existing.programExercises.toList(),
    );
    if (triggerSync) {
      unawaited(sync());
    }
  }

  Future<void> sync() async {
    final pendingDeletes = await local.getPendingDeletes();
    for (final item in pendingDeletes) {
      try {
        await remote.delete(item.id);
      } catch (_) {
        continue;
      }
    }

    final unsynced = await local.getUnsynced();
    for (final item in unsynced) {
      if (item.pendingDelete) continue;
      final payload = _buildPayloadFromProgram(item);
      try {
        final saved = item.isLocalOnly
            ? await remote.create(payload)
            : await remote.update(item.id, payload);
        await local.updateFromProgram(saved, saved.programExercises.toList());
      } catch (_) {
        continue;
      }
    }
  }

  Future<ExerciseProgram> _createLocalProgram(
    ExerciseProgramPayloadDTO payload, {
    int? id,
    bool triggerSync = true,
  }) async {
    final programId = id ?? _generateLocalId();
    final localProgram = ExerciseProgram(
      id: programId,
      userId: payload.userId,
      name: payload.name,
      description: payload.description,
      synced: false,
      pendingDelete: false,
      isLocalOnly: true,
    );
    await _attachProgramLinks(localProgram, payload);
    final programExercises = _buildProgramExercises(payload.exercises);
    await local.create(localProgram, programExercises: programExercises);
    if (triggerSync) {
      unawaited(sync());
    }
    return localProgram;
  }

  ExerciseProgramPayloadDTO _buildPayloadFromProgram(ExerciseProgram item) {
    final exercises = item.programExercises
        .map(
          (pe) => ProgramExerciseDTO(
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
    return ExerciseProgramPayloadDTO(
      id: item.id,
      name: item.name,
      description: item.description,
      difficultyLevelId: item.difficultyLevel.isNotEmpty
          ? item.difficultyLevel.first.id
          : 1,
      subscriptionId: item.subscription.isNotEmpty
          ? item.subscription.first.id
          : null,
      userId: item.userId,
      fitnessGoalIds: item.fitnessGoals.map((g) => g.id).toList(),
      exercises: exercises,
    );
  }

  List<ProgramExercise> _buildProgramExercises(
    List<ProgramExerciseDTO> exercises,
  ) {
    if (exercises.isEmpty) return const [];
    final baseId = _generateLocalId();
    return exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return ProgramExercise(
        id: item.id ?? baseId + index + 1,
        exerciseId: item.exerciseId,
        order: item.order,
        sets: item.sets,
        reps: item.reps,
        duration: item.duration,
        restDuration: item.restDuration,
      );
    }).toList();
  }

  Future<void> _attachProgramLinks(
    ExerciseProgram program,
    ExerciseProgramPayloadDTO payload,
  ) async {
    final difficulty = await local.db.difficultyLevels.get(
      payload.difficultyLevelId,
    );
    program.difficultyLevel..clear();
    if (difficulty != null) {
      program.difficultyLevel.add(difficulty);
    }

    program.subscription..clear();
    if (payload.subscriptionId != null) {
      final subscription = await local.db.subscriptions.get(
        payload.subscriptionId!,
      );
      if (subscription != null) {
        program.subscription.add(subscription);
      }
    }

    final goalIds = payload.fitnessGoalIds;
    if (goalIds.isNotEmpty) {
      final goals = (await local.db.fitnessGoals.getAll(
        goalIds,
      )).whereType<FitnessGoal>().toList();
      program.fitnessGoals
        ..clear()
        ..addAll(goals);
    } else {
      program.fitnessGoals.clear();
    }
  }

  int _generateLocalId() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}
