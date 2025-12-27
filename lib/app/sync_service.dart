import 'package:mobile_fitness_app/planned_exercise_program/repository.dart';
import 'package:mobile_fitness_app/user_completed_exercise/repository.dart';
import 'package:mobile_fitness_app/user_completed_program/repository.dart';
import 'package:mobile_fitness_app/user_payment/repository.dart';
import 'package:mobile_fitness_app/user_subscription/repository.dart';

class SyncService {
  final UserSubscriptionRepository userSubscriptionRepository;
  final UserPaymentRepository userPaymentRepository;
  final PlannedExerciseProgramRepository plannedExerciseProgramRepository;
  final UserCompletedProgramRepository userCompletedProgramRepository;
  final UserCompletedExerciseRepository userCompletedExerciseRepository;

  bool _isSyncing = false;
  final Duration delayBetweenEntities;
  final Duration retryDelay;
  final int maxRetries;

  SyncService({
    required this.userSubscriptionRepository,
    required this.userPaymentRepository,
    required this.plannedExerciseProgramRepository,
    required this.userCompletedProgramRepository,
    required this.userCompletedExerciseRepository,
    this.delayBetweenEntities = const Duration(milliseconds: 400),
    this.retryDelay = const Duration(seconds: 2),
    this.maxRetries = 2,
  });

  Future<void> syncAll() async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await _syncWithRetry(userSubscriptionRepository.sync);
      await _delayBetween();
      await _syncWithRetry(userPaymentRepository.sync);
      await _delayBetween();
      await _syncWithRetry(plannedExerciseProgramRepository.sync);
      await _delayBetween();
      await _syncWithRetry(userCompletedProgramRepository.sync);
      await _delayBetween();
      await _syncWithRetry(userCompletedExerciseRepository.sync);
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
