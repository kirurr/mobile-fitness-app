import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/subscription/data/local_ds.dart';
import 'package:mobile_fitness_app/subscription/data/remote_ds.dart';
import 'package:mobile_fitness_app/subscription/repository.dart';

class SubscriptionAssembler {
  static SubscriptionRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final local = SubscriptionLocalDataSource(isar);
    final remote = SubscriptionRemoteDataSource(api);

    return SubscriptionRepository(local: local, remote: remote);
  }
}
