import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/subscription/model.dart';

part 'model.g.dart';

@collection
class ExerciseProgram {
  late Id id;
  final int? userId;
  final String name;
  final String description;
  bool synced;
  bool pendingDelete;
  bool isLocalOnly;
  bool isUserAdded;

  final programExercises = IsarLinks<ProgramExercise>();
  final difficultyLevel = IsarLinks<DifficultyLevel>();
  final subscription = IsarLinks<Subscription>();
  final fitnessGoals = IsarLinks<FitnessGoal>();

  ExerciseProgram({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    this.synced = true,
    this.pendingDelete = false,
    this.isLocalOnly = false,
    this.isUserAdded = false,
  });
}

@collection
class ProgramExercise {
  late Id id;
  final int exerciseId;
  final int? order;
  final int sets;
  final int? reps;
  final int? duration;
  final int restDuration;

  final program = IsarLink<ExerciseProgram>();
  final exercise = IsarLink<Exercise>();

  ProgramExercise({
    required this.id,
    required this.exerciseId,
    required this.order,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.restDuration,
  });
}
