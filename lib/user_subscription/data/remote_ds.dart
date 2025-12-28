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
      () => _api.postAuth('/user-subscription', data: _withIsoDates(payload)),
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
      () => _api.putAuth('/user-subscription/$id', data: _withIsoDates(payload)),
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

  Map<String, dynamic> _withIsoDates(UserSubscriptionPayloadDTO payload) {
    return {
      if (payload.id != null) 'id': payload.id,
      'userId': payload.userId,
      'subscriptionId': payload.subscriptionId,
      'startDate': _toIsoString(payload.startDate),
      'endDate': _toIsoString(payload.endDate),
    };
  }

  String _toIsoString(String value) {
    final parsed = DateTime.tryParse(value);
    return (parsed ?? DateTime.parse(value)).toUtc().toIso8601String();
  }
}
