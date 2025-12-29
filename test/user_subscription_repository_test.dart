import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/user_subscription/data/local_ds.dart';
import 'package:mobile_fitness_app/user_subscription/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_subscription/dto.dart';
import 'package:mobile_fitness_app/user_subscription/mapper.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';
import 'package:mobile_fitness_app/user_subscription/repository.dart';
import 'package:test/test.dart';

class _FakeUserSubscriptionRemote extends UserSubscriptionRemoteDataSource {
  final List<UserSubscription> items = [];
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  final List<UserSubscriptionPayloadDTO> createdPayloads = [];
  final List<UserSubscriptionPayloadDTO> updatedPayloads = [];
  final List<int> deletedIds = [];

  _FakeUserSubscriptionRemote(UserSubscriptionMapper mapper)
      : super(ApiClient.instance, mapper);

  @override
  Future<List<UserSubscription>> getAll() async {
    return items;
  }

  @override
  Future<UserSubscription> create(UserSubscriptionPayloadDTO payload) async {
    createCalls += 1;
    createdPayloads.add(payload);
    return UserSubscription(
      id: payload.id ?? 1,
      userId: payload.userId,
      startDate: payload.startDate,
      endDate: payload.endDate,
    );
  }

  @override
  Future<UserSubscription> update(
    int id,
    UserSubscriptionPayloadDTO payload,
  ) async {
    updateCalls += 1;
    updatedPayloads.add(payload);
    return UserSubscription(
      id: id,
      userId: payload.userId,
      startDate: payload.startDate,
      endDate: payload.endDate,
    );
  }

  @override
  Future<void> delete(int id) async {
    deleteCalls += 1;
    deletedIds.add(id);
  }
}

Future<Isar> _openIsar() async {
  final dir = await Directory.systemTemp.createTemp('isar_user_subscription');
  return Isar.open(
    [UserSubscriptionSchema, SubscriptionSchema],
    directory: dir.path,
    inspector: false,
    name: 'user_subscription_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('UserSubscriptionRepository', () {
    late Isar isar;
    late UserSubscriptionRepository repo;
    late _FakeUserSubscriptionRemote remote;
    late Subscription subscription;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
      subscription = Subscription(id: 2, name: 'Pro', monthlyCost: 20);
      await isar.writeTxn(() async {
        await isar.subscriptions.put(subscription);
      });

      final mapper = UserSubscriptionMapper(isar: isar);
      remote = _FakeUserSubscriptionRemote(mapper);
      repo = UserSubscriptionRepository(
        local: UserSubscriptionLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('create stores a local unsynced record with subscription link', () async {
      const payload = UserSubscriptionPayloadDTO(
        userId: 1,
        subscriptionId: 2,
        startDate: '2024-01-01T00:00:00Z',
        endDate: '2024-02-01T00:00:00Z',
      );

      await repo.create(payload, id: 101);

      final items = await repo.getLocalUserSubscriptions();
      expect(items.length, 1);
      expect(items.first.id, 101);
      expect(items.first.synced, isFalse);
      expect(items.first.isLocalOnly, isTrue);
      expect(items.first.subscription.value?.id, subscription.id);
    });

    test('update keeps existing subscription when payload has none', () async {
      await repo.create(
        const UserSubscriptionPayloadDTO(
          userId: 1,
          subscriptionId: 2,
          startDate: '2024-01-01T00:00:00Z',
          endDate: '2024-02-01T00:00:00Z',
        ),
        id: 202,
      );

      await repo.update(
        202,
        const UserSubscriptionPayloadDTO(
          userId: 1,
          subscriptionId: null,
          startDate: '2024-03-01T00:00:00Z',
          endDate: '2024-04-01T00:00:00Z',
        ),
      );

      final updated = await repo.getLocalUserSubscriptions();
      expect(updated.length, 1);
      expect(updated.first.subscription.value?.id, subscription.id);
      expect(updated.first.startDate, '2024-03-01T00:00:00Z');
    });

    test('delete marks record as pending delete', () async {
      await repo.create(
        const UserSubscriptionPayloadDTO(
          userId: 1,
          subscriptionId: 2,
          startDate: '2024-01-01T00:00:00Z',
          endDate: '2024-02-01T00:00:00Z',
        ),
        id: 303,
      );

      await repo.delete(303);

      final pending = await UserSubscriptionLocalDataSource(isar).getPendingDeletes();
      expect(pending.length, 1);
      expect(pending.first.pendingDelete, isTrue);
      expect(pending.first.synced, isFalse);
      expect(pending.first.subscription.value?.id, subscription.id);
    });

    test('sync dispatches deletes and unsynced changes', () async {
      await repo.create(
        const UserSubscriptionPayloadDTO(
          userId: 1,
          subscriptionId: 2,
          startDate: '2024-01-01T00:00:00Z',
          endDate: '2024-02-01T00:00:00Z',
        ),
        id: 401,
      );
      await repo.delete(401);

      await repo.create(
        const UserSubscriptionPayloadDTO(
          userId: 3,
          subscriptionId: 2,
          startDate: '2024-03-01T00:00:00Z',
          endDate: '2024-04-01T00:00:00Z',
        ),
        id: 403,
      );

      final needsUpdate = UserSubscription(
        id: 402,
        userId: 2,
        startDate: '2024-05-01T00:00:00Z',
        endDate: '2024-06-01T00:00:00Z',
        synced: false,
        pendingDelete: false,
        isLocalOnly: false,
      )..subscription.value = subscription;
      await UserSubscriptionLocalDataSource(isar).upsert(needsUpdate);

      await repo.sync();

      expect(remote.createCalls, 1);
      expect(remote.updateCalls, 1);
      expect(remote.deleteCalls, 1);
      expect(remote.deletedIds, contains(401));
    });
  });
}
