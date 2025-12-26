import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_completed_exercise/dto.dart';
import 'package:mobile_fitness_app/user_completed_exercise/mapper.dart';
import 'package:mobile_fitness_app/user_completed_exercise/model.dart';

class UserCompletedExerciseRemoteDataSource {
  final ApiClient _api;
  final UserCompletedExerciseMapper _mapper;

  UserCompletedExerciseRemoteDataSource(this._api, this._mapper);

  Future<List<UserCompletedExercise>> getAll(int completedProgramId) async {
    final response = await safeApiCall(
      () => _api.getAuth(
        '/user-completed-exercise',
        queryParameters: {'completedProgramId': completedProgramId},
      ),
    );
    if (response.error != null) {
      throw response.error!;
    }

    final items = response.data?.data as List;
    return Future.wait(
      items.map(
        (json) => _mapper.fromDto(
          UserCompletedExerciseDTO.fromJson(json as Map<String, dynamic>),
        ),
      ),
    );
  }

  Future<UserCompletedExercise?> getById(int id) async {
    final response = await safeApiCall(
      () => _api.getAuth('/user-completed-exercise/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      UserCompletedExerciseDTO.fromJson(
        response.data!.data as Map<String, dynamic>,
      ),
    );
  }

  Future<UserCompletedExercise> create(
    UserCompletedExercisePayloadDTO payload,
  ) async {
    final response = await safeApiCall(
      () => _api.postAuth('/user-completed-exercise', data: payload.toJson()),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      UserCompletedExerciseDTO.fromJson(
        response.data!.data as Map<String, dynamic>,
      ),
    );
  }

  Future<UserCompletedExercise> update(
    int id,
    UserCompletedExercisePayloadDTO payload,
  ) async {
    final response = await safeApiCall(
      () =>
          _api.putAuth('/user-completed-exercise/$id', data: payload.toJson()),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      UserCompletedExerciseDTO.fromJson(
        response.data!.data as Map<String, dynamic>,
      ),
    );
  }

  Future<void> delete(int id) async {
    final response = await safeApiCall(
      () => _api.deleteAuth('/user-completed-exercise/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }
  }
}
