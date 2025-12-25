class ExerciseCategoryDTO {
  final int id;
  final String name;
  final String description;

  const ExerciseCategoryDTO({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ExerciseCategoryDTO.fromJson(Map<String, dynamic> json) {
    return ExerciseCategoryDTO(
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
