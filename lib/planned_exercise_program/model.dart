import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';

part 'model.g.dart';

@collection
class PlannedExerciseProgram {
  late Id id;
  final int programId;
  bool synced;
  bool pendingDelete;
  bool isLocalOnly;

  final program = IsarLink<ExerciseProgram>();
  final dates = IsarLinks<PlannedExerciseProgramDate>();

  PlannedExerciseProgram({
    required this.id,
    required this.programId,
    this.synced = true,
    this.pendingDelete = false,
    this.isLocalOnly = false,
  });
}

@collection
class PlannedExerciseProgramDate {
  late Id id;
  final int plannedExerciseProgramId;
  final String date;

  final plannedProgram = IsarLink<PlannedExerciseProgram>();

  PlannedExerciseProgramDate({
    required this.id,
    required this.plannedExerciseProgramId,
    required this.date,
  });
}
