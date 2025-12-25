import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/exercise/dto.dart';
import 'package:mobile_fitness_app/exercise/model.dart';
import 'package:mobile_fitness_app/exercise/mapper.dart';

class ExerciseRemoteDataSource {
  final ApiClient _api;
  final ExerciseMapper _mapper;

  ExerciseRemoteDataSource(this._api, this._mapper);

  Future<List<Exercise>> getAll({
    int? categoryId,
    int? muscleGroupId,
    int? difficultyLevelId,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (categoryId != null) queryParameters['categoryId'] = categoryId;
    if (muscleGroupId != null) queryParameters['muscleGroupId'] = muscleGroupId;
    if (difficultyLevelId != null) {
      queryParameters['difficultyLevelId'] = difficultyLevelId;
    }

    final response = await safeApiCall(
      () => _api.getAuth(
        '/exercise',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      ),
    );
    if (response.error != null) {
      throw response.error!;
    }

    final items = response.data?.data as List;
    return Future.wait(
      items.map(
        (json) => _mapper.fromDto(
          ExerciseDTO.fromJson(json as Map<String, dynamic>),
        ),
      ),
    );
  }

  Future<Exercise?> getById(int id) async {
    final response = await safeApiCall(
      () => _api.getAuth('/exercise/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      ExerciseDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }
}
