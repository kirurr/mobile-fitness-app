import 'package:mobile_fitness_app/user_subscription/data/local_ds.dart';
import 'package:mobile_fitness_app/user_subscription/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_subscription/dto.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';
import 'dart:async';
import 'package:mobile_fitness_app/subscription/model.dart';

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
      rethrow;
    }
  }

  Future<void> create(
    UserSubscriptionPayloadDTO payload, {
    int? id,
  }) async {
    final created = UserSubscription(
      id: id ?? _generateLocalId(),
      userId: payload.userId,
      startDate: payload.startDate,
      endDate: payload.endDate,
      synced: false,
      pendingDelete: false,
      isLocalOnly: true,
    );
    await _attachSubscription(created, payload.subscriptionId);
    await local.upsert(created);
  }

  Future<void> update(int id, UserSubscriptionPayloadDTO payload) async {
    final existing = await local.getById(id);
    if (existing == null) {
      final created = UserSubscription(
        id: id,
        userId: payload.userId,
        startDate: payload.startDate,
        endDate: payload.endDate,
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      );
      await _attachSubscription(created, payload.subscriptionId);
      await local.upsert(created);
      return;
    }

    final updatedLocal = UserSubscription(
      id: existing.id,
      userId: existing.userId,
      startDate: payload.startDate,
      endDate: payload.endDate,
      synced: false,
      pendingDelete: existing.pendingDelete,
      isLocalOnly: existing.isLocalOnly,
    );
    if (payload.subscriptionId == null) {
      updatedLocal.subscription.value = existing.subscription.value;
    } else {
      await _attachSubscription(updatedLocal, payload.subscriptionId);
    }
    await local.upsert(updatedLocal);
  }

  Future<void> delete(int id) async {
    final existing = await local.getById(id);
    if (existing == null) return;

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

  Future<void> sync() async {
    final pendingDeletes = await local.getPendingDeletes();
    for (final item in pendingDeletes) {
      try {
        await remote.delete(item.id);
      } catch (_) {
        continue;
      }
    }

    final unsynced = await local.getUnsynced();
    for (final item in unsynced) {
      if (item.pendingDelete) continue;
      final payload = UserSubscriptionPayloadDTO(
        id: item.id,
        userId: item.userId,
        subscriptionId: item.subscription.value?.id,
        startDate: item.startDate,
        endDate: item.endDate,
      );
      try {
        if (item.isLocalOnly) {
          await remote.create(payload);
        } else {
          await remote.update(item.id, payload);
        }
      } catch (_) {
        continue;
      }
    }
  }

  int _generateLocalId() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  Future<void> _attachSubscription(
    UserSubscription target,
    int? subscriptionId,
  ) async {
    if (subscriptionId == null) return;
    target.subscription.value = await local.db.subscriptions.get(subscriptionId);
  }
}
