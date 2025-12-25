import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/exercise_category/dto.dart';
import 'package:mobile_fitness_app/exercise_category/mapper.dart';
import 'package:mobile_fitness_app/exercise_category/model.dart';

class ExerciseCategoryRemoteDataSource {
  final ApiClient _api;

  ExerciseCategoryRemoteDataSource(this._api);

  Future<List<ExerciseCategory>> getAll() async {
    final response = await safeApiCall(
      () => _api.getAuth('/exercise-category'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return (response.data?.data as List)
        .map(
          (json) => ExerciseCategoryMapper.fromDto(
            ExerciseCategoryDTO.fromJson(json as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  Future<ExerciseCategory?> getById(int id) async {
    final response = await safeApiCall(
      () => _api.getAuth('/exercise-category/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return ExerciseCategoryMapper.fromDto(
      ExerciseCategoryDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }
}
