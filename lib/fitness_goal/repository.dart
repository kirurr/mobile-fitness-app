import 'package:mobile_fitness_app/fitness_goal/data/local_ds.dart';
import 'package:mobile_fitness_app/fitness_goal/data/remote_ds.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';

class FitnessGoalRepository {
  final FitnessGoalLocalDataSource local;
  final FitnessGoalRemoteDataSource remote;

  FitnessGoalRepository({required this.local, required this.remote});

  Stream<List<FitnessGoal>> watchGoals() {
    return local.watchAll();
  }

  Future<List<FitnessGoal>> getLocalGoals() {
    return local.getAll();
  }

  Future<void> refreshGoals() async {
    try {
      final remoteGoals = await remote.getAll();

      await local.replaceAll(remoteGoals);
    } catch (e) {
      print('Error refreshing goals: $e');
      rethrow;
    }
  }
}
