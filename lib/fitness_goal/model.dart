import 'package:isar_community/isar.dart';

part 'model.g.dart';

@collection
class FitnessGoal {
  late Id id;
  final String name;

  FitnessGoal({
    required this.id,
    required this.name,
  });
}
