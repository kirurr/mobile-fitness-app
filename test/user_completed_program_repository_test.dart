import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart'
    as program_exercise;
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/user_completed_exercise/mapper.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';
import 'package:mobile_fitness_app/user_completed_program/data/local_ds.dart';
import 'package:mobile_fitness_app/user_completed_program/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_completed_program/dto.dart';
import 'package:mobile_fitness_app/user_completed_program/mapper.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';
import 'package:mobile_fitness_app/user_completed_program/repository.dart';
import 'package:test/test.dart';

class _FakeUserCompletedProgramRemote
    extends UserCompletedProgramRemoteDataSource {
  final List<UserCompletedProgram> created = [];
  final List<UserCompletedProgram> updated = [];
  final List<int> deleted = [];
  bool failCreate = false;
  bool failUpdate = false;
  bool failDelete = false;

  _FakeUserCompletedProgramRemote(UserCompletedProgramMapper mapper)
    : super(ApiClient.instance, mapper);

  @override
  Future<List<UserCompletedProgram>> getAll() async {
    return [...created, ...updated];
  }

  @override
  Future<UserCompletedProgram> create(
    UserCompletedProgramPayloadDTO payload,
  ) async {
    if (failCreate) throw Exception('create failed');
    final item = UserCompletedProgram(
      id: (created.isNotEmpty ? created.last.id + 1 : 1),
      userId: payload.userId,
      programId: payload.programId,
      startDate: payload.startDate ?? DateTime.now().toIso8601String(),
      endDate: payload.endDate,
    );
    created.add(item);
    return item;
  }

  @override
  Future<UserCompletedProgram> update(
    int id,
    UserCompletedProgramPayloadDTO payload,
  ) async {
    if (failUpdate) throw Exception('update failed');
    final item = UserCompletedProgram(
      id: id,
      userId: payload.userId,
      programId: payload.programId,
      startDate: payload.startDate ?? DateTime.now().toIso8601String(),
      endDate: payload.endDate,
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
    'isar_user_completed_program_test',
  );
  return Isar.open(
    [
      UserCompletedProgramSchema,
      UserCompletedExerciseSchema,
      ExerciseProgramSchema,
      program_exercise.ProgramExerciseSchema,
      ExerciseSchema,
      ExerciseCategorySchema,
      MuscleGroupSchema,
      DifficultyLevelSchema,
      FitnessGoalSchema,
      SubscriptionSchema,
    ],
    directory: dir.path,
    inspector: false,
    name:
        'user_completed_program_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('UserCompletedProgramRepository', () {
    late Isar isar;
    late UserCompletedProgramRepository repo;
    late _FakeUserCompletedProgramRemote remote;

    setUp(() async {
      isar = await _openIsar();
      final completedExerciseMapper = UserCompletedExerciseMapper(isar: isar);
      final mapper = UserCompletedProgramMapper(
        isar: isar,
        completedExerciseMapper: completedExerciseMapper,
      );
      remote = _FakeUserCompletedProgramRemote(mapper);
      repo = UserCompletedProgramRepository(
        local: UserCompletedProgramLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    const payload = UserCompletedProgramPayloadDTO(
      userId: 1,
      programId: 2,
      startDate: '2024-01-01T00:00:00Z',
      endDate: '2024-01-02T00:00:00Z',
    );

    test('creates synced record when remote succeeds', () async {
      await repo.create(payload);

      final items = await repo.getLocalCompletedPrograms();
      expect(items.length, 1);
      expect(items.first.synced, isTrue);
      expect(items.first.isLocalOnly, isFalse);
    });

    test('stores unsynced local record when remote create fails', () async {
      remote.failCreate = true;
      await repo.create(payload);

      final items = await repo.getLocalCompletedPrograms();
      expect(items.length, 1);
      expect(items.first.synced, isFalse);
      expect(items.first.isLocalOnly, isTrue);
    });

    test('sync processes unsynced creates and deletes', () async {
      remote.failCreate = true;
      await repo.create(payload);

      final offline = (await repo.getLocalCompletedPrograms()).first;
      await repo.delete(offline.id);

      remote
        ..failCreate = false
        ..failDelete = false;

      await repo.sync();

      final remaining = await repo.getLocalCompletedPrograms();
      expect(remaining, isEmpty);
      expect(remote.deleted.isNotEmpty, isTrue);
    });
  });
}
