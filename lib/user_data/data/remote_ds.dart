import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_data/model.dart';
import 'package:mobile_fitness_app/user_data/dto.dart';
import 'package:mobile_fitness_app/user_data/mapper.dart';

class UserDataRemoteDataSource {
  final ApiClient _api;
  final UserDataMapper _mapper;

  UserDataRemoteDataSource(this._api, this._mapper);

  Future<UserData?> getCurrent() async {
    final response = await safeApiCall(() => _api.getAuth('/user-data'));
    if (response.error != null) {
      if (response.error!.code == 400) {
        return null;
      }

      throw response.error!;
    }

    final data = response.data?.data;
    final dto = UserDataDTO.fromJson(data as Map<String, dynamic>);
    return _mapper.fromDto(dto);
  }

  Future<UserData> create(CreateUserDataDTO payload) async {
    final response = await safeApiCall(
      () => _api.postAuth(
        '/user-data',
        data: payload.toJson(),
      ),
    );
    if (response.error != null) {
      throw response.error!;
    }

    final data = response.data?.data;
    final dto = UserDataDTO.fromJson(data as Map<String, dynamic>);
    return _mapper.fromDto(dto);
  }

  Future<UserData> update(UserData payload) async {
    final dto = await _mapper.toDto(payload);
    final response = await safeApiCall(
      () => _api.putAuth(
        '/user-data',
        data: dto.toJson()
      ),
    );
    if (response.error != null) {
      throw response.error!;
    }

    final data = response.data?.data;
    final resultDto = UserDataDTO.fromJson(data as Map<String, dynamic>);
    return _mapper.fromDto(resultDto);
  }
}
