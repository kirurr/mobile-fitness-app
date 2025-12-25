import 'package:isar_community/isar.dart';

part 'model.g.dart';

@collection
class Subscription {
  late Id id;
  final String name;
  final int monthlyCost;

  Subscription({
    required this.id,
    required this.name,
    required this.monthlyCost,
  });
}
