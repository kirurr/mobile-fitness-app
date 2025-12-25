import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/subscription/data/local_ds.dart';
import 'package:mobile_fitness_app/subscription/data/remote_ds.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/subscription/repository.dart';
import 'package:test/test.dart';

class _FakeSubscriptionRemote extends SubscriptionRemoteDataSource {
  final List<Subscription> items;

  _FakeSubscriptionRemote(this.items) : super(ApiClient.instance);

  @override
  Future<List<Subscription>> getAll() async => items;
}

Future<Isar> _openIsar() async {
  final dir = await Directory.systemTemp.createTemp('isar_subscription');
  return Isar.open(
    [SubscriptionSchema],
    directory: dir.path,
    inspector: false,
    name: 'subscription_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('SubscriptionRepository', () {
    late Isar isar;
    late SubscriptionRepository repo;
    late _FakeSubscriptionRemote remote;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
      remote = _FakeSubscriptionRemote(
        [
          Subscription(id: 1, name: 'Basic', monthlyCost: 10),
          Subscription(id: 2, name: 'Pro', monthlyCost: 20),
        ],
      );
      repo = SubscriptionRepository(
        local: SubscriptionLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('refreshSubscriptions replaces local data with remote items', () async {
      await isar.writeTxn(
        () async => isar.subscriptions.put(
          Subscription(id: 99, name: 'Old', monthlyCost: 0),
        ),
      );

      await repo.refreshSubscriptions();

      final items = await repo.getLocalSubscriptions();
      expect(items.length, 2);
      expect(items.map((i) => i.id), containsAll([1, 2]));
      expect(items.map((i) => i.name), containsAll(['Basic', 'Pro']));
    });
  });
}
