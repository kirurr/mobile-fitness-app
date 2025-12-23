class DifficultyLevelDTO {
  final int id;
  final String name;
  final String description;

  const DifficultyLevelDTO({
    required this.id,
    required this.name,
    required this.description,
  });

  factory DifficultyLevelDTO.fromJson(Map<String, dynamic> json) {
    return DifficultyLevelDTO(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
