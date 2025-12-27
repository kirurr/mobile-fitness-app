class UserSubscriptionDTO {
  final int id;
  final int userId;
  final int? subscriptionId;
  final String startDate;
  final String endDate;

  const UserSubscriptionDTO({
    required this.id,
    required this.userId,
    required this.subscriptionId,
    required this.startDate,
    required this.endDate,
  });

  factory UserSubscriptionDTO.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionDTO(
      id: json['id'] as int,
      userId: json['userId'] as int,
      subscriptionId: json['subscriptionId'] as int?,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionId': subscriptionId,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

class UserSubscriptionPayloadDTO {
  final int? id;
  final int userId;
  final int? subscriptionId;
  final String startDate;
  final String endDate;

  const UserSubscriptionPayloadDTO({
    this.id,
    required this.userId,
    required this.subscriptionId,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionId': subscriptionId,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}
