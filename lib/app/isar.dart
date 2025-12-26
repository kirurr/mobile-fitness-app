import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart'
    as program_exercise;
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/user_payment/model.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';
import 'package:mobile_fitness_app/planned_exercise_program/model.dart';
import 'package:mobile_fitness_app/user_data/model.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          FitnessGoalSchema,
          DifficultyLevelSchema,
          UserDataSchema,
          ExerciseCategorySchema,
          MuscleGroupSchema,
          ExerciseSchema,
          ExerciseProgramSchema,
          program_exercise.ProgramExerciseSchema,
          SubscriptionSchema,
          UserSubscriptionSchema,
          UserPaymentSchema,
          UserCompletedProgramSchema,
          UserCompletedExerciseSchema,
          PlannedExerciseProgramSchema,
          PlannedExerciseProgramDateSchema,
        ],
        inspector: true,
        directory: dir.path,
      );
    }

    return Future.value(Isar.getInstance());
  }
}
