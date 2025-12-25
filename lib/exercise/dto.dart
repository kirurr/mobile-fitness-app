class ExerciseDTO {
  final int id;
  final String name;
  final int categoryId;
  final int muscleGroupId;
  final int difficultyLevelId;
  final String type;

  const ExerciseDTO({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.muscleGroupId,
    required this.difficultyLevelId,
    required this.type,
  });

  factory ExerciseDTO.fromJson(Map<String, dynamic> json) {
    return ExerciseDTO(
      id: json['id'] as int,
      name: json['name'] as String,
      categoryId: json['categoryId'] as int,
      muscleGroupId: json['muscleGroupId'] as int,
      difficultyLevelId: json['difficultyLevelId'] as int,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'muscleGroupId': muscleGroupId,
      'difficultyLevelId': difficultyLevelId,
      'type': type,
    };
  }
}
