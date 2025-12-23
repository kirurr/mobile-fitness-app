class FitnessGoalDTO {
  final int id;
  final String name;

  const FitnessGoalDTO({
    required this.id,
    required this.name,
  });

  factory FitnessGoalDTO.fromJson(Map<String, dynamic> json) {
    return FitnessGoalDTO(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
