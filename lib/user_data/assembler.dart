import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/app/dio.dart';
import 'package:mobile_fitness_app/user_data/data/local_ds.dart';
import 'package:mobile_fitness_app/user_data/data/remote_ds.dart';
import 'package:mobile_fitness_app/user_data/mapper.dart';
import 'package:mobile_fitness_app/user_data/repository.dart';

class UserDataAssembler {
  static UserDataRepository build({
    required Isar isar,
    required ApiClient api,
  }) {
    final local = UserDataLocalDataSource(isar);
    final mapper = UserDataMapper(isar: isar);
    final remote = UserDataRemoteDataSource(api, mapper);

    return UserDataRepository(local: local, remote: remote);
  }
}
