import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/subscription/model.dart';

class SubscriptionLocalDataSource {
  late Isar db;

  IsarCollection<Subscription> get _collection => db.subscriptions;

  SubscriptionLocalDataSource(this.db);

  Stream<List<Subscription>> watchAll() {
    return _collection.where().watch(fireImmediately: true);
  }

  Future<List<Subscription>> getAll() {
    return _collection.where().findAll();
  }

  Future<Subscription?> getById(int id) async {
    return await _collection.get(id);
  }

  Future<void> replaceAll(List<Subscription> items) async {
    await db.writeTxn(() async {
      await _collection.clear();
      await _collection.putAll(items);
    });
  }
}
