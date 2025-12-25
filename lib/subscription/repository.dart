import 'package:mobile_fitness_app/subscription/data/local_ds.dart';
import 'package:mobile_fitness_app/subscription/data/remote_ds.dart';
import 'package:mobile_fitness_app/subscription/model.dart';

class SubscriptionRepository {
  final SubscriptionLocalDataSource local;
  final SubscriptionRemoteDataSource remote;

  SubscriptionRepository({
    required this.local,
    required this.remote,
  });

  Stream<List<Subscription>> watchSubscriptions() {
    return local.watchAll();
  }

  Future<List<Subscription>> getLocalSubscriptions() {
    return local.getAll();
  }

  Future<void> refreshSubscriptions() async {
    try {
      final remoteItems = await remote.getAll();
      await local.replaceAll(remoteItems);
    } catch (e) {
      print('Error refreshing subscriptions: $e');
      rethrow;
    }
  }
}
