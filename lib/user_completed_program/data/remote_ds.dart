import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_completed_program/dto.dart';
import 'package:mobile_fitness_app/user_completed_program/mapper.dart';
import 'package:mobile_fitness_app/user_completed_program/model.dart';

class UserCompletedProgramRemoteDataSource {
  final ApiClient _api;
  final UserCompletedProgramMapper _mapper;

  UserCompletedProgramRemoteDataSource(this._api, this._mapper);

  Future<List<UserCompletedProgram>> getAll() async {
    final response = await safeApiCall(
      () => _api.getAuth('/user-completed-program'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    final items = response.data?.data as List;
    return Future.wait(
      items.map(
        (json) => _mapper.fromDto(
          UserCompletedProgramDTO.fromJson(json as Map<String, dynamic>),
        ),
      ),
    );
  }

  Future<UserCompletedProgram?> getById(int id) async {
    final response = await safeApiCall(
      () => _api.getAuth('/user-completed-program/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      UserCompletedProgramDTO.fromJson(
        response.data!.data as Map<String, dynamic>,
      ),
    );
  }

  Future<UserCompletedProgram> create(
    UserCompletedProgramPayloadDTO payload,
  ) async {
    final response = await safeApiCall(
      () => _api.postAuth(
        '/user-completed-program',
        data: _withIsoDates(payload),
      ),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      UserCompletedProgramDTO.fromJson(
        response.data!.data as Map<String, dynamic>,
      ),
    );
  }

  Future<UserCompletedProgram> update(
    int id,
    UserCompletedProgramPayloadDTO payload,
  ) async {
    final response = await safeApiCall(
      () => _api.putAuth(
        '/user-completed-program/$id',
        data: _withIsoDates(payload),
      ),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      UserCompletedProgramDTO.fromJson(
        response.data!.data as Map<String, dynamic>,
      ),
    );
  }

  Future<void> delete(int id) async {
    final response = await safeApiCall(
      () => _api.deleteAuth('/user-completed-program/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }
  }

  Map<String, dynamic> _withIsoDates(UserCompletedProgramPayloadDTO payload) {
    return {
      if (payload.id != null) 'id': payload.id,
      'userId': payload.userId,
      'programId': payload.programId,
      'startDate':
          payload.startDate != null ? _toIsoString(payload.startDate!) : null,
      'endDate': payload.endDate != null ? _toIsoString(payload.endDate!) : null,
    };
  }

  String _toIsoString(String value) {
    final parsed = DateTime.tryParse(value);
    return (parsed ?? DateTime.parse(value)).toUtc().toIso8601String();
  }
}
