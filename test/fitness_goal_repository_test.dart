import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/fitness_goal/data/local_ds.dart';
import 'package:mobile_fitness_app/fitness_goal/data/remote_ds.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/fitness_goal/repository.dart';
import 'package:test/test.dart';

class _FakeFitnessGoalRemote extends FitnessGoalRemoteDataSource {
  final List<FitnessGoal> items;

  _FakeFitnessGoalRemote(this.items) : super(ApiClient.instance);

  @override
  Future<List<FitnessGoal>> getAll() async => items;
}

Future<Isar> _openIsar() async {
  final dir = await Directory.systemTemp.createTemp('isar_fitness_goal');
  return Isar.open(
    [FitnessGoalSchema],
    directory: dir.path,
    inspector: false,
    name: 'fitness_goal_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('FitnessGoalRepository', () {
    late Isar isar;
    late FitnessGoalRepository repo;
    late _FakeFitnessGoalRemote remote;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
      remote = _FakeFitnessGoalRemote(
        [
          FitnessGoal(id: 1, name: 'Lose Weight'),
          FitnessGoal(id: 2, name: 'Gain Muscle'),
        ],
      );
      repo = FitnessGoalRepository(
        local: FitnessGoalLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('refreshGoals replaces local data with remote items', () async {
      await isar.writeTxn(
        () async => isar.fitnessGoals.put(
          FitnessGoal(id: 99, name: 'Old Goal'),
        ),
      );

      await repo.refreshGoals();

      final goals = await repo.getLocalGoals();
      expect(goals.length, 2);
      expect(goals.map((g) => g.id), containsAll([1, 2]));
      expect(goals.map((g) => g.name), containsAll(['Lose Weight', 'Gain Muscle']));
    });
  });
}
