import 'package:isar_community/isar.dart';
import 'package:mobile_fitness_app/subscription/model.dart';
import 'package:mobile_fitness_app/user_subscription/dto.dart';
import 'package:mobile_fitness_app/user_subscription/model.dart';

class UserSubscriptionMapper {
  final Isar isar;

  UserSubscriptionMapper({required this.isar});

  Future<UserSubscription> fromDto(UserSubscriptionDTO dto) async {
    final model = UserSubscription(
      id: dto.id,
      userId: dto.userId,
      startDate: dto.startDate,
      endDate: dto.endDate,
      synced: true,
      pendingDelete: false,
      isLocalOnly: false,
    );

    if (dto.subscriptionId != null) {
      model.subscription.value =
          await isar.subscriptions.get(dto.subscriptionId!);
    }

    return model;
  }

  Future<UserSubscriptionDTO> toDto(UserSubscription model) async {
    await model.subscription.load();

    return UserSubscriptionDTO(
      id: model.id,
      userId: model.userId,
      subscriptionId: model.subscription.value?.id,
      startDate: model.startDate,
      endDate: model.endDate,
    );
  }
}
