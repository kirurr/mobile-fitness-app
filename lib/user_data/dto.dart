class UserDataDTO {
  final int userId;
  final String name;
  final int age;
  final int weight;
  final int height;
  final int fitnessGoalId;
  final int trainingLevel;

  const UserDataDTO({
    required this.userId,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.fitnessGoalId,
    required this.trainingLevel,
  });

  factory UserDataDTO.fromJson(Map<String, dynamic> json) {
    return UserDataDTO(
      userId: json['userId'] as int,
      name: json['name'] as String,
      age: json['age'] as int,
      weight: json['weight'] as int,
      height: json['height'] as int,
      fitnessGoalId: json['fitnessGoalId'] as int,
      trainingLevel: json['trainingLevel'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'fitnessGoalId': fitnessGoalId,
      'trainingLevel': trainingLevel,
    };
  }
}

class CreateUserDataDTO {
  final String name;
  final int age;
  final int weight;
  final int height;
  final int fitnessGoalId;
  final int trainingLevel;

  const CreateUserDataDTO({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.fitnessGoalId,
    required this.trainingLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'fitnessGoalId': fitnessGoalId,
      'trainingLevel': trainingLevel,
    };
  }
}
