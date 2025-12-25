// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserSubscriptionCollection on Isar {
  IsarCollection<UserSubscription> get userSubscriptions => this.collection();
}

const UserSubscriptionSchema = CollectionSchema(
  name: r'UserSubscription',
  id: 950687617358749933,
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
    r'startDate': PropertySchema(
      id: 3,
      name: r'startDate',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 4, name: r'synced', type: IsarType.bool),
    r'userId': PropertySchema(id: 5, name: r'userId', type: IsarType.long),
  },

  estimateSize: _userSubscriptionEstimateSize,
  serialize: _userSubscriptionSerialize,
  deserialize: _userSubscriptionDeserialize,
  deserializeProp: _userSubscriptionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'subscription': LinkSchema(
      id: 6207977264677583940,
      name: r'subscription',
      target: r'Subscription',
      single: true,
    ),
  },
  embeddedSchemas: {},

  getId: _userSubscriptionGetId,
  getLinks: _userSubscriptionGetLinks,
  attach: _userSubscriptionAttach,
  version: '3.3.0',
);

int _userSubscriptionEstimateSize(
  UserSubscription object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.endDate.length * 3;
  bytesCount += 3 + object.startDate.length * 3;
  return bytesCount;
}

void _userSubscriptionSerialize(
  UserSubscription object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.endDate);
  writer.writeBool(offsets[1], object.isLocalOnly);
  writer.writeBool(offsets[2], object.pendingDelete);
  writer.writeString(offsets[3], object.startDate);
  writer.writeBool(offsets[4], object.synced);
  writer.writeLong(offsets[5], object.userId);
}

UserSubscription _userSubscriptionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserSubscription(
    endDate: reader.readString(offsets[0]),
    id: id,
    isLocalOnly: reader.readBoolOrNull(offsets[1]) ?? false,
    pendingDelete: reader.readBoolOrNull(offsets[2]) ?? false,
    startDate: reader.readString(offsets[3]),
    synced: reader.readBoolOrNull(offsets[4]) ?? true,
    userId: reader.readLong(offsets[5]),
  );
  return object;
}

P _userSubscriptionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userSubscriptionGetId(UserSubscription object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userSubscriptionGetLinks(UserSubscription object) {
  return [object.subscription];
}

void _userSubscriptionAttach(
  IsarCollection<dynamic> col,
  Id id,
  UserSubscription object,
) {
  object.id = id;
  object.subscription.attach(
    col,
    col.isar.collection<Subscription>(),
    r'subscription',
    id,
  );
}

extension UserSubscriptionQueryWhereSort
    on QueryBuilder<UserSubscription, UserSubscription, QWhere> {
  QueryBuilder<UserSubscription, UserSubscription, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserSubscriptionQueryWhere
    on QueryBuilder<UserSubscription, UserSubscription, QWhereClause> {
  QueryBuilder<UserSubscription, UserSubscription, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterWhereClause>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterWhereClause> idBetween(
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

extension UserSubscriptionQueryFilter
    on QueryBuilder<UserSubscription, UserSubscription, QFilterCondition> {
  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  endDateEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  endDateGreaterThan(
    String value, {
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  endDateLessThan(
    String value, {
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  endDateBetween(
    String lower,
    String upper, {
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  endDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'endDate', value: ''),
      );
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  endDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'endDate', value: ''),
      );
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  isLocalOnlyEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isLocalOnly', value: value),
      );
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  pendingDeleteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'pendingDelete', value: value),
      );
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  startDateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'startDate', value: ''),
      );
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  startDateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'startDate', value: ''),
      );
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  userIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'userId', value: value),
      );
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
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

extension UserSubscriptionQueryObject
    on QueryBuilder<UserSubscription, UserSubscription, QFilterCondition> {}

extension UserSubscriptionQueryLinks
    on QueryBuilder<UserSubscription, UserSubscription, QFilterCondition> {
  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  subscription(FilterQuery<Subscription> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'subscription');
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterFilterCondition>
  subscriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'subscription', 0, true, 0, true);
    });
  }
}

extension UserSubscriptionQuerySortBy
    on QueryBuilder<UserSubscription, UserSubscription, QSortBy> {
  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortByIsLocalOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.desc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortByPendingDeleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.desc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  sortByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserSubscriptionQuerySortThenBy
    on QueryBuilder<UserSubscription, UserSubscription, QSortThenBy> {
  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenByIsLocalOnlyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isLocalOnly', Sort.desc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenByPendingDeleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pendingDelete', Sort.desc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.asc);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QAfterSortBy>
  thenByUserIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userId', Sort.desc);
    });
  }
}

extension UserSubscriptionQueryWhereDistinct
    on QueryBuilder<UserSubscription, UserSubscription, QDistinct> {
  QueryBuilder<UserSubscription, UserSubscription, QDistinct>
  distinctByEndDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QDistinct>
  distinctByIsLocalOnly() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isLocalOnly');
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QDistinct>
  distinctByPendingDelete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pendingDelete');
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QDistinct>
  distinctByStartDate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QDistinct>
  distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<UserSubscription, UserSubscription, QDistinct>
  distinctByUserId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userId');
    });
  }
}

extension UserSubscriptionQueryProperty
    on QueryBuilder<UserSubscription, UserSubscription, QQueryProperty> {
  QueryBuilder<UserSubscription, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserSubscription, String, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<UserSubscription, bool, QQueryOperations> isLocalOnlyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isLocalOnly');
    });
  }

  QueryBuilder<UserSubscription, bool, QQueryOperations>
  pendingDeleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pendingDelete');
    });
  }

  QueryBuilder<UserSubscription, String, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }

  QueryBuilder<UserSubscription, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<UserSubscription, int, QQueryOperations> userIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userId');
    });
  }
}
