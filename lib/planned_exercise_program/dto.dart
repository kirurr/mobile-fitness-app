class PlannedExerciseProgramDateDTO {
  final int id;
  final int plannedExerciseProgramId;
  final String date;

  const PlannedExerciseProgramDateDTO({
    required this.id,
    required this.plannedExerciseProgramId,
    required this.date,
  });

  factory PlannedExerciseProgramDateDTO.fromJson(Map<String, dynamic> json) {
    return PlannedExerciseProgramDateDTO(
      id: (json['id'] as num).toInt(),
      plannedExerciseProgramId: (json['plannedExerciseProgramId'] as num)
          .toInt(),
      date: json['date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plannedExerciseProgramId': plannedExerciseProgramId,
      'date': date,
    };
  }
}

class PlannedExerciseProgramDTO {
  final int id;
  final int programId;
  final List<PlannedExerciseProgramDateDTO> dates;

  const PlannedExerciseProgramDTO({
    required this.id,
    required this.programId,
    required this.dates,
  });

  factory PlannedExerciseProgramDTO.fromJson(Map<String, dynamic> json) {
    final datesSource =
        (json['dates'] as List?) ??
        (json['plannedDates'] as List?) ??
        (json['planned_dates'] as List?) ??
        (json['plannedExerciseProgramDates'] as List?) ??
        const [];
    final datesJson = datesSource
        .map(
          (e) =>
              PlannedExerciseProgramDateDTO.fromJson(e as Map<String, dynamic>),
        )
        .toList();

    return PlannedExerciseProgramDTO(
      id: (json['id'] as num).toInt(),
      programId: (json['programId'] as num).toInt(),
      dates: datesJson,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'programId': programId,
      'dates': dates.map((d) => d.toJson()).toList(),
    };
  }
}

class PlannedExerciseProgramPayloadDTO {
  final int? id;
  final int programId;
  final List<String> dates;

  const PlannedExerciseProgramPayloadDTO({
    this.id,
    required this.programId,
    this.dates = const [],
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'programId': programId, 'dates': dates};
  }
}
