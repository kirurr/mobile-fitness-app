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

  ExerciseProgramRepository({
    required this.local,
    required this.remote,
  });

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
      print('Error refreshing exercise programs: $e');
      rethrow;
    }
  }

  Future<ExerciseProgram> createProgram(
    ExerciseProgramPayloadDTO payload,
  ) async {
    final created = await remote.create(payload);
    final programExercises = created.programExercises.toList();
    await local.create(created, programExercises: programExercises);
    return created;
  }

  Future<ExerciseProgram> createLocalProgram(
    ExerciseProgramPayloadDTO payload, {
    int? id,
  }) async {
    final programId = id ?? _generateLocalId();
    final localProgram = ExerciseProgram(
      id: programId,
      userId: payload.userId,
      name: payload.name,
      description: payload.description,
    );
    await _attachProgramLinks(localProgram, payload);
    final programExercises = _buildProgramExercises(payload.exercises);
    await local.create(localProgram, programExercises: programExercises);
    return localProgram;
  }

  Future<ExerciseProgram> updateProgram(
    int id,
    ExerciseProgramPayloadDTO payload,
  ) async {
    print(
      'ExerciseProgramRepository.updateProgram: '
      'id=$id payloadExercises=${payload.exercises.length}',
    );
    ExerciseProgram updated = await remote.update(id, payload);
    if (updated.programExercises.isEmpty && payload.exercises.isNotEmpty) {
      try {
        final fetched = await remote.getById(id);
        if (fetched != null && fetched.programExercises.isNotEmpty) {
          updated = fetched;
        }
      } catch (e) {
        print('ExerciseProgramRepository.updateProgram: getById failed: $e');
      }
    }
    final programExercises = updated.programExercises.toList();
    await local.updateFromProgram(updated, programExercises);
    return updated;
  }

  Future<ExerciseProgram> updateLocalProgram(
    int id,
    ExerciseProgramPayloadDTO payload,
  ) async {
    final localProgram = ExerciseProgram(
      id: id,
      userId: payload.userId,
      name: payload.name,
      description: payload.description,
    );
    await _attachProgramLinks(localProgram, payload);
    final programExercises =
        payload.exercises.isEmpty
            ? null
            : _buildProgramExercises(payload.exercises);
    await local.updateFromProgram(localProgram, programExercises);
    return localProgram;
  }

  Future<void> deleteProgram(int id) async {
    await remote.delete(id);
    await local.deleteById(id);
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
    program.difficultyLevel.value = difficulty;

    if (payload.subscriptionId == null) {
      program.subscription.value = null;
    } else {
      program.subscription.value = await local.db.subscriptions.get(
        payload.subscriptionId!,
      );
    }

    final goalIds = payload.fitnessGoalIds;
    if (goalIds.isNotEmpty) {
      final goals = (await local.db.fitnessGoals.getAll(goalIds))
          .whereType<FitnessGoal>()
          .toList();
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
