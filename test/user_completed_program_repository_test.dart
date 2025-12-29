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
  final List<UserCompletedProgram> items = [];
  int deleteCalls = 0;

  _FakeUserCompletedProgramRemote(UserCompletedProgramMapper mapper)
    : super(ApiClient.instance, mapper);

  @override
  Future<List<UserCompletedProgram>> getAll() async {
    return items;
  }

  @override
  Future<void> delete(int id) async {
    deleteCalls += 1;
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
    late ExerciseProgram program;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
      program = ExerciseProgram(
        id: 5,
        userId: 1,
        name: 'Program',
        description: 'Plan',
      );
      await isar.writeTxn(() async {
        await isar.exercisePrograms.put(program);
      });
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

    test('create stores local unsynced record and normalizes start date', () async {
      await repo.create(
        const UserCompletedProgramPayloadDTO(
          userId: 1,
          programId: 2,
          startDate: '',
          endDate: '2024-01-02T00:00:00Z',
        ),
        id: 11,
        triggerSync: false,
      );

      final items = await repo.getLocalCompletedPrograms();
      expect(items.length, 1);
      expect(items.first.id, 11);
      expect(items.first.synced, isFalse);
      expect(items.first.isLocalOnly, isTrue);
      expect(items.first.startDate.isNotEmpty, isTrue);
    });

    test('update keeps fallback dates when payload is empty', () async {
      final localItem = UserCompletedProgram(
        id: 20,
        userId: 1,
        programId: 5,
        startDate: '2024-01-01T00:00:00Z',
        endDate: '2024-01-02T00:00:00Z',
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      );
      localItem.program.value = program;
      await UserCompletedProgramLocalDataSource(isar).upsert(localItem);

      await repo.update(
        20,
        const UserCompletedProgramPayloadDTO(
          userId: 1,
          programId: 5,
          startDate: '',
          endDate: '',
        ),
        triggerSync: false,
      );

      final updated = await repo.getLocalCompletedPrograms();
      expect(updated.length, 1);
      expect(updated.first.startDate, '2024-01-01T00:00:00Z');
      expect(updated.first.endDate, '2024-01-02T00:00:00Z');
      expect(updated.first.program.value?.id, program.id);
    });

    test('refresh keeps local links when remote has none', () async {
      final completedExercise = UserCompletedExercise(
        id: 50,
        completedProgramId: 30,
        programExerciseId: null,
        exerciseId: null,
        sets: 3,
        reps: 10,
        duration: null,
        weight: null,
        restDuration: null,
      );
      final localItem = UserCompletedProgram(
        id: 30,
        userId: 1,
        programId: 5,
        startDate: '2024-02-01T00:00:00Z',
        endDate: null,
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      );
      localItem.program.value = program;
      localItem.completedExercises.add(completedExercise);

      await isar.writeTxn(() async {
        await isar.userCompletedExercises.put(completedExercise);
        await isar.userCompletedPrograms.put(localItem);
        await localItem.program.save();
        await localItem.completedExercises.save();
      });

      remote.items.add(
        UserCompletedProgram(
          id: 30,
          userId: 1,
          programId: 5,
          startDate: '2024-02-01T00:00:00Z',
          endDate: null,
        ),
      );

      await repo.refreshCompletedPrograms();

      final stored = await repo.getLocalCompletedPrograms();
      expect(stored.length, 1);
      expect(stored.first.id, 30);
      expect(stored.first.programId, program.id);
    });
  });
}
