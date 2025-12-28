import 'package:mobile_fitness_app/user_data/data/local_ds.dart';
import 'package:mobile_fitness_app/user_data/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_data/dto.dart';
import 'package:mobile_fitness_app/user_data/model.dart';
import 'package:mobile_fitness_app/app/dio.dart';

class UserDataRepository {
  final UserDataLocalDataSource local;
  final UserDataRemoteDataSource remote;

  UserDataRepository({required this.local, required this.remote});

  Stream<UserData?> watchUserData() {
    return local.watchCurrent();
  }

  Future<UserData?> getLocalUserData() {
    return local.getCurrent();
  }

  Future<void> refreshUserData() async {
    try {
      final remoteUserData = await remote.getCurrent();
      if (remoteUserData == null) {
        await local.clear();
        return;
      }
      await local.replace(remoteUserData);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserData> createUserData(CreateUserDataDTO payload) async {
    final created = await remote.create(payload);
    await local.save(created);
    return created;
  }

  Future<UserData> updateUserData(UserData payload) async {
    final updated = await remote.update(payload);
    await local.save(updated);
    return updated;
  }

  Future<void> saveLocalUserData(UserData payload) {
    return local.save(payload);
  }

  Future<void> syncLocalUserData() async {
    final localData = await local.getCurrent();
    if (localData == null) return;

    await localData.fitnessGoal.load();
    await localData.trainingLevel.load();
    final fitnessGoalId = localData.fitnessGoal.value?.id;
    final trainingLevelId = localData.trainingLevel.value?.id;
    if (fitnessGoalId == null || trainingLevelId == null) return;

    try {
      final updated = await remote.update(localData);
      await local.save(updated);
    } catch (e) {
      if (e is! ApiError || e.code != 400) rethrow;

      final created = await remote.create(
        CreateUserDataDTO(
          name: localData.name,
          age: localData.age,
          weight: localData.weight,
          height: localData.height,
          fitnessGoalId: fitnessGoalId,
          trainingLevel: trainingLevelId,
        ),
      );
      await local.save(created);
    }
  }
}
