class UserPaymentDTO {
  final int id;
  final int userId;
  final String createdAt;
  final int amount;

  const UserPaymentDTO({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.amount,
  });

  factory UserPaymentDTO.fromJson(Map<String, dynamic> json) {
    return UserPaymentDTO(
      id: json['id'] as int,
      userId: json['userId'] as int,
      createdAt: json['createdAt'] as String,
      amount: json['amount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt,
      'amount': amount,
    };
  }
}

class UserPaymentPayloadDTO {
  final int userId;
  final int amount;

  const UserPaymentPayloadDTO({
    required this.userId,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amount': amount,
    };
  }
}
