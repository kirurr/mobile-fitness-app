import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';

class UserSubscriptionLocalDataSource {
  late Isar db;

  IsarCollection<UserSubscription> get _collection => db.userSubscriptions;

  UserSubscriptionLocalDataSource(this.db);

  Stream<List<UserSubscription>> watchAll() {
    return _collection.where().watch(fireImmediately: true).asyncMap((items) async {
      for (final item in items) {
        await _loadLinks(item);
      }
      return items;
    });
  }

  Future<List<UserSubscription>> getAll() async {
    final items = await _collection.where().findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<UserSubscription?> getById(int id) async {
    final item = await _collection.get(id);
    if (item == null) return null;
    await _loadLinks(item);
    return item;
  }

  Future<List<UserSubscription>> getUnsynced() async {
    final items = await _collection.filter().syncedEqualTo(false).findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<List<UserSubscription>> getPendingDeletes() async {
    final items =
        await _collection.filter().pendingDeleteEqualTo(true).findAll();
    for (final item in items) {
      await _loadLinks(item);
    }
    return items;
  }

  Future<void> upsert(UserSubscription item) async {
    await db.writeTxn(() async {
      await _collection.put(item);
    });
  }

  Future<void> deleteById(int id) async {
    await db.writeTxn(() async {
      await _collection.delete(id);
    });
  }

  Future<void> replaceAll(List<UserSubscription> items) async {
    final subscriptionIds = items
        .map((i) => i.subscription.value?.id)
        .whereType<int>()
        .toSet();

    final subscriptionMap = subscriptionIds.isEmpty
        ? <int, Subscription>{}
        : {
            for (final sub in await db.subscriptions
                .where()
                .anyOf(subscriptionIds, (q, id) => q.idEqualTo(id))
                .findAll())
              sub.id: sub
          };

    for (final item in items) {
      final sub = subscriptionMap[item.subscription.value?.id];
      if (sub != null) {
        item.subscription.value = sub;
      }
    }

    await db.writeTxn(() async {
      await _collection.clear();
      await _collection.putAll(items);
    });
  }

  Future<void> _loadLinks(UserSubscription item) async {
    await item.subscription.load();
  }
}
