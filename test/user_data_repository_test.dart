import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/user_data/data/local_ds.dart';
import 'package:mobile_fitness_app/user_data/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_data/dto.dart';
import 'package:mobile_fitness_app/user_data/mapper.dart';
import 'package:mobile_fitness_app/user_data/model.dart';
import 'package:mobile_fitness_app/user_data/repository.dart';
import 'package:test/test.dart';

class _FakeUserDataRemote extends UserDataRemoteDataSource {
  UserData? current;
  UserData? created;
  UserData? updated;
  int createCalls = 0;
  int updateCalls = 0;
  bool throwUpdateBadRequest = false;

  _FakeUserDataRemote(Isar isar)
      : super(ApiClient.instance, UserDataMapper(isar: isar));

  @override
  Future<UserData?> getCurrent() async => current;

  @override
  Future<UserData> create(CreateUserDataDTO payload) async {
    createCalls += 1;
    return created!;
  }

  @override
  Future<UserData> update(UserData payload) async {
    updateCalls += 1;
    if (throwUpdateBadRequest) {
      throw ApiError(message: 'bad request', code: 400);
    }
    return updated ?? payload;
  }
}

UserData _buildUserData({
  required int id,
  required FitnessGoal goal,
  required DifficultyLevel level,
  String name = 'User',
}) {
  final user = UserData(
    userId: id,
    name: name,
    age: 25,
    weight: 170,
    height: 180,
  );
  user.fitnessGoal.value = goal;
  user.trainingLevel.value = level;
  return user;
}

Future<Isar> _openIsar() async {
  final dir = await Directory.systemTemp.createTemp('isar_user_data');
  return Isar.open(
    [
      UserDataSchema,
      FitnessGoalSchema,
      DifficultyLevelSchema,
    ],
    directory: dir.path,
    inspector: false,
    name: 'user_data_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('UserDataRepository', () {
    late Isar isar;
    late UserDataRepository repo;
    late _FakeUserDataRemote remote;
    late FitnessGoal goal;
    late DifficultyLevel level;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
      goal = FitnessGoal(id: 1, name: 'Strength');
      level = DifficultyLevel(id: 2, name: 'Intermediate', description: 'Medium');
      await isar.writeTxn(() async {
        await isar.fitnessGoals.put(goal);
        await isar.difficultyLevels.put(level);
      });

      remote = _FakeUserDataRemote(isar);
      repo = UserDataRepository(
        local: UserDataLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('refreshUserData stores remote data locally', () async {
      remote.current = _buildUserData(id: 10, goal: goal, level: level);

      await repo.refreshUserData();

      final stored = await repo.getLocalUserData();
      expect(stored?.userId, 10);
      expect(stored?.fitnessGoal.value?.id, goal.id);
      expect(stored?.trainingLevel.value?.id, level.id);
    });

    test('refreshUserData clears local data when remote returns null', () async {
      final localUser = _buildUserData(id: 20, goal: goal, level: level);
      await UserDataLocalDataSource(isar).save(localUser);
      remote.current = null;

      await repo.refreshUserData();

      final stored = await repo.getLocalUserData();
      expect(stored, isNull);
    });

    test('createUserData saves returned data locally', () async {
      remote.created = _buildUserData(
        id: 30,
        goal: goal,
        level: level,
        name: 'Created',
      );

      await repo.createUserData(
        const CreateUserDataDTO(
          name: 'Created',
          age: 26,
          weight: 165,
          height: 175,
          fitnessGoalId: 1,
          trainingLevel: 2,
        ),
      );

      final stored = await repo.getLocalUserData();
      expect(stored?.userId, 30);
      expect(stored?.name, 'Created');
    });

    test('saveLocalUserData marks record as unsynced local-only', () async {
      final payload = _buildUserData(id: 40, goal: goal, level: level);

      await repo.saveLocalUserData(payload);

      final stored = await repo.getLocalUserData();
      expect(stored?.synced, isFalse);
      expect(stored?.isLocalOnly, isTrue);
    });

    test('syncLocalUserData creates after update 400 error', () async {
      final localUser = _buildUserData(id: 50, goal: goal, level: level);
      await repo.saveLocalUserData(localUser);

      remote.throwUpdateBadRequest = true;
      remote.created = _buildUserData(id: 51, goal: goal, level: level);

      await repo.syncLocalUserData();

      expect(remote.updateCalls, 1);
      expect(remote.createCalls, 1);
      final stored = await isar.userDatas.get(51);
      expect(stored?.userId, 51);
    });
  });
}
