import 'package:isar_community/isar.dart';

part 'model.g.dart';

@collection
class UserPayment {
  late Id id;
  final int userId;
  final String createdAt;
  final int amount;
  bool synced;
  bool pendingDelete;
  bool isLocalOnly;

  UserPayment({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.amount,
    this.synced = true,
    this.pendingDelete = false,
    this.isLocalOnly = false,
  });
}
