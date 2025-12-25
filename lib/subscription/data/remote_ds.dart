import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/subscription/dto.dart';
import 'package:mobile_fitness_app/subscription/mapper.dart';
import 'package:mobile_fitness_app/subscription/model.dart';

class SubscriptionRemoteDataSource {
  final ApiClient _api;

  SubscriptionRemoteDataSource(this._api);

  Future<List<Subscription>> getAll() async {
    final response = await safeApiCall(() => _api.getAuth('/subscription'));
    if (response.error != null) {
      throw response.error!;
    }

    return (response.data?.data as List)
        .map(
          (json) => SubscriptionMapper.fromDto(
            SubscriptionDTO.fromJson(json as Map<String, dynamic>),
          ),
        )
        .toList();
  }

  Future<Subscription?> getById(int id) async {
    final response = await safeApiCall(() => _api.getAuth('/subscription/$id'));
    if (response.error != null) {
      throw response.error!;
    }

    return SubscriptionMapper.fromDto(
      SubscriptionDTO.fromJson(response.data!.data as Map<String, dynamic>),
    );
  }
}
