import 'package:mobile_fitness_app/user_data/data/local_ds.dart';
import 'package:mobile_fitness_app/user_data/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_data/dto.dart';
import 'package:mobile_fitness_app/user_data/model.dart';

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
      print('Error refreshing user data: $e');
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
}
