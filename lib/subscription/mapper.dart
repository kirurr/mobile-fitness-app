import 'package:mobile_fitness_app/subscription/dto.dart';
import 'package:mobile_fitness_app/subscription/model.dart';

class SubscriptionMapper {
  static Subscription fromDto(SubscriptionDTO dto) {
    return Subscription(
      id: dto.id,
      name: dto.name,
      monthlyCost: dto.monthlyCost,
    );
  }

  static SubscriptionDTO toDto(Subscription model) {
    return SubscriptionDTO(
      id: model.id,
      name: model.name,
      monthlyCost: model.monthlyCost,
    );
  }
}
