import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/app/isar.dart';
import 'package:mobile_fitness_app/exercise/assembler.dart';
import 'package:mobile_fitness_app/exercise/repository.dart';
import 'package:mobile_fitness_app/exercise_category/assembler.dart';
import 'package:mobile_fitness_app/exercise_category/repository.dart';
import 'package:mobile_fitness_app/muscle_group/assembler.dart';
import 'package:mobile_fitness_app/muscle_group/repository.dart';
import 'package:mobile_fitness_app/exercise_program/assembler.dart';
import 'package:mobile_fitness_app/exercise_program/repository.dart';
import 'package:mobile_fitness_app/subscription/assembler.dart';
import 'package:mobile_fitness_app/subscription/repository.dart';
import 'package:mobile_fitness_app/user_payment/assembler.dart';
import 'package:mobile_fitness_app/user_payment/repository.dart';
import 'package:mobile_fitness_app/user_subscription/assembler.dart';
import 'package:mobile_fitness_app/user_subscription/repository.dart';
import 'package:mobile_fitness_app/user_data/assembler.dart';
import 'package:mobile_fitness_app/user_data/repository.dart';
import 'package:mobile_fitness_app/difficulty_level/assembler.dart';
import 'package:mobile_fitness_app/difficulty_level/repository.dart';
import 'package:mobile_fitness_app/fitness_goal/assembler.dart';
import 'package:mobile_fitness_app/fitness_goal/repository.dart';
import 'package:mobile_fitness_app/user_completed_program/assembler.dart';
import 'package:mobile_fitness_app/user_completed_program/repository.dart';
import 'package:mobile_fitness_app/user_completed_exercise/assembler.dart';
import 'package:mobile_fitness_app/user_completed_exercise/repository.dart';
import 'package:mobile_fitness_app/planned_exercise_program/assembler.dart';
import 'package:mobile_fitness_app/planned_exercise_program/repository.dart';
import 'package:mobile_fitness_app/app/sync_service.dart';

class Dependencies {
  final Isar db;
  final FitnessGoalRepository fitnessGoalRepository;
  final DifficultyLevelRepository difficultyLevelRepository;
  final ExerciseCategoryRepository exerciseCategoryRepository;
  final MuscleGroupRepository muscleGroupRepository;
  final ExerciseRepository exerciseRepository;
  final ExerciseProgramRepository exerciseProgramRepository;
  final SubscriptionRepository subscriptionRepository;
  final UserSubscriptionRepository userSubscriptionRepository;
  final UserPaymentRepository userPaymentRepository;
  final UserDataRepository userDataRepository;
  final UserCompletedProgramRepository userCompletedProgramRepository;
  final UserCompletedExerciseRepository userCompletedExerciseRepository;
  final PlannedExerciseProgramRepository plannedExerciseProgramRepository;
  final SyncService syncService;

  Dependencies._({
    required this.db,
    required this.fitnessGoalRepository,
    required this.difficultyLevelRepository,
    required this.exerciseCategoryRepository,
    required this.muscleGroupRepository,
    required this.exerciseRepository,
    required this.exerciseProgramRepository,
    required this.subscriptionRepository,
    required this.userSubscriptionRepository,
    required this.userPaymentRepository,
    required this.userDataRepository,
    required this.userCompletedProgramRepository,
    required this.userCompletedExerciseRepository,
    required this.plannedExerciseProgramRepository,
    required this.syncService,
  });

  static Future<Dependencies> init() async {
    await dotenv.load(fileName: ".env");
    await ApiClient.instance.init();

    final isarService = await IsarService().openDB();

    final fitnessGoalRepository = FitnessGoalAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );
    final difficultyLevelRepository = DifficultyLevelAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );
    final exerciseCategoryRepository = ExerciseCategoryAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );
    final muscleGroupRepository = MuscleGroupAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );
    final exerciseRepository = ExerciseAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );
    final exerciseProgramRepository = ExerciseProgramAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );
    final subscriptionRepository = SubscriptionAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );
    final userSubscriptionRepository = UserSubscriptionAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );
    final userPaymentRepository = UserPaymentAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );
    final userDataRepository = UserDataAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );
    final userCompletedProgramRepository = UserCompletedProgramAssembler.build(
      isar: isarService,
      api: ApiClient.instance,
    );
    final userCompletedExerciseRepository =
        UserCompletedExerciseAssembler.build(
          isar: isarService,
          api: ApiClient.instance,
        );
    final plannedExerciseProgramRepository =
        PlannedExerciseProgramAssembler.build(
          isar: isarService,
          api: ApiClient.instance,
        );

    final syncService = SyncService(
      difficultyLevelRepository: difficultyLevelRepository,
      subscriptionRepository: subscriptionRepository,
      fitnessGoalRepository: fitnessGoalRepository,
      exerciseCategoryRepository: exerciseCategoryRepository,
      muscleGroupRepository: muscleGroupRepository,
      exerciseRepository: exerciseRepository,
      userSubscriptionRepository: userSubscriptionRepository,
      userPaymentRepository: userPaymentRepository,
      userDataRepository: userDataRepository,
      exerciseProgramRepository: exerciseProgramRepository,
      plannedExerciseProgramRepository: plannedExerciseProgramRepository,
      userCompletedProgramRepository: userCompletedProgramRepository,
      userCompletedExerciseRepository: userCompletedExerciseRepository,
    );

    return Dependencies._(
      db: isarService,
      fitnessGoalRepository: fitnessGoalRepository,
      difficultyLevelRepository: difficultyLevelRepository,
      exerciseCategoryRepository: exerciseCategoryRepository,
      muscleGroupRepository: muscleGroupRepository,
      exerciseRepository: exerciseRepository,
      exerciseProgramRepository: exerciseProgramRepository,
      subscriptionRepository: subscriptionRepository,
      userSubscriptionRepository: userSubscriptionRepository,
      userPaymentRepository: userPaymentRepository,
      userDataRepository: userDataRepository,
      userCompletedProgramRepository: userCompletedProgramRepository,
      userCompletedExerciseRepository: userCompletedExerciseRepository,
      plannedExerciseProgramRepository: plannedExerciseProgramRepository,
      syncService: syncService,
    );
  }
}
