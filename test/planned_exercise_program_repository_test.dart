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
import 'package:mobile_fitness_app/planned_exercise_program/data/local_ds.dart';
import 'package:mobile_fitness_app/planned_exercise_program/data/remote_ds.dart';
import 'package:mobile_fitness_app/planned_exercise_program/dto.dart';
import 'package:mobile_fitness_app/planned_exercise_program/mapper.dart';
import 'package:mobile_fitness_app/planned_exercise_program/model.dart';
import 'package:mobile_fitness_app/planned_exercise_program/repository.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:test/test.dart';

class _FakePlannedExerciseProgramRemote
    extends PlannedExerciseProgramRemoteDataSource {
  final List<PlannedExerciseProgram> items = [];

  _FakePlannedExerciseProgramRemote(PlannedExerciseProgramMapper mapper)
    : super(ApiClient.instance, mapper);

  @override
  Future<List<PlannedExerciseProgram>> getAll() async {
    return items;
  }
}

Future<Isar> _openIsar() async {
  final dir = await Directory.systemTemp.createTemp(
    'isar_planned_exercise_program_test',
  );
  return Isar.open(
    [
      PlannedExerciseProgramSchema,
      PlannedExerciseProgramDateSchema,
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
        'planned_exercise_program_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('PlannedExerciseProgramRepository', () {
    late Isar isar;
    late PlannedExerciseProgramRepository repo;
    late _FakePlannedExerciseProgramRemote remote;
    late ExerciseProgram program;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
      program = ExerciseProgram(
        id: 10,
        userId: 1,
        name: 'Program',
        description: 'Plan',
      );
      await isar.writeTxn(() async {
        await isar.exercisePrograms.put(program);
      });
      final mapper = PlannedExerciseProgramMapper(isar: isar);
      remote = _FakePlannedExerciseProgramRemote(mapper);
      repo = PlannedExerciseProgramRepository(
        local: PlannedExerciseProgramLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    const payload = PlannedExerciseProgramPayloadDTO(
      programId: 1,
      dates: ['2024-01-01T00:00:00Z', '2024-01-02T00:00:00Z'],
    );

    test('create stores local unsynced record with dates', () async {
      await repo.create(payload);

      final items = await repo.getLocalPlannedPrograms();
      expect(items.length, 1);
      expect(items.first.synced, isFalse);
      expect(items.first.isLocalOnly, isTrue);
      expect(items.first.dates.length, payload.dates.length);
    });

    test('update preserves program link and replaces dates', () async {
      final created = PlannedExerciseProgram(
        id: 25,
        programId: program.id,
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      );
      created.program.value = program;
      created.dates.addAll(
        [
          PlannedExerciseProgramDate(
            id: 26,
            plannedExerciseProgramId: 25,
            date: '2024-01-01T00:00:00Z',
          )..plannedProgram.value = created,
        ],
      );
      await PlannedExerciseProgramLocalDataSource(isar).upsert(
        created,
        datesOverride: ['2024-01-01T00:00:00Z'],
      );

      await repo.update(
        25,
        const PlannedExerciseProgramPayloadDTO(
          programId: 10,
          dates: ['2024-02-01T00:00:00Z'],
        ),
      );

      final stored = await repo.getLocalPlannedPrograms();
      expect(stored.length, 1);
      expect(stored.first.program.value?.id, program.id);
      expect(stored.first.dates.length, 1);
      expect(stored.first.dates.first.date, '2024-02-01T00:00:00Z');
    });

    test('refresh preserves local links when remote data is sparse', () async {
      final localItem = PlannedExerciseProgram(
        id: 30,
        programId: program.id,
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      );
      localItem.program.value = program;
      localItem.dates.addAll(
        [
          PlannedExerciseProgramDate(
            id: 31,
            plannedExerciseProgramId: 30,
            date: '2024-03-01T00:00:00Z',
          )..plannedProgram.value = localItem,
        ],
      );
      await PlannedExerciseProgramLocalDataSource(isar).upsert(
        localItem,
        datesOverride: ['2024-03-01T00:00:00Z'],
      );

      remote.items.add(
        PlannedExerciseProgram(id: 30, programId: program.id),
      );

      await repo.refreshPlannedPrograms();

      final stored = await repo.getLocalPlannedPrograms();
      expect(stored.length, 1);
      expect(stored.first.id, 30);
      expect(stored.first.programId, program.id);
    });
  });
}
