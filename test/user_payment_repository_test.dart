import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_payment/data/local_ds.dart';
import 'package:mobile_fitness_app/user_payment/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_payment/dto.dart';
import 'package:mobile_fitness_app/user_payment/model.dart';
import 'package:mobile_fitness_app/user_payment/repository.dart';
import 'package:test/test.dart';

class _FakeUserPaymentRemote extends UserPaymentRemoteDataSource {
  final List<UserPayment> created = [];
  final List<UserPayment> updated = [];
  final List<int> deleted = [];
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  bool failCreate = false;
  bool failUpdate = false;
  bool failDelete = false;

  _FakeUserPaymentRemote() : super(ApiClient.instance);

  @override
  Future<List<UserPayment>> getAll() async => [...created, ...updated];

  @override
  Future<UserPayment> create(UserPaymentPayloadDTO payload) async {
    if (failCreate) throw Exception('create failed');
    createCalls += 1;
    final item = UserPayment(
      id: payload.id ?? (created.isNotEmpty ? created.last.id + 1 : 1),
      userId: payload.userId,
      createdAt: DateTime.now().toIso8601String(),
      amount: payload.amount,
      synced: true,
      isLocalOnly: false,
    );
    created.add(item);
    return item;
  }

  @override
  Future<UserPayment> update(int id, UserPaymentPayloadDTO payload) async {
    if (failUpdate) throw Exception('update failed');
    updateCalls += 1;
    final item = UserPayment(
      id: id,
      userId: payload.userId,
      createdAt: DateTime.now().toIso8601String(),
      amount: payload.amount,
      synced: true,
      isLocalOnly: false,
    );
    updated.add(item);
    return item;
  }

  @override
  Future<void> delete(int id) async {
    if (failDelete) throw Exception('delete failed');
    deleteCalls += 1;
    deleted.add(id);
  }
}

Future<Isar> _openIsar() async {
  final dir =
      await Directory.systemTemp.createTemp('isar_user_payment_test');
  return Isar.open(
    [UserPaymentSchema],
    directory: dir.path,
    inspector: false,
    name: 'user_payment_test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

void main() {
  group('UserPaymentRepository', () {
    late Isar isar;
    late UserPaymentRepository repo;
    late _FakeUserPaymentRemote remote;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await _openIsar();
      remote = _FakeUserPaymentRemote();
      repo = UserPaymentRepository(
        local: UserPaymentLocalDataSource(isar),
        remote: remote,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('create stores a local unsynced record', () async {
      await repo.create(
        const UserPaymentPayloadDTO(userId: 1, amount: 100),
        id: 10,
      );

      final items = await repo.getLocalUserPayments();
      expect(items.length, 1);
      expect(items.first.id, 10);
      expect(items.first.synced, isFalse);
      expect(items.first.isLocalOnly, isTrue);
      expect(items.first.createdAt.isNotEmpty, isTrue);
    });

    test('update creates a new record when missing', () async {
      await repo.update(
        20,
        const UserPaymentPayloadDTO(userId: 1, amount: 150),
      );

      final items = await repo.getLocalUserPayments();
      expect(items.length, 1);
      expect(items.first.id, 20);
      expect(items.first.synced, isFalse);
      expect(items.first.isLocalOnly, isTrue);
    });

    test('delete flags pending delete when remote fails', () async {
      await repo.create(
        const UserPaymentPayloadDTO(userId: 1, amount: 100),
        id: 30,
      );
      remote.failDelete = true;
      await repo.delete(30);

      final pending = await UserPaymentLocalDataSource(isar).getPendingDeletes();
      expect(pending.length, 1);
      expect(pending.first.pendingDelete, isTrue);
      expect(pending.first.synced, isFalse);
    });

    test('sync processes deletes and unsynced changes', () async {
      final pendingDelete = UserPayment(
        id: 40,
        userId: 1,
        createdAt: '2024-01-01T00:00:00Z',
        amount: 100,
        synced: false,
        pendingDelete: true,
        isLocalOnly: false,
      );
      final localCreate = UserPayment(
        id: 41,
        userId: 1,
        createdAt: '2024-01-02T00:00:00Z',
        amount: 200,
        synced: false,
        pendingDelete: false,
        isLocalOnly: true,
      );
      final localUpdate = UserPayment(
        id: 42,
        userId: 2,
        createdAt: '2024-01-03T00:00:00Z',
        amount: 300,
        synced: false,
        pendingDelete: false,
        isLocalOnly: false,
      );
      final local = UserPaymentLocalDataSource(isar);
      await local.upsert(pendingDelete);
      await local.upsert(localCreate);
      await local.upsert(localUpdate);

      await repo.sync();

      final remaining = await repo.getLocalUserPayments();
      expect(remaining.any((p) => p.id == 40), isFalse);
      expect(remaining.any((p) => p.id == 41), isTrue);
      expect(remaining.any((p) => p.id == 42), isTrue);
      expect(remote.createCalls, 1);
      expect(remote.updateCalls, 1);
      expect(remote.deleteCalls, 1);
      expect(remote.deleted, contains(40));
      final syncedItems =
          remaining.where((item) => item.id == 41 || item.id == 42).toList();
      expect(syncedItems.every((item) => item.synced), isTrue);
    });
  });
}
