import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_subscription/data/local_ds.dart';
import 'package:mobile_fitness_app/user_subscription/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_subscription/dto.dart';
import 'package:mobile_fitness_app/user_subscription/mapper.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';
import 'package:mobile_fitness_app/user_subscription/repository.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:test/test.dart';

class _FakeUserSubscriptionRemote extends UserSubscriptionRemoteDataSource {
  final List<UserSubscription> created = [];
  final List<UserSubscription> updated = [];
  final List<int> deleted = [];
  bool failCreate = false;
  bool failUpdate = false;
  bool failDelete = false;

  _FakeUserSubscriptionRemote(UserSubscriptionMapper mapper)
      : super(ApiClient.instance, mapper);

  @override
  Future<List<UserSubscription>> getAll() async {
    return [...created, ...updated];
  }

  @override
  Future<UserSubscription> create(UserSubscriptionPayloadDTO payload) async {
    if (failCreate) throw Exception('create failed');
    final item = UserSubscription(
      id: (created.isNotEmpty ? created.last.id + 1 : 1),
      userId: payload.userId,
      startDate: payload.startDate,
      endDate: payload.endDate,
    );
    created.add(item);
    return item;
  }

  @override
  Future<UserSubscription> update(
    int id,
    UserSubscriptionPayloadDTO payload,
  ) async {
    if (failUpdate) throw Exception('update failed');
    final item = UserSubscription(
      id: id,
      userId: payload.userId,
      startDate: payload.startDate,
      endDate: payload.endDate,
    );
    updated.add(item);
    return item;
  }

  @override
  Future<void> delete(int id) async {
    if (failDelete) throw Exception('delete failed');
    deleted.add(id);
  }
}

Future<Isar> _openIsar() async {
  final dir = await Directory.systemTemp.createTemp('isar_test');
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

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
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

    test('creates synced record when remote succeeds', () async {
      await repo.create(
        const UserSubscriptionPayloadDTO(
          userId: 1,
          subscriptionId: 2,
          startDate: '2024-01-01T00:00:00Z',
          endDate: '2024-02-01T00:00:00Z',
        ),
      );

      final items = await repo.getLocalUserSubscriptions();
      expect(items.length, 1);
      expect(items.first.synced, isTrue);
      expect(items.first.isLocalOnly, isFalse);
    });

    test('stores unsynced local record when remote create fails', () async {
      remote.failCreate = true;
      await repo.create(
        const UserSubscriptionPayloadDTO(
          userId: 1,
          subscriptionId: 2,
          startDate: '2024-01-01T00:00:00Z',
          endDate: '2024-02-01T00:00:00Z',
        ),
      );

      final items = await repo.getLocalUserSubscriptions();
      expect(items.length, 1);
      expect(items.first.synced, isFalse);
      expect(items.first.isLocalOnly, isTrue);
    });

    test('sync processes unsynced creates and deletes', () async {
      remote.failCreate = true;
      await repo.create(
        const UserSubscriptionPayloadDTO(
          userId: 1,
          subscriptionId: 2,
          startDate: '2024-01-01T00:00:00Z',
          endDate: '2024-02-01T00:00:00Z',
        ),
      );

      final offline = (await repo.getLocalUserSubscriptions()).first;
      await repo.delete(offline.id);

      remote
        ..failCreate = false
        ..failDelete = false;

      await repo.sync();

      final remaining = await repo.getLocalUserSubscriptions();
      expect(remaining, isEmpty);
      expect(remote.deleted.isNotEmpty, isTrue);
    });
  });
}
