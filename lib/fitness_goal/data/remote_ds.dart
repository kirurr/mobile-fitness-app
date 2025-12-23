import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/fitness_goal/model.dart';

class FitnessGoalRemoteDataSource {
  final ApiClient _api;

  FitnessGoalRemoteDataSource(this._api);

  Future<List<FitnessGoal>> getAll() async {
    final response = await safeApiCall(() => _api.getAuth('/fitness-goal'));
    if (response.error != null) {
      throw response.error!;
    }

    return (response.data?.data as List)
        .map((json) => FitnessGoal.fromJson(json))
        .toList();
  }

  Future<FitnessGoal?> getById(int id) async {
    final response = await safeApiCall(() => _api.getAuth('/fitness-goal/$id'));
    if (response.error != null) {
      throw response.error!;
    }

    return FitnessGoal.fromJson(response.data!.data);
  }
}
