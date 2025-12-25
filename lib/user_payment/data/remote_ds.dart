import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_payment/dto.dart';
import 'package:mobile_fitness_app/user_payment/mapper.dart';
import 'package:mobile_fitness_app/user_payment/model.dart';

class UserPaymentRemoteDataSource {
  final ApiClient _api;

  UserPaymentRemoteDataSource(this._api);

  Future<List<UserPayment>> getAll() async {
    final response = await safeApiCall(() => _api.getAuth('/user-payment'));
    if (response.error != null) {
      throw response.error!;
    }

    return (response.data?.data as List)
        .map(
          (json) => UserPaymentMapper.fromDto(
            UserPaymentDTO.fromJson(json as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  Future<UserPayment?> getById(int id) async {
    final response = await safeApiCall(() => _api.getAuth('/user-payment/$id'));
    if (response.error != null) {
      throw response.error!;
    }

    return UserPaymentMapper.fromDto(
      UserPaymentDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }

  Future<UserPayment> create(UserPaymentPayloadDTO payload) async {
    final response = await safeApiCall(
      () => _api.postAuth('/user-payment', data: payload.toJson()),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return UserPaymentMapper.fromDto(
      UserPaymentDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }

  Future<UserPayment> update(int id, UserPaymentPayloadDTO payload) async {
    final response = await safeApiCall(
      () => _api.putAuth('/user-payment/$id', data: payload.toJson()),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return UserPaymentMapper.fromDto(
      UserPaymentDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }

  Future<void> delete(int id) async {
    final response = await safeApiCall(() => _api.deleteAuth('/user-payment/$id'));
    if (response.error != null) {
      throw response.error!;
    }
  }
}
