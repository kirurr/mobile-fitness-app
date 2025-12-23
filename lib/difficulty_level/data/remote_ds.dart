import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/difficulty_level/model.dart';
import 'package:mobile_fitness_app/difficulty_level/dto.dart';
import 'package:mobile_fitness_app/difficulty_level/mapper.dart';

class DifficultyLevelRemoteDataSource {
  final ApiClient _api;

  DifficultyLevelRemoteDataSource(this._api);

  Future<List<DifficultyLevel>> getAll() async {
    final response = await safeApiCall(() => _api.getAuth('/difficulty-level'));
    if (response.error != null) {
      throw response.error!;
    }

    return (response.data?.data as List)
        .map((json) => DifficultyLevelMapper.fromDto(
              DifficultyLevelDTO.fromJson(json as Map<String, dynamic>),
            ))
        .toList();
  }

  Future<DifficultyLevel?> getById(int id) async {
    final response = await safeApiCall(
      () => _api.getAuth('/difficulty-level/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return DifficultyLevelMapper.fromDto(
      DifficultyLevelDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }
}
