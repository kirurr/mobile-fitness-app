import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/user_payment/model.dart';

class UserPaymentLocalDataSource {
  late Isar db;

  IsarCollection<UserPayment> get _collection => db.userPayments;

  UserPaymentLocalDataSource(this.db);

  Stream<List<UserPayment>> watchAll() {
    return _collection
        .filter()
        .pendingDeleteEqualTo(false)
        .watch(fireImmediately: true);
  }

  Future<List<UserPayment>> getAll() {
    return _collection.filter().pendingDeleteEqualTo(false).findAll();
  }

  Future<UserPayment?> getById(int id) async {
    return await _collection.get(id);
  }

  Future<List<UserPayment>> getUnsynced() {
    return _collection.filter().syncedEqualTo(false).findAll();
  }

  Future<List<UserPayment>> getPendingDeletes() {
    return _collection.filter().pendingDeleteEqualTo(true).findAll();
  }

  Future<void> upsert(UserPayment item) async {
    await db.writeTxn(() async {
      await _collection.put(item);
    });
  }

  Future<void> deleteById(int id) async {
    await db.writeTxn(() async {
      await _collection.delete(id);
    });
  }

  Future<void> replaceAll(List<UserPayment> items) async {
    await db.writeTxn(() async {
      await _collection.clear();
      await _collection.putAll(items);
    });
  }
}
