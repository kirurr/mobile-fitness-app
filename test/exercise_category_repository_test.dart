import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/exercise_category/data/local_ds.dart';
import 'package:mobile_fitness_app/exercise_category/data/remote_ds.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';
import 'package:mobile_fitness_app/exercise_category/repository.dart';
import 'package:test/test.dart';

class _FakeExerciseCategoryRemote extends ExerciseCategoryRemoteDataSource {
  final List<ExerciseCategory> items;

  _FakeExerciseCategoryRemote(this.items) : super(ApiClient.instance);

  @override
  Future<List<ExerciseCategory>> getAll() async => items;
}

Future<Isar> _openIsar() async {
  final dir =
      await Directory.systemTemp.createTemp('isar_exercise_category');
  return Isar.open(
    [ExerciseCategorySchema],
    directory: dir.path,
    inspector: false,
    name: 'exercise_category_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('ExerciseCategoryRepository', () {
    late Isar isar;
    late ExerciseCategoryRepository repo;
    late _FakeExerciseCategoryRemote remote;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
      remote = _FakeExerciseCategoryRemote(
        [
          ExerciseCategory(id: 1, name: 'Cardio', description: 'Heart work'),
          ExerciseCategory(id: 2, name: 'Strength', description: 'Power'),
        ],
      );
      repo = ExerciseCategoryRepository(
        local: ExerciseCategoryLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('refreshCategories replaces local data with remote items', () async {
      await isar.writeTxn(
        () async => isar.exerciseCategorys.put(
          ExerciseCategory(id: 99, name: 'Old', description: 'Stale'),
        ),
      );

      await repo.refreshCategories();

      final categories = await repo.getLocalCategories();
      expect(categories.length, 2);
      expect(categories.map((c) => c.id), containsAll([1, 2]));
      expect(
        categories.map((c) => c.name),
        containsAll(['Cardio', 'Strength']),
      );
    });
  });
}
