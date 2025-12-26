// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserCompletedProgramCollection on Isar {
  IsarCollection<UserCompletedProgram> get userCompletedPrograms =>
      this.collection();
}

const UserCompletedProgramSchema = CollectionSchema(
  name: r'UserCompletedProgram',
  id: -6002548314264256969,
  properties: {
    r'endDate': PropertySchema(id: 0, name: r'endDate', type: IsarType.string),
    r'isLocalOnly': PropertySchema(
      id: 1,
      name: r'isLocalOnly',
      type: IsarType.bool,
    ),
    r'pendingDelete': PropertySchema(
      id: 2,
      name: r'pendingDelete',
      type: IsarType.bool,
    ),
    r'programId': PropertySchema(
      id: 3,
      name: r'programId',
      type: IsarType.long,
    ),
    r'startDate': PropertySchema(
      id: 4,
      name: r'startDate',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 5, name: r'synced', type: IsarType.bool),
    r'userId': PropertySchema(id: 6, name: r'userId', type: IsarType.long),
  },

  estimateSize: _userCompletedProgramEstimateSize,
  serialize: _userCompletedProgramSerialize,
  deserialize: _userCompletedProgramDeserialize,
  deserializeProp: _userCompletedProgramDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'program': LinkSchema(
      id: -845520894939685582,
      name: r'program',
      target: r'ExerciseProgram',
      single: true,
    ),
    r'completedExercises': LinkSchema(
      id: 1296070052520119910,
      name: r'completedExercises',
      target: r'UserCompletedExercise',
      single: false,
    ),
  },
  embeddedSchemas: {},

  getId: _userCompletedProgramGetId,
  getLinks: _userCompletedProgramGetLinks,
  attach: _userCompletedProgramAttach,
  version: '3.3.0',
);

int _userCompletedProgramEstimateSize(
  UserCompletedProgram object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.endDate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.startDate.length * 3;
  return bytesCount;
}

void _userCompletedProgramSerialize(
  UserCompletedProgram object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.endDate);
  writer.writeBool(offsets[1], object.isLocalOnly);
  writer.writeBool(offsets[2], object.pendingDelete);
  writer.writeLong(offsets[3], object.programId);
  writer.writeString(offsets[4], object.startDate);
  writer.writeBool(offsets[5], object.synced);
  writer.writeLong(offsets[6], object.userId);
}

UserCompletedProgram _userCompletedProgramDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserCompletedProgram(
    endDate: reader.readStringOrNull(offsets[0]),
    id: id,
    isLocalOnly: reader.readBoolOrNull(offsets[1]) ?? false,
    pendingDelete: reader.readBoolOrNull(offsets[2]) ?? false,
    programId: reader.readLong(offsets[3]),
    startDate: reader.readString(offsets[4]),
    synced: reader.readBoolOrNull(offsets[5]) ?? true,
    userId: reader.readLong(offsets[6]),
  );
  return object;
}

P _userCompletedProgramDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userCompletedProgramGetId(UserCompletedProgram object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userCompletedProgramGetLinks(
  UserCompletedProgram object,
) {
  return [object.program, object.completedExercises];
}

void _userCompletedProgramAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserCompletedProgram object,
) {
  object.id = id;
  object.program.attach(
    col,
    col.isar.collection<ExerciseProgram>(),
    r'program',
    id,
  );
  object.completedExercises.attach(
    col,
    col.isar.collection<UserCompletedExercise>(),
    r'completedExercises',
    id,
  );
}

extension UserCompletedProgramQueryWhereSort
    on QueryBuilder<UserCompletedProgram, UserCompletedProgram, QWhere> {
  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserCompletedProgramQueryWhere
    on QueryBuilder<UserCompletedProgram, UserCompletedProgram, QWhereClause> {
  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterWhereClause>
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

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterWhereClause>
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

extension UserCompletedProgramQueryFilter
    on
        QueryBuilder<
          UserCompletedProgram,
          UserCompletedProgram,
          QFilterCondition
        > {
  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'endDate'),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'endDate'),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'endDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'endDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'endDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'endDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'endDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'endDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'endDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'endDate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endDate', value: ''),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  endDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'endDate', value: ''),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
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
    UserCompletedProgram,
    UserCompletedProgram,
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
    UserCompletedProgram,
    UserCompletedProgram,
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
    UserCompletedProgram,
    UserCompletedProgram,
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
    UserCompletedProgram,
    UserCompletedProgram,
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
    UserCompletedProgram,
    UserCompletedProgram,
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
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  programIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'programId', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  programIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'programId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  programIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'programId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  programIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'programId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  startDateEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'startDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  startDateGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'startDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  startDateLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'startDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  startDateBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'startDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  startDateStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'startDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  startDateEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'startDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  startDateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'startDate',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  startDateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'startDate',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  startDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startDate', value: ''),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  startDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'startDate', value: ''),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
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
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  userIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: value),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  userIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'userId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  userIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'userId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  userIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'userId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserCompletedProgramQueryObject
    on
        QueryBuilder<
          UserCompletedProgram,
          UserCompletedProgram,
          QFilterCondition
        > {}

extension UserCompletedProgramQueryLinks
    on
        QueryBuilder<
          UserCompletedProgram,
          UserCompletedProgram,
          QFilterCondition
        > {
  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  program(FilterQuery<ExerciseProgram> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'program');
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  programIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'program', 0, true, 0, true);
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  completedExercises(FilterQuery<UserCompletedExercise> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'completedExercises');
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  completedExercisesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'completedExercises',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  completedExercisesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'completedExercises', 0, true, 0, true);
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  completedExercisesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'completedExercises', 0, false, 999999, true);
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  completedExercisesLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'completedExercises', 0, true, length, include);
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  completedExercisesLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'completedExercises',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<
    UserCompletedProgram,
    UserCompletedProgram,
    QAfterFilterCondition
  >
  completedExercisesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'completedExercises',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension UserCompletedProgramQuerySortBy
    on QueryBuilder<UserCompletedProgram, UserCompletedProgram, QSortBy> {
  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByIsLocalOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByPendingDeleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserCompletedProgramQuerySortThenBy
    on QueryBuilder<UserCompletedProgram, UserCompletedProgram, QSortThenBy> {
  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByIsLocalOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByPendingDeleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByProgramIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'programId', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QAfterSortBy>
  thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserCompletedProgramQueryWhereDistinct
    on QueryBuilder<UserCompletedProgram, UserCompletedProgram, QDistinct> {
  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QDistinct>
  distinctByEndDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QDistinct>
  distinctByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLocalOnly');
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QDistinct>
  distinctByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingDelete');
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QDistinct>
  distinctByProgramId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'programId');
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QDistinct>
  distinctByStartDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QDistinct>
  distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<UserCompletedProgram, UserCompletedProgram, QDistinct>
  distinctByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId');
    });
  }
}

extension UserCompletedProgramQueryProperty
    on
        QueryBuilder<
          UserCompletedProgram,
          UserCompletedProgram,
          QQueryProperty
        > {
  QueryBuilder<UserCompletedProgram, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserCompletedProgram, String?, QQueryOperations>
  endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<UserCompletedProgram, bool, QQueryOperations>
  isLocalOnlyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLocalOnly');
    });
  }

  QueryBuilder<UserCompletedProgram, bool, QQueryOperations>
  pendingDeleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingDelete');
    });
  }

  QueryBuilder<UserCompletedProgram, int, QQueryOperations>
  programIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'programId');
    });
  }

  QueryBuilder<UserCompletedProgram, String, QQueryOperations>
  startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<UserCompletedProgram, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<UserCompletedProgram, int, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
