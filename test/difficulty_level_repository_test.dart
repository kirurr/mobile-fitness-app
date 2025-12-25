import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/difficulty_level/data/local_ds.dart';
import 'package:mobile_fitness_app/difficulty_level/data/remote_ds.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/difficulty_level/repository.dart';
import 'package:test/test.dart';

class _FakeDifficultyLevelRemote extends DifficultyLevelRemoteDataSource {
  final List<DifficultyLevel> items;

  _FakeDifficultyLevelRemote(this.items) : super(ApiClient.instance);

  @override
  Future<List<DifficultyLevel>> getAll() async => items;
}

Future<Isar> _openIsar() async {
  final dir = await Directory.systemTemp.createTemp('isar_difficulty_level');
  return Isar.open(
    [DifficultyLevelSchema],
    directory: dir.path,
    inspector: false,
    name: 'difficulty_level_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('DifficultyLevelRepository', () {
    late Isar isar;
    late DifficultyLevelRepository repo;
    late _FakeDifficultyLevelRemote remote;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
      remote = _FakeDifficultyLevelRemote(
        [
          DifficultyLevel(id: 1, name: 'Beginner', description: 'Easy'),
          DifficultyLevel(id: 2, name: 'Advanced', description: 'Hard'),
        ],
      );
      repo = DifficultyLevelRepository(
        local: DifficultyLevelLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('refreshLevels replaces local data with remote items', () async {
      await isar.writeTxn(
        () async => isar.difficultyLevels.put(
          DifficultyLevel(id: 99, name: 'Stale', description: 'Old'),
        ),
      );

      await repo.refreshLevels();

      final stored = await repo.getLocalLevels();
      expect(stored.length, 2);
      expect(stored.map((e) => e.id), containsAll([1, 2]));
      expect(stored.map((e) => e.name), containsAll(['Beginner', 'Advanced']));
    });
  });
}
