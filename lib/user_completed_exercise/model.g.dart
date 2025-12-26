// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserCompletedExerciseCollection on Isar {
  IsarCollection<UserCompletedExercise> get userCompletedExercises =>
      this.collection();
}

const UserCompletedExerciseSchema = CollectionSchema(
  name: r'UserCompletedExercise',
  id: -2839832728717449070,
  properties: {
    r'completedProgramId': PropertySchema(
      id: 0,
      name: r'completedProgramId',
      type: IsarType.long,
    ),
    r'duration': PropertySchema(id: 1, name: r'duration', type: IsarType.long),
    r'exerciseId': PropertySchema(
      id: 2,
      name: r'exerciseId',
      type: IsarType.long,
    ),
    r'isLocalOnly': PropertySchema(
      id: 3,
      name: r'isLocalOnly',
      type: IsarType.bool,
    ),
    r'pendingDelete': PropertySchema(
      id: 4,
      name: r'pendingDelete',
      type: IsarType.bool,
    ),
    r'programExerciseId': PropertySchema(
      id: 5,
      name: r'programExerciseId',
      type: IsarType.long,
    ),
    r'reps': PropertySchema(id: 6, name: r'reps', type: IsarType.long),
    r'restDuration': PropertySchema(
      id: 7,
      name: r'restDuration',
      type: IsarType.long,
    ),
    r'sets': PropertySchema(id: 8, name: r'sets', type: IsarType.long),
    r'synced': PropertySchema(id: 9, name: r'synced', type: IsarType.bool),
    r'weight': PropertySchema(id: 10, name: r'weight', type: IsarType.long),
  },

  estimateSize: _userCompletedExerciseEstimateSize,
  serialize: _userCompletedExerciseSerialize,
  deserialize: _userCompletedExerciseDeserialize,
  deserializeProp: _userCompletedExerciseDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'programExercise': LinkSchema(
      id: -4179431563294133131,
      name: r'programExercise',
      target: r'ProgramExercise',
      single: true,
    ),
    r'exercise': LinkSchema(
      id: 575355559181481368,
      name: r'exercise',
      target: r'Exercise',
      single: true,
    ),
  },
  embeddedSchemas: {},

  getId: _userCompletedExerciseGetId,
  getLinks: _userCompletedExerciseGetLinks,
  attach: _userCompletedExerciseAttach,
  version: '3.3.0',
);

int _userCompletedExerciseEstimateSize(
  UserCompletedExercise object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _userCompletedExerciseSerialize(
  UserCompletedExercise object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.completedProgramId);
  writer.writeLong(offsets[1], object.duration);
  writer.writeLong(offsets[2], object.exerciseId);
  writer.writeBool(offsets[3], object.isLocalOnly);
  writer.writeBool(offsets[4], object.pendingDelete);
  writer.writeLong(offsets[5], object.programExerciseId);
  writer.writeLong(offsets[6], object.reps);
  writer.writeLong(offsets[7], object.restDuration);
  writer.writeLong(offsets[8], object.sets);
  writer.writeBool(offsets[9], object.synced);
  writer.writeLong(offsets[10], object.weight);
}

UserCompletedExercise _userCompletedExerciseDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserCompletedExercise(
    completedProgramId: reader.readLong(offsets[0]),
    duration: reader.readLongOrNull(offsets[1]),
    exerciseId: reader.readLongOrNull(offsets[2]),
    id: id,
    isLocalOnly: reader.readBoolOrNull(offsets[3]) ?? false,
    pendingDelete: reader.readBoolOrNull(offsets[4]) ?? false,
    programExerciseId: reader.readLongOrNull(offsets[5]),
    reps: reader.readLongOrNull(offsets[6]),
    restDuration: reader.readLongOrNull(offsets[7]),
    sets: reader.readLong(offsets[8]),
    synced: reader.readBoolOrNull(offsets[9]) ?? true,
    weight: reader.readLongOrNull(offsets[10]),
  );
  return object;
}

P _userCompletedExerciseDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userCompletedExerciseGetId(UserCompletedExercise object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userCompletedExerciseGetLinks(
  UserCompletedExercise object,
) {
  return [object.programExercise, object.exercise];
}

void _userCompletedExerciseAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserCompletedExercise object,
) {
  object.id = id;
  object.programExercise.attach(
    col,
    col.isar.collection<ProgramExercise>(),
    r'programExercise',
    id,
  );
  object.exercise.attach(col, col.isar.collection<Exercise>(), r'exercise', id);
}

extension UserCompletedExerciseQueryWhereSort
    on QueryBuilder<UserCompletedExercise, UserCompletedExercise, QWhere> {
  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserCompletedExerciseQueryWhere
    on
        QueryBuilder<
          UserCompletedExercise,
          UserCompletedExercise,
          QWhereClause
        > {
  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserCompletedExerciseQueryFilter
    on
        QueryBuilder<
          UserCompletedExercise,
          UserCompletedExercise,
          QFilterCondition
        > {
  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  completedProgramIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedProgramId', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  completedProgramIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedProgramId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  completedProgramIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedProgramId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  completedProgramIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedProgramId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'duration'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'duration'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  durationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'duration', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  durationGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'duration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  durationLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'duration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'duration',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  exerciseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'exerciseId'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  exerciseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'exerciseId'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  exerciseIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'exerciseId', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  exerciseIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'exerciseId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  exerciseIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'exerciseId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  exerciseIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'exerciseId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  isLocalOnlyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isLocalOnly', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  pendingDeleteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pendingDelete', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  programExerciseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'programExerciseId'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  programExerciseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'programExerciseId'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  programExerciseIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'programExerciseId', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  programExerciseIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'programExerciseId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  programExerciseIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'programExerciseId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  programExerciseIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'programExerciseId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  repsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'reps'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  repsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'reps'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  repsEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'reps', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  repsGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'reps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  repsLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'reps',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  repsBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'reps',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  restDurationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'restDuration'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  restDurationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'restDuration'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  restDurationEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'restDuration', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  restDurationGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'restDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  restDurationLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'restDuration',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  restDurationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'restDuration',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  setsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sets', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  setsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sets',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  setsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sets',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  setsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sets',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  weightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'weight'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  weightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'weight'),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  weightEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'weight', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  weightGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'weight',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  weightLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'weight',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  weightBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'weight',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserCompletedExerciseQueryObject
    on
        QueryBuilder<
          UserCompletedExercise,
          UserCompletedExercise,
          QFilterCondition
        > {}

extension UserCompletedExerciseQueryLinks
    on
        QueryBuilder<
          UserCompletedExercise,
          UserCompletedExercise,
          QFilterCondition
        > {
  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  programExercise(FilterQuery<ProgramExercise> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'programExercise');
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  programExerciseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'programExercise', 0, true, 0, true);
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  exercise(FilterQuery<Exercise> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'exercise');
    });
  }

  QueryBuilder<
    UserCompletedExercise,
    UserCompletedExercise,
    QAfterFilterCondition
  >
  exerciseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'exercise', 0, true, 0, true);
    });
  }
}

extension UserCompletedExerciseQuerySortBy
    on QueryBuilder<UserCompletedExercise, UserCompletedExercise, QSortBy> {
  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByCompletedProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedProgramId', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByCompletedProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedProgramId', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByIsLocalOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByPendingDeleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByProgramExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programExerciseId', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByProgramExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programExerciseId', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByRestDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByRestDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortBySets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortBySetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension UserCompletedExerciseQuerySortThenBy
    on QueryBuilder<UserCompletedExercise, UserCompletedExercise, QSortThenBy> {
  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByCompletedProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedProgramId', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByCompletedProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedProgramId', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'exerciseId', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByIsLocalOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByPendingDeleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByProgramExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programExerciseId', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByProgramExerciseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programExerciseId', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByRepsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reps', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByRestDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByRestDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'restDuration', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenBySets() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenBySetsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sets', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QAfterSortBy>
  thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }
}

extension UserCompletedExerciseQueryWhereDistinct
    on QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct> {
  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct>
  distinctByCompletedProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedProgramId');
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct>
  distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct>
  distinctByExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'exerciseId');
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct>
  distinctByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLocalOnly');
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct>
  distinctByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingDelete');
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct>
  distinctByProgramExerciseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'programExerciseId');
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct>
  distinctByReps() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reps');
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct>
  distinctByRestDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'restDuration');
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct>
  distinctBySets() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sets');
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct>
  distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<UserCompletedExercise, UserCompletedExercise, QDistinct>
  distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }
}

extension UserCompletedExerciseQueryProperty
    on
        QueryBuilder<
          UserCompletedExercise,
          UserCompletedExercise,
          QQueryProperty
        > {
  QueryBuilder<UserCompletedExercise, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserCompletedExercise, int, QQueryOperations>
  completedProgramIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedProgramId');
    });
  }

  QueryBuilder<UserCompletedExercise, int?, QQueryOperations>
  durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<UserCompletedExercise, int?, QQueryOperations>
  exerciseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'exerciseId');
    });
  }

  QueryBuilder<UserCompletedExercise, bool, QQueryOperations>
  isLocalOnlyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLocalOnly');
    });
  }

  QueryBuilder<UserCompletedExercise, bool, QQueryOperations>
  pendingDeleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingDelete');
    });
  }

  QueryBuilder<UserCompletedExercise, int?, QQueryOperations>
  programExerciseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'programExerciseId');
    });
  }

  QueryBuilder<UserCompletedExercise, int?, QQueryOperations> repsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reps');
    });
  }

  QueryBuilder<UserCompletedExercise, int?, QQueryOperations>
  restDurationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'restDuration');
    });
  }

  QueryBuilder<UserCompletedExercise, int, QQueryOperations> setsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sets');
    });
  }

  QueryBuilder<UserCompletedExercise, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<UserCompletedExercise, int?, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }
}
