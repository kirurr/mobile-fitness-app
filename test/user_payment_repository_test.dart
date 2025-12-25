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
  bool failCreate = false;
  bool failUpdate = false;
  bool failDelete = false;

  _FakeUserPaymentRemote() : super(ApiClient.instance);

  @override
  Future<List<UserPayment>> getAll() async => [...created, ...updated];

  @override
  Future<UserPayment> create(UserPaymentPayloadDTO payload) async {
    if (failCreate) throw Exception('create failed');
    final item = UserPayment(
      id: (created.isNotEmpty ? created.last.id + 1 : 1),
      userId: payload.userId,
      createdAt: DateTime.now().toIso8601String(),
      amount: payload.amount,
    );
    created.add(item);
    return item;
  }

  @override
  Future<UserPayment> update(int id, UserPaymentPayloadDTO payload) async {
    if (failUpdate) throw Exception('update failed');
    final item = UserPayment(
      id: id,
      userId: payload.userId,
      createdAt: DateTime.now().toIso8601String(),
      amount: payload.amount,
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

    test('creates and stores synced record when remote succeeds', () async {
      await repo.create(const UserPaymentPayloadDTO(userId: 1, amount: 100));

      final items = await repo.getLocalUserPayments();
      expect(items.length, 1);
      expect(items.first.synced, isTrue);
      expect(items.first.isLocalOnly, isFalse);
    });

    test('stores unsynced local record when remote create fails', () async {
      remote.failCreate = true;
      await repo.create(const UserPaymentPayloadDTO(userId: 1, amount: 100));

      final items = await repo.getLocalUserPayments();
      expect(items.length, 1);
      expect(items.first.synced, isFalse);
      expect(items.first.isLocalOnly, isTrue);
    });

    test('sync pushes unsynced creates and deletes', () async {
      remote.failCreate = true;
      await repo.create(const UserPaymentPayloadDTO(userId: 1, amount: 100));
      final offline = (await repo.getLocalUserPayments()).first;

      await repo.delete(offline.id);

      remote
        ..failCreate = false
        ..failDelete = false;

      await repo.sync();

      final remaining = await repo.getLocalUserPayments();
      expect(remaining, isEmpty);
      expect(remote.deleted.isNotEmpty, isTrue);
    });
  });
}
