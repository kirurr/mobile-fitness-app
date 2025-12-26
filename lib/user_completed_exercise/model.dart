import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';

part 'model.g.dart';

@collection
class UserCompletedExercise {
  late Id id;
  final int completedProgramId;
  final int? programExerciseId;
  final int? exerciseId;
  final int sets;
  final int? reps;
  final int? duration;
  final int? weight;
  final int? restDuration;
  bool synced;
  bool pendingDelete;
  bool isLocalOnly;

  final programExercise = IsarLink<ProgramExercise>();
  final exercise = IsarLink<Exercise>();

  UserCompletedExercise({
    required this.id,
    required this.completedProgramId,
    required this.programExerciseId,
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.duration,
    required this.weight,
    required this.restDuration,
    this.synced = true,
    this.pendingDelete = false,
    this.isLocalOnly = false,
  });
}
