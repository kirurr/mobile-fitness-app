import 'package:mobile_fitness_app/user_payment/dto.dart';
import 'package:mobile_fitness_app/user_payment/model.dart';

class UserPaymentMapper {
  static UserPayment fromDto(UserPaymentDTO dto) {
    return UserPayment(
      id: dto.id,
      userId: dto.userId,
      createdAt: dto.createdAt,
      amount: dto.amount,
      synced: true,
      pendingDelete: false,
      isLocalOnly: false,
    );
  }

  static UserPaymentDTO toDto(UserPayment model) {
    return UserPaymentDTO(
      id: model.id,
      userId: model.userId,
      createdAt: model.createdAt,
      amount: model.amount,
    );
  }
}
