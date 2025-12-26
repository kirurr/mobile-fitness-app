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
  final List<PlannedExerciseProgram> created = [];
  final List<PlannedExerciseProgram> updated = [];
  final List<int> deleted = [];
  bool failCreate = false;
  bool failUpdate = false;
  bool failDelete = false;

  _FakePlannedExerciseProgramRemote(PlannedExerciseProgramMapper mapper)
    : super(ApiClient.instance, mapper);

  @override
  Future<List<PlannedExerciseProgram>> getAll() async {
    return [...created, ...updated];
  }

  @override
  Future<PlannedExerciseProgram> create(
    PlannedExerciseProgramPayloadDTO payload,
  ) async {
    if (failCreate) throw Exception('create failed');
    final item = PlannedExerciseProgram(
      id: (created.isNotEmpty ? created.last.id + 1 : 1),
      programId: payload.programId,
    );
    item.dates.addAll(
      payload.dates
          .map(
            (d) => PlannedExerciseProgramDate(
              id: Isar.autoIncrement,
              plannedExerciseProgramId: item.id,
              date: d,
            )..plannedProgram.value = item,
          )
          .toList(),
    );
    created.add(item);
    return item;
  }

  @override
  Future<PlannedExerciseProgram> update(
    int id,
    PlannedExerciseProgramPayloadDTO payload,
  ) async {
    if (failUpdate) throw Exception('update failed');
    final item = PlannedExerciseProgram(id: id, programId: payload.programId);
    item.dates.addAll(
      payload.dates
          .map(
            (d) => PlannedExerciseProgramDate(
              id: Isar.autoIncrement,
              plannedExerciseProgramId: id,
              date: d,
            )..plannedProgram.value = item,
          )
          .toList(),
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

    setUp(() async {
      isar = await _openIsar();
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

    test('creates synced record when remote succeeds', () async {
      await repo.create(payload);

      final items = await repo.getLocalPlannedPrograms();
      expect(items.length, 1);
      expect(items.first.synced, isTrue);
      expect(items.first.isLocalOnly, isFalse);
      expect(items.first.dates.length, payload.dates.length);
    });

    test('stores unsynced local record when remote create fails', () async {
      remote.failCreate = true;
      await repo.create(payload);

      final items = await repo.getLocalPlannedPrograms();
      expect(items.length, 1);
      expect(items.first.synced, isFalse);
      expect(items.first.isLocalOnly, isTrue);
      expect(items.first.dates.length, payload.dates.length);
    });

    test('sync processes unsynced creates and deletes', () async {
      remote.failCreate = true;
      await repo.create(payload);

      final offline = (await repo.getLocalPlannedPrograms()).first;
      await repo.delete(offline.id);

      remote
        ..failCreate = false
        ..failDelete = false;

      await repo.sync();

      final remaining = await repo.getLocalPlannedPrograms();
      expect(remaining, isEmpty);
      expect(remote.deleted.isNotEmpty, isTrue);
    });
  });
}
