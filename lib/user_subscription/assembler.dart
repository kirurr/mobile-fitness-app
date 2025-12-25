import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_subscription/data/local_ds.dart';
import 'package:mobile_fitness_app/user_subscription/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_subscription/mapper.dart';
import 'package:mobile_fitness_app/user_subscription/repository.dart';

class UserSubscriptionAssembler {
  static UserSubscriptionRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final local = UserSubscriptionLocalDataSource(isar);
    final mapper = UserSubscriptionMapper(isar: isar);
    final remote = UserSubscriptionRemoteDataSource(api, mapper);

    return UserSubscriptionRepository(local: local, remote: remote);
  }
}
