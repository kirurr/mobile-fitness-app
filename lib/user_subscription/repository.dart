import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/user_subscription/data/local_ds.dart';
import 'package:mobile_fitness_app/user_subscription/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_subscription/dto.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';

class UserSubscriptionRepository {
  final UserSubscriptionLocalDataSource local;
  final UserSubscriptionRemoteDataSource remote;

  UserSubscriptionRepository({
    required this.local,
    required this.remote,
  });

  Stream<List<UserSubscription>> watchUserSubscriptions() {
    return local.watchAll();
  }

  Future<List<UserSubscription>> getLocalUserSubscriptions() {
    return local.getAll();
  }

  Future<void> refreshUserSubscriptions() async {
    try {
      final remoteItems = await remote.getAll();
      await local.replaceAll(remoteItems);
    } catch (e) {
      print('Error refreshing user subscriptions: $e');
      rethrow;
    }
  }

  Future<void> create(UserSubscriptionPayloadDTO payload) async {
    try {
      final created = await remote.create(payload);
      await local.upsert(created);
    } catch (e) {
      final fallback = UserSubscription(
        id: Isar.autoIncrement,
        userId: payload.userId,
        startDate: payload.startDate,
        endDate: payload.endDate,
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      );
      await local.upsert(fallback);
    }
  }

  Future<void> update(int id, UserSubscriptionPayloadDTO payload) async {
    try {
      final updated = await remote.update(id, payload);
      await local.upsert(updated);
    } catch (e) {
      final existing = await local.getById(id);
      if (existing != null) {
        final updatedLocal = UserSubscription(
          id: existing.id,
          userId: existing.userId,
          startDate: payload.startDate,
          endDate: payload.endDate,
          synced: false,
          pendingDelete: existing.pendingDelete,
          isLocalOnly: existing.isLocalOnly,
        );
        updatedLocal.subscription.value = existing.subscription.value;
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
        final updatedLocal = UserSubscription(
          id: existing.id,
          userId: existing.userId,
          startDate: existing.startDate,
          endDate: existing.endDate,
          synced: false,
          pendingDelete: true,
          isLocalOnly: existing.isLocalOnly,
        );
        updatedLocal.subscription.value = existing.subscription.value;
        await local.upsert(updatedLocal);
      }
    }
  }

  Future<void> sync() async {
    final pendingDeletes = await local.getPendingDeletes();
    for (final item in pendingDeletes) {
      final payload = UserSubscriptionPayloadDTO(
        userId: item.userId,
        subscriptionId: item.subscription.value?.id,
        startDate: item.startDate,
        endDate: item.endDate,
      );
      try {
        await remote.delete(item.id);
        await local.deleteById(item.id);
      } catch (_) {
        try {
          final created = await remote.create(payload);
          await remote.delete(created.id);
          await local.deleteById(item.id);
        } catch (_) {
          continue;
        }
      }
    }

    final unsynced = await local.getUnsynced();
    for (final item in unsynced) {
      if (item.pendingDelete) continue;
      final payload = UserSubscriptionPayloadDTO(
        userId: item.userId,
        subscriptionId: item.subscription.value?.id,
        startDate: item.startDate,
        endDate: item.endDate,
      );
      try {
        if (item.isLocalOnly) {
          final created = await remote.create(payload);
          await local.deleteById(item.id);
          created.subscription.value ??= item.subscription.value;
          await local.upsert(created);
        } else {
          final updated = await remote.update(item.id, payload);
          updated.subscription.value ??= item.subscription.value;
          await local.upsert(updated);
        }
      } catch (_) {
        continue;
      }
    }
  }
}
