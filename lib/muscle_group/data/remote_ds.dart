import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/muscle_group/dto.dart';
import 'package:mobile_fitness_app/muscle_group/mapper.dart';
import 'package:mobile_fitness_app/muscle_group/model.dart';

class MuscleGroupRemoteDataSource {
  final ApiClient _api;

  MuscleGroupRemoteDataSource(this._api);

  Future<List<MuscleGroup>> getAll() async {
    final response = await safeApiCall(
      () => _api.getAuth('/muscle-group'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return (response.data?.data as List)
        .map(
          (json) => MuscleGroupMapper.fromDto(
            MuscleGroupDTO.fromJson(json as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  Future<MuscleGroup?> getById(int id) async {
    final response = await safeApiCall(
      () => _api.getAuth('/muscle-group/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return MuscleGroupMapper.fromDto(
      MuscleGroupDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }
}
