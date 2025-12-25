import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/user_payment/data/local_ds.dart';
import 'package:mobile_fitness_app/user_payment/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_payment/dto.dart';
import 'package:mobile_fitness_app/user_payment/model.dart';

class UserPaymentRepository {
  final UserPaymentLocalDataSource local;
  final UserPaymentRemoteDataSource remote;

  UserPaymentRepository({
    required this.local,
    required this.remote,
  });

  Stream<List<UserPayment>> watchUserPayments() {
    return local.watchAll();
  }

  Future<List<UserPayment>> getLocalUserPayments() {
    return local.getAll();
  }

  Future<void> refreshUserPayments() async {
    try {
      final remoteItems = await remote.getAll();
      await local.replaceAll(remoteItems);
    } catch (e) {
      print('Error refreshing user payments: $e');
      rethrow;
    }
  }

  Future<void> create(UserPaymentPayloadDTO payload) async {
    try {
      final created = await remote.create(payload);
      await local.upsert(created);
    } catch (e) {
      final fallback = UserPayment(
        id: Isar.autoIncrement,
        userId: payload.userId,
        createdAt: DateTime.now().toIso8601String(),
        amount: payload.amount,
        synced: false,
        isLocalOnly: true,
      );
      await local.upsert(fallback);
    }
  }

  Future<void> update(int id, UserPaymentPayloadDTO payload) async {
    try {
      final updated = await remote.update(id, payload);
      await local.upsert(updated);
    } catch (e) {
      final existing = await local.getById(id);
      if (existing != null) {
        final updatedLocal = UserPayment(
          id: existing.id,
          userId: existing.userId,
          createdAt: existing.createdAt,
          amount: payload.amount,
          synced: false,
          pendingDelete: existing.pendingDelete,
          isLocalOnly: existing.isLocalOnly,
        );
        await local.upsert(updatedLocal);
      }
    }
  }

  Future<void> delete(int id) async {
    try {
      await remote.delete(id);
      await local.deleteById(id);
    } catch (e) {
      final existing = await local.getById(id);
      if (existing != null) {
        final updatedLocal = UserPayment(
          id: existing.id,
          userId: existing.userId,
          createdAt: existing.createdAt,
          amount: existing.amount,
          synced: false,
          pendingDelete: true,
          isLocalOnly: existing.isLocalOnly,
        );
        await local.upsert(updatedLocal);
      }
    }
  }

  Future<void> sync() async {
    // Sync pending deletes first.
    final pendingDeletes = await local.getPendingDeletes();
    for (final item in pendingDeletes) {
      final payload = UserPaymentPayloadDTO(
        userId: item.userId,
        amount: item.amount,
      );
      try {
        await remote.delete(item.id);
        await local.deleteById(item.id);
      } catch (_) {
        // if delete fails because it doesn't exist remotely, try create then delete
        try {
          final created = await remote.create(payload);
          await remote.delete(created.id);
          await local.deleteById(item.id);
        } catch (_) {
          continue;
        }
      }
    }

    // Sync unsynced creations/updates.
    final unsynced = await local.getUnsynced();
    for (final item in unsynced) {
      if (item.pendingDelete) {
        continue;
      }

      final payload = UserPaymentPayloadDTO(
        userId: item.userId,
        amount: item.amount,
      );

      try {
        if (item.isLocalOnly) {
          final created = await remote.create(payload);
          await local.deleteById(item.id);
          await local.upsert(
            UserPayment(
              id: created.id,
              userId: created.userId,
              createdAt: created.createdAt,
              amount: created.amount,
              synced: true,
              pendingDelete: false,
              isLocalOnly: false,
            ),
          );
        } else {
          final updated = await remote.update(item.id, payload);
          await local.upsert(
            UserPayment(
              id: updated.id,
              userId: updated.userId,
              createdAt: updated.createdAt,
              amount: updated.amount,
              synced: true,
              pendingDelete: false,
              isLocalOnly: false,
            ),
          );
        }
      } catch (_) {
        continue;
      }
    }
  }
}
