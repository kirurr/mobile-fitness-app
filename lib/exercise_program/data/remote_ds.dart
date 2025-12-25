import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/exercise_program/dto.dart';
import 'package:mobile_fitness_app/exercise_program/mapper.dart';
import 'package:mobile_fitness_app/exercise_program/model.dart';

class ExerciseProgramRemoteDataSource {
  final ApiClient _api;
  final ExerciseProgramMapper _mapper;

  ExerciseProgramRemoteDataSource(this._api, this._mapper);

  Future<List<ExerciseProgram>> getAll({
    int? difficultyLevelId,
    int? subscriptionId,
    int? fitnessGoalId,
    int? userId,
  }) async {
    final query = <String, dynamic>{};
    if (difficultyLevelId != null) query['difficultyLevelId'] = difficultyLevelId;
    if (subscriptionId != null) query['subscriptionId'] = subscriptionId;
    if (fitnessGoalId != null) query['fitnessGoalId'] = fitnessGoalId;
    if (userId != null) query['userId'] = userId;

    final response = await safeApiCall(
      () => _api.getAuth(
        '/exercise-program',
        queryParameters: query.isEmpty ? null : query,
      ),
    );
    if (response.error != null) {
      throw response.error!;
    }

    final items = response.data?.data as List;
    return Future.wait(
      items.map(
        (json) => _mapper.fromDto(
          ExerciseProgramDTO.fromJson(json as Map<String, dynamic>),
        ),
      ),
    );
  }

  Future<ExerciseProgram?> getById(int id) async {
    final response = await safeApiCall(
      () => _api.getAuth('/exercise-program/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      ExerciseProgramDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }

  Future<ExerciseProgram> create(ExerciseProgramPayloadDTO payload) async {
    final response = await safeApiCall(
      () => _api.postAuth(
        '/exercise-program',
        data: payload.toJson(),
      ),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      ExerciseProgramDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }

  Future<ExerciseProgram> update(int id, ExerciseProgramPayloadDTO payload) async {
    final response = await safeApiCall(
      () => _api.putAuth(
        '/exercise-program/$id',
        data: payload.toJson(),
      ),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      ExerciseProgramDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }

  Future<void> delete(int id) async {
    final response = await safeApiCall(
      () => _api.deleteAuth('/exercise-program/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }
  }
}
