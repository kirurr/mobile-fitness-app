import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/user_completed_exercise/data/local_ds.dart';
import 'package:mobile_fitness_app/user_completed_exercise/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_completed_exercise/dto.dart';
import 'package:mobile_fitness_app/user_completed_exercise/mapper.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';
import 'package:mobile_fitness_app/user_completed_exercise/repository.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';
import 'package:test/test.dart';

class _FakeUserCompletedExerciseRemote
    extends UserCompletedExerciseRemoteDataSource {
  final List<UserCompletedExercise> created = [];
  final List<UserCompletedExercise> updated = [];
  final List<int> deleted = [];
  int createCalls = 0;
  bool failCreate = false;
  bool failUpdate = false;
  bool failDelete = false;

  _FakeUserCompletedExerciseRemote(UserCompletedExerciseMapper mapper)
    : super(ApiClient.instance, mapper);

  @override
  Future<List<UserCompletedExercise>> getAll(int completedProgramId) async {
    return [
      ...created,
      ...updated,
    ].where((e) => e.completedProgramId == completedProgramId).toList();
  }

  @override
  Future<UserCompletedExercise> create(
    UserCompletedExercisePayloadDTO payload,
  ) async {
    if (failCreate) throw Exception('create failed');
    createCalls += 1;
    final item = UserCompletedExercise(
      id: (created.isNotEmpty ? created.last.id + 1 : 1),
      completedProgramId: payload.completedProgramId,
      programExerciseId: payload.programExerciseId,
      exerciseId: payload.exerciseId,
      sets: payload.sets,
      reps: payload.reps,
      duration: payload.duration,
      weight: payload.weight,
      restDuration: payload.restDuration,
    );
    created.add(item);
    return item;
  }

  @override
  Future<UserCompletedExercise> update(
    int id,
    UserCompletedExercisePayloadDTO payload,
  ) async {
    if (failUpdate) throw Exception('update failed');
    final item = UserCompletedExercise(
      id: id,
      completedProgramId: payload.completedProgramId,
      programExerciseId: payload.programExerciseId,
      exerciseId: payload.exerciseId,
      sets: payload.sets,
      reps: payload.reps,
      duration: payload.duration,
      weight: payload.weight,
      restDuration: payload.restDuration,
    );
    updated.add(item);
    return item;
  }

  @override
  Future<void> delete(int id) async {
    if (failDelete) throw Exception('delete failed');
    deleted.add(id);
  }
}

Future<Isar> _openIsar() async {
  final dir = await Directory.systemTemp.createTemp(
    'isar_user_completed_exercise_test',
  );
  return Isar.open(
    [
      UserCompletedExerciseSchema,
      UserCompletedProgramSchema,
      ExerciseSchema,
      ExerciseCategorySchema,
      MuscleGroupSchema,
      DifficultyLevelSchema,
      ExerciseProgramSchema,
      ProgramExerciseSchema,
      FitnessGoalSchema,
      SubscriptionSchema,
    ],
    directory: dir.path,
    inspector: false,
    name:
        'user_completed_exercise_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('UserCompletedExerciseRepository', () {
    late Isar isar;
    late UserCompletedExerciseRepository repo;
    late _FakeUserCompletedExerciseRemote remote;
    late Exercise exercise;
    late ProgramExercise programExercise;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
      exercise = Exercise(id: 1, name: 'Squat', type: 'strength');
      programExercise = ProgramExercise(
        id: 2,
        exerciseId: exercise.id,
        order: 1,
        sets: 3,
        reps: 10,
        duration: null,
        restDuration: 60,
      );
      await isar.writeTxn(() async {
        await isar.exercises.put(exercise);
        await isar.programExercises.put(programExercise);
      });
      final mapper = UserCompletedExerciseMapper(isar: isar);
      remote = _FakeUserCompletedExerciseRemote(mapper);
      repo = UserCompletedExerciseRepository(
        local: UserCompletedExerciseLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    const payload = UserCompletedExercisePayloadDTO(
      completedProgramId: 1,
      programExerciseId: 2,
      exerciseId: 3,
      sets: 3,
      reps: 10,
      duration: 30,
      weight: 50,
      restDuration: 60,
    );

    test('create stores local unsynced record', () async {
      await repo.create(payload, id: 10, triggerSync: false);

      final items = await repo.getLocalCompletedExercises(1);
      expect(items.length, 1);
      expect(items.first.id, 10);
      expect(items.first.synced, isFalse);
      expect(items.first.isLocalOnly, isTrue);
    });

    test('update preserves existing links when payload omits optional fields', () async {
      final existing = UserCompletedExercise(
        id: 20,
        completedProgramId: 1,
        programExerciseId: programExercise.id,
        exerciseId: exercise.id,
        sets: 3,
        reps: 10,
        duration: 30,
        weight: 50,
        restDuration: 60,
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      )
        ..programExercise.value = programExercise
        ..exercise.value = exercise;
      await UserCompletedExerciseLocalDataSource(isar).upsert(existing);

      await repo.update(
        20,
        const UserCompletedExercisePayloadDTO(
          completedProgramId: 1,
          programExerciseId: null,
          exerciseId: null,
          sets: 4,
          reps: null,
          duration: null,
          weight: null,
          restDuration: null,
        ),
        triggerSync: false,
      );

      final updated = await repo.getLocalCompletedExercises(1);
      expect(updated.length, 1);
      expect(updated.first.programExercise.value?.id, programExercise.id);
      expect(updated.first.exercise.value?.id, exercise.id);
      expect(updated.first.reps, 10);
      expect(updated.first.duration, 30);
      expect(updated.first.weight, 50);
    });

    test('sync skips items when completed program is not synced', () async {
      final program = UserCompletedProgram(
        id: 30,
        userId: 1,
        programId: 1,
        startDate: '2024-01-01T00:00:00Z',
        endDate: null,
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      );
      await isar.writeTxn(() async {
        await isar.userCompletedPrograms.put(program);
      });

      await repo.create(
        const UserCompletedExercisePayloadDTO(
          completedProgramId: 30,
          programExerciseId: 2,
          exerciseId: 1,
          sets: 3,
          reps: 10,
          duration: 30,
          weight: 50,
          restDuration: 60,
        ),
        id: 40,
        triggerSync: false,
      );

      await repo.sync();

      expect(remote.createCalls, 0);
    });
  });
}
