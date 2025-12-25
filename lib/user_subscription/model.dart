import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/subscription/model.dart';

part 'model.g.dart';

@collection
class UserSubscription {
  late Id id;
  final int userId;
  final String startDate;
  final String endDate;
  bool synced;
  bool pendingDelete;
  bool isLocalOnly;

  final subscription = IsarLink<Subscription>();

  UserSubscription({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    this.synced = true,
    this.pendingDelete = false,
    this.isLocalOnly = false,
  });
}
