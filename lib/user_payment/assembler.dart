import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_payment/data/local_ds.dart';
import 'package:mobile_fitness_app/user_payment/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_payment/repository.dart';

class UserPaymentAssembler {
  static UserPaymentRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final local = UserPaymentLocalDataSource(isar);
    final remote = UserPaymentRemoteDataSource(api);

    return UserPaymentRepository(local: local, remote: remote);
  }
}
