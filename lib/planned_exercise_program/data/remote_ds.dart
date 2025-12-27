import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/planned_exercise_program/dto.dart';
import 'package:mobile_fitness_app/planned_exercise_program/mapper.dart';
import 'package:mobile_fitness_app/planned_exercise_program/model.dart';

class PlannedExerciseProgramRemoteDataSource {
  final ApiClient _api;
  final PlannedExerciseProgramMapper _mapper;

  PlannedExerciseProgramRemoteDataSource(this._api, this._mapper);

  Future<List<PlannedExerciseProgram>> getAll() async {
    final response = await safeApiCall(
      () => _api.getAuth('/planned-exercise-program'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    final items = response.data?.data as List;
    return Future.wait(
      items.map(
        (json) => _mapper.fromDto(
          PlannedExerciseProgramDTO.fromJson(json as Map<String, dynamic>),
        ),
      ),
    );
  }

  Future<PlannedExerciseProgram?> getById(int id) async {
    final response = await safeApiCall(
      () => _api.getAuth('/planned-exercise-program/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      PlannedExerciseProgramDTO.fromJson(
        response.data!.data as Map<String, dynamic>,
      ),
    );
  }

  Future<PlannedExerciseProgram> create(
    PlannedExerciseProgramPayloadDTO payload,
  ) async {
    final response = await safeApiCall(
      () => _api.postAuth(
        '/planned-exercise-program',
        data: _withIsoDates(payload),
      ),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      PlannedExerciseProgramDTO.fromJson(
        response.data!.data as Map<String, dynamic>,
      ),
    );
  }

  Future<PlannedExerciseProgram> update(
    int id,
    PlannedExerciseProgramPayloadDTO payload,
  ) async {
    final response = await safeApiCall(
      () => _api.putAuth(
        '/planned-exercise-program/$id',
        data: _withIsoDates(payload),
      ),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      PlannedExerciseProgramDTO.fromJson(
        response.data!.data as Map<String, dynamic>,
      ),
    );
  }

  Future<void> delete(int id) async {
    final response = await safeApiCall(
      () => _api.deleteAuth('/planned-exercise-program/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }
  }

  Map<String, dynamic> _withIsoDates(PlannedExerciseProgramPayloadDTO payload) {
    return {
      if (payload.id != null) 'id': payload.id,
      'programId': payload.programId,
      'dates': payload.dates.map(_toIsoString).toList(),
    };
  }

  String _toIsoString(String value) {
    final parsed = DateTime.tryParse(value);
    return (parsed ?? DateTime.parse(value)).toUtc().toIso8601String();
  }
}
