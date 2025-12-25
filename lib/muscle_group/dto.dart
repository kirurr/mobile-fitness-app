class MuscleGroupDTO {
  final int id;
  final String name;

  const MuscleGroupDTO({
    required this.id,
    required this.name,
  });

  factory MuscleGroupDTO.fromJson(Map<String, dynamic> json) {
    return MuscleGroupDTO(
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
