class SubscriptionDTO {
  final int id;
  final String name;
  final int monthlyCost;

  const SubscriptionDTO({
    required this.id,
    required this.name,
    required this.monthlyCost,
  });

  factory SubscriptionDTO.fromJson(Map<String, dynamic> json) {
    return SubscriptionDTO(
      id: json['id'] as int,
      name: json['name'] as String,
      monthlyCost: json['monthlyCost'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'monthlyCost': monthlyCost,
    };
  }
}
