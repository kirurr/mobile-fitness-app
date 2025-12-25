import 'package:isar_community/isar.dart';

part 'model.g.dart';

@collection
class MuscleGroup {
  late Id id;
  final String name;

  MuscleGroup({
    required this.id,
    required this.name,
  });
}
