import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';

part 'model.g.dart';

@collection
class UserData {
  late Id userId;
  final String name;
  final int age;
  final int weight;
  final int height;
  bool synced;
  bool isLocalOnly;

  final fitnessGoal = IsarLink<FitnessGoal>();
  final trainingLevel = IsarLink<DifficultyLevel>();

  UserData({
    required this.userId,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    this.synced = true,
    this.isLocalOnly = false,
  });
}
