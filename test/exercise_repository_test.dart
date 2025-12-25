import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise/data/local_ds.dart';
import 'package:mobile_fitness_app/exercise/data/remote_ds.dart';
import 'package:mobile_fitness_app/exercise/mapper.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise/repository.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';
import 'package:test/test.dart';

class _FakeExerciseRemote extends ExerciseRemoteDataSource {
  final List<Exercise> items;

  _FakeExerciseRemote(this.items, Isar isar)
      : super(ApiClient.instance, ExerciseMapper(isar: isar));

  @override
  Future<List<Exercise>> getAll({
    int? categoryId,
    int? muscleGroupId,
    int? difficultyLevelId,
  }) async =>
      items;
}

Future<Isar> _openIsar() async {
  final dir = await Directory.systemTemp.createTemp('isar_exercise');
  return Isar.open(
    [
      ExerciseSchema,
      ExerciseCategorySchema,
      MuscleGroupSchema,
      DifficultyLevelSchema,
    ],
    directory: dir.path,
    inspector: false,
    name: 'exercise_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('ExerciseRepository', () {
    late Isar isar;
    late ExerciseRepository repo;
    late _FakeExerciseRemote remote;
    late ExerciseCategory category;
    late MuscleGroup group;
    late DifficultyLevel level;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();

      category = ExerciseCategory(
        id: 5,
        name: 'Plyo',
        description: 'Explosive work',
      );
      group = MuscleGroup(id: 6, name: 'Legs');
      level = DifficultyLevel(id: 7, name: 'Intermediate', description: 'Some effort');

      await isar.writeTxn(() async {
        await isar.exerciseCategorys.put(category);
        await isar.muscleGroups.put(group);
        await isar.difficultyLevels.put(level);
      });

      final exercise = Exercise(id: 1, name: 'Jump Squat', type: 'strength')
        ..category.value = category
        ..muscleGroup.value = group
        ..difficultyLevel.value = level;

      remote = _FakeExerciseRemote([exercise], isar);
      repo = ExerciseRepository(
        local: ExerciseLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('refreshExercises replaces local data and keeps links', () async {
      final stale = Exercise(id: 99, name: 'Old', type: 'stretch');
      await isar.writeTxn(() async {
        await isar.exercises.put(stale);
      });

      await repo.refreshExercises();

      final items = await repo.getLocalExercises();
      expect(items.length, 1);
      expect(items.first.id, 1);
      expect(items.first.category.value?.id, category.id);
      expect(items.first.muscleGroup.value?.id, group.id);
      expect(items.first.difficultyLevel.value?.id, level.id);
    });
  });
}
