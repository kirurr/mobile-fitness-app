import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/muscle_group/data/local_ds.dart';
import 'package:mobile_fitness_app/muscle_group/data/remote_ds.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';
import 'package:mobile_fitness_app/muscle_group/repository.dart';
import 'package:test/test.dart';

class _FakeMuscleGroupRemote extends MuscleGroupRemoteDataSource {
  final List<MuscleGroup> items;

  _FakeMuscleGroupRemote(this.items) : super(ApiClient.instance);

  @override
  Future<List<MuscleGroup>> getAll() async => items;
}

Future<Isar> _openIsar() async {
  final dir = await Directory.systemTemp.createTemp('isar_muscle_group');
  return Isar.open(
    [MuscleGroupSchema],
    directory: dir.path,
    inspector: false,
    name: 'muscle_group_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('MuscleGroupRepository', () {
    late Isar isar;
    late MuscleGroupRepository repo;
    late _FakeMuscleGroupRemote remote;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
      remote = _FakeMuscleGroupRemote(
        [
          MuscleGroup(id: 1, name: 'Chest'),
          MuscleGroup(id: 2, name: 'Back'),
        ],
      );
      repo = MuscleGroupRepository(
        local: MuscleGroupLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('refreshGroups replaces local data with remote items', () async {
      await isar.writeTxn(
        () async => isar.muscleGroups.put(
          MuscleGroup(id: 99, name: 'Stale'),
        ),
      );

      await repo.refreshGroups();

      final groups = await repo.getLocalGroups();
      expect(groups.length, 2);
      expect(groups.map((g) => g.id), containsAll([1, 2]));
      expect(groups.map((g) => g.name), containsAll(['Chest', 'Back']));
    });
  });
}
