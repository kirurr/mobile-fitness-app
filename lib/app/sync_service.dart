import 'package:mobile_fitness_app/difficulty_level/repository.dart';
import 'package:mobile_fitness_app/exercise/repository.dart';
import 'package:mobile_fitness_app/exercise_category/repository.dart';
import 'package:mobile_fitness_app/fitness_goal/repository.dart';
import 'package:mobile_fitness_app/muscle_group/repository.dart';
import 'package:mobile_fitness_app/planned_exercise_program/repository.dart';
import 'package:mobile_fitness_app/subscription/repository.dart';
import 'package:mobile_fitness_app/user_completed_exercise/repository.dart';
import 'package:mobile_fitness_app/user_completed_program/repository.dart';
import 'package:mobile_fitness_app/user_data/repository.dart';
import 'package:mobile_fitness_app/user_payment/repository.dart';
import 'package:mobile_fitness_app/user_subscription/repository.dart';
import 'package:mobile_fitness_app/exercise_program/repository.dart';

class SyncService {
  final DifficultyLevelRepository difficultyLevelRepository;
  final SubscriptionRepository subscriptionRepository;
  final FitnessGoalRepository fitnessGoalRepository;
  final ExerciseCategoryRepository exerciseCategoryRepository;
  final MuscleGroupRepository muscleGroupRepository;
  final ExerciseRepository exerciseRepository;
  final UserSubscriptionRepository userSubscriptionRepository;
  final UserPaymentRepository userPaymentRepository;
  final UserDataRepository userDataRepository;
  final ExerciseProgramRepository exerciseProgramRepository;
  final PlannedExerciseProgramRepository plannedExerciseProgramRepository;
  final UserCompletedProgramRepository userCompletedProgramRepository;
  final UserCompletedExerciseRepository userCompletedExerciseRepository;

  bool _isSyncing = false;
  final Duration delayBetweenEntities;
  final Duration retryDelay;
  final int maxRetries;

  SyncService({
    required this.difficultyLevelRepository,
    required this.subscriptionRepository,
    required this.fitnessGoalRepository,
    required this.exerciseCategoryRepository,
    required this.muscleGroupRepository,
    required this.exerciseRepository,
    required this.userSubscriptionRepository,
    required this.userPaymentRepository,
    required this.userDataRepository,
    required this.exerciseProgramRepository,
    required this.plannedExerciseProgramRepository,
    required this.userCompletedProgramRepository,
    required this.userCompletedExerciseRepository,
    this.delayBetweenEntities = const Duration(milliseconds: 400),
    this.retryDelay = const Duration(seconds: 2),
    this.maxRetries = 2,
  });

  Future<void> refreshAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await _syncWithRetry(difficultyLevelRepository.refreshLevels);
      await _delayBetween();
      await _syncWithRetry(fitnessGoalRepository.refreshGoals);
      await _delayBetween();
      await _syncWithRetry(userDataRepository.refreshUserData);
      await _delayBetween();
      await _syncWithRetry(subscriptionRepository.refreshSubscriptions);
      await _delayBetween();
      await _syncWithRetry(exerciseCategoryRepository.refreshCategories);
      await _delayBetween();
      await _syncWithRetry(muscleGroupRepository.refreshGroups);
      await _delayBetween();
      await _syncWithRetry(() => exerciseRepository.refreshExercises());
      await _delayBetween();
      await _syncWithRetry(exerciseProgramRepository.refreshProgramsIfSafe);
      await _delayBetween();
      await _syncWithRetry(userSubscriptionRepository.refreshUserSubscriptions);
      await _delayBetween();
      await _syncWithRetry(userPaymentRepository.refreshUserPayments);
      await _delayBetween();
      await _syncWithRetry(plannedExerciseProgramRepository.refreshPlannedPrograms);
      await _delayBetween();
      await _syncWithRetry(userCompletedProgramRepository.refreshCompletedPrograms);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncPending() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await _syncWithRetry(userSubscriptionRepository.sync);
      await _delayBetween();
      await _syncWithRetry(userPaymentRepository.sync);
      await _delayBetween();
      await _syncWithRetry(exerciseProgramRepository.sync);
      await _delayBetween();
      await _syncWithRetry(plannedExerciseProgramRepository.sync);
      await _delayBetween();
      await _syncWithRetry(userCompletedProgramRepository.sync);
      await _delayBetween();
      await _syncWithRetry(userCompletedExerciseRepository.sync);
      await _delayBetween();
      await _syncWithRetry(userDataRepository.syncLocalUserData);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncWithRetry(Future<void> Function() action) async {
    int attempt = 0;
    while (true) {
      try {
        await action();
        return;
      } catch (_) {
        attempt += 1;
        if (attempt > maxRetries) rethrow;
        await Future.delayed(retryDelay);
      }
    }
  }

  Future<void> _delayBetween() async {
    if (delayBetweenEntities.inMilliseconds <= 0) return;
    await Future.delayed(delayBetweenEntities);
  }
}
