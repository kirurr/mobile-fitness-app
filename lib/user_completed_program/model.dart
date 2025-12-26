import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';

part 'model.g.dart';

@collection
class UserCompletedProgram {
  late Id id;
  final int userId;
  final int programId;
  final String startDate;
  final String? endDate;
  bool synced;
  bool pendingDelete;
  bool isLocalOnly;

  final program = IsarLink<ExerciseProgram>();
  final completedExercises = IsarLinks<UserCompletedExercise>();

  UserCompletedProgram({
    required this.id,
    required this.userId,
    required this.programId,
    required this.startDate,
    required this.endDate,
    this.synced = true,
    this.pendingDelete = false,
    this.isLocalOnly = false,
  });
}
