import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_subscription/dto.dart';
import 'package:mobile_fitness_app/user_subscription/mapper.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';

class UserSubscriptionRemoteDataSource {
  final ApiClient _api;
  final UserSubscriptionMapper _mapper;

  UserSubscriptionRemoteDataSource(this._api, this._mapper);

  Future<List<UserSubscription>> getAll() async {
    final response = await safeApiCall(() => _api.getAuth('/user-subscription'));
    if (response.error != null) {
      throw response.error!;
    }

    final items = response.data?.data as List;
    return Future.wait(
      items.map(
        (json) => _mapper.fromDto(
          UserSubscriptionDTO.fromJson(json as Map<String, dynamic>),
        ),
      ),
    );
  }

  Future<UserSubscription?> getById(int id) async {
    final response = await safeApiCall(
      () => _api.getAuth('/user-subscription/$id'),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      UserSubscriptionDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }

  Future<UserSubscription> create(UserSubscriptionPayloadDTO payload) async {
    final response = await safeApiCall(
      () => _api.postAuth('/user-subscription', data: payload.toJson()),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      UserSubscriptionDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }

  Future<UserSubscription> update(int id, UserSubscriptionPayloadDTO payload) async {
    final response = await safeApiCall(
      () => _api.putAuth('/user-subscription/$id', data: payload.toJson()),
    );
    if (response.error != null) {
      throw response.error!;
    }

    return _mapper.fromDto(
      UserSubscriptionDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }

  Future<void> delete(int id) async {
    final response = await safeApiCall(() => _api.deleteAuth('/user-subscription/$id'));
    if (response.error != null) {
      throw response.error!;
    }
  }
}
