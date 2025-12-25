import 'package:mobile_fitness_app/muscle_group/data/local_ds.dart';
import 'package:mobile_fitness_app/muscle_group/data/remote_ds.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';

class MuscleGroupRepository {
  final MuscleGroupLocalDataSource local;
  final MuscleGroupRemoteDataSource remote;

  MuscleGroupRepository({
    required this.local,
    required this.remote,
  });

  Stream<List<MuscleGroup>> watchGroups() {
    return local.watchAll();
  }

  Future<List<MuscleGroup>> getLocalGroups() {
    return local.getAll();
  }

  Future<void> refreshGroups() async {
    try {
      final remoteGroups = await remote.getAll();

      await local.replaceAll(remoteGroups);
    } catch (e) {
      print('Error refreshing muscle groups: $e');
      rethrow;
    }
  }
}
