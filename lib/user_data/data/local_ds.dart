import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/user_data/model.dart';

class UserDataLocalDataSource {
  late Isar db;

  IsarCollection<UserData> get _collection => db.userDatas;

  UserDataLocalDataSource(this.db);

  Stream<UserData?> watchCurrent() {
    return _collection.where().limit(1).watch(fireImmediately: true).asyncMap((
      items,
    ) async {
      if (items.isEmpty) return null;

      final user = items.first;

      await user.fitnessGoal.load();
      await user.trainingLevel.load();

      return user;
    });
  }

  Future<UserData?> getCurrent() async {
    final items = await _collection.where().limit(1).findAll();
    if (items.isEmpty) {
      return null;
    }

    final data = items.first;
    await data.fitnessGoal.load();
    await data.trainingLevel.load();

    return data;
  }

  Future<void> save(UserData data) async {
    await db.writeTxn(() async {
      await _collection.put(data);
      await data.fitnessGoal.save();
      await data.trainingLevel.save();
    });
  }

  Future<void> replace(UserData data) async {
    await save(data);
  }

  Future<void> clear() async {
    await db.writeTxn(() async {
      await _collection.clear();
    });
  }
}
