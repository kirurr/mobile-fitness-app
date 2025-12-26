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
import 'package:test/test.dart';

class _FakeUserCompletedExerciseRemote
    extends UserCompletedExerciseRemoteDataSource {
  final List<UserCompletedExercise> created = [];
  final List<UserCompletedExercise> updated = [];
  final List<int> deleted = [];
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

    setUp(() async {
      isar = await _openIsar();
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

    test('creates and stores synced record when remote succeeds', () async {
      await repo.create(payload);

      final items = await repo.getLocalCompletedExercises(1);
      expect(items.length, 1);
      expect(items.first.synced, isTrue);
      expect(items.first.isLocalOnly, isFalse);
    });

    test('stores unsynced local record when remote create fails', () async {
      remote.failCreate = true;
      await repo.create(payload);

      final items = await repo.getLocalCompletedExercises(1);
      expect(items.length, 1);
      expect(items.first.synced, isFalse);
      expect(items.first.isLocalOnly, isTrue);
    });

    test('sync pushes unsynced creates and deletes', () async {
      remote.failCreate = true;
      await repo.create(payload);

      final offline = (await repo.getLocalCompletedExercises(1)).first;
      await repo.delete(offline.id);

      remote
        ..failCreate = false
        ..failDelete = false;

      await repo.sync();

      final remaining = await repo.getLocalCompletedExercises(1);
      expect(remaining, isEmpty);
      expect(remote.deleted.isNotEmpty, isTrue);
    });
  });
}
