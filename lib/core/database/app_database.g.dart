// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LendersTable extends Lenders with TableInfo<$LendersTable, LenderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LendersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('card'),
  );
  static const VerificationMeta _issuerMeta = const VerificationMeta('issuer');
  @override
  late final GeneratedColumn<String> issuer = GeneratedColumn<String>(
    'issuer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _networkMeta = const VerificationMeta(
    'network',
  );
  @override
  late final GeneratedColumn<String> network = GeneratedColumn<String>(
    'network',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typicalRatePctMeta = const VerificationMeta(
    'typicalRatePct',
  );
  @override
  late final GeneratedColumn<double> typicalRatePct = GeneratedColumn<double>(
    'typical_rate_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rateTypeMeta = const VerificationMeta(
    'rateType',
  );
  @override
  late final GeneratedColumn<String> rateType = GeneratedColumn<String>(
    'rate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('reducing'),
  );
  static const VerificationMeta _feeTypeMeta = const VerificationMeta(
    'feeType',
  );
  @override
  late final GeneratedColumn<String> feeType = GeneratedColumn<String>(
    'fee_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('flat'),
  );
  static const VerificationMeta _feeValueMeta = const VerificationMeta(
    'feeValue',
  );
  @override
  late final GeneratedColumn<double> feeValue = GeneratedColumn<double>(
    'fee_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isMineMeta = const VerificationMeta('isMine');
  @override
  late final GeneratedColumn<bool> isMine = GeneratedColumn<bool>(
    'is_mine',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mine" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    issuer,
    network,
    typicalRatePct,
    rateType,
    feeType,
    feeValue,
    isMine,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lenders';
  @override
  VerificationContext validateIntegrity(
    Insertable<LenderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('issuer')) {
      context.handle(
        _issuerMeta,
        issuer.isAcceptableOrUnknown(data['issuer']!, _issuerMeta),
      );
    }
    if (data.containsKey('network')) {
      context.handle(
        _networkMeta,
        network.isAcceptableOrUnknown(data['network']!, _networkMeta),
      );
    }
    if (data.containsKey('typical_rate_pct')) {
      context.handle(
        _typicalRatePctMeta,
        typicalRatePct.isAcceptableOrUnknown(
          data['typical_rate_pct']!,
          _typicalRatePctMeta,
        ),
      );
    }
    if (data.containsKey('rate_type')) {
      context.handle(
        _rateTypeMeta,
        rateType.isAcceptableOrUnknown(data['rate_type']!, _rateTypeMeta),
      );
    }
    if (data.containsKey('fee_type')) {
      context.handle(
        _feeTypeMeta,
        feeType.isAcceptableOrUnknown(data['fee_type']!, _feeTypeMeta),
      );
    }
    if (data.containsKey('fee_value')) {
      context.handle(
        _feeValueMeta,
        feeValue.isAcceptableOrUnknown(data['fee_value']!, _feeValueMeta),
      );
    }
    if (data.containsKey('is_mine')) {
      context.handle(
        _isMineMeta,
        isMine.isAcceptableOrUnknown(data['is_mine']!, _isMineMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LenderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LenderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      issuer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issuer'],
      ),
      network: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}network'],
      ),
      typicalRatePct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}typical_rate_pct'],
      )!,
      rateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_type'],
      )!,
      feeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fee_type'],
      )!,
      feeValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fee_value'],
      )!,
      isMine: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mine'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $LendersTable createAlias(String alias) {
    return $LendersTable(attachedDatabase, alias);
  }
}

class LenderRow extends DataClass implements Insertable<LenderRow> {
  final String id;
  final String name;
  final String type;
  final String? issuer;
  final String? network;
  final double typicalRatePct;
  final String rateType;
  final String feeType;
  final double feeValue;
  final bool isMine;
  final String? notes;
  const LenderRow({
    required this.id,
    required this.name,
    required this.type,
    this.issuer,
    this.network,
    required this.typicalRatePct,
    required this.rateType,
    required this.feeType,
    required this.feeValue,
    required this.isMine,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || issuer != null) {
      map['issuer'] = Variable<String>(issuer);
    }
    if (!nullToAbsent || network != null) {
      map['network'] = Variable<String>(network);
    }
    map['typical_rate_pct'] = Variable<double>(typicalRatePct);
    map['rate_type'] = Variable<String>(rateType);
    map['fee_type'] = Variable<String>(feeType);
    map['fee_value'] = Variable<double>(feeValue);
    map['is_mine'] = Variable<bool>(isMine);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LendersCompanion toCompanion(bool nullToAbsent) {
    return LendersCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      issuer: issuer == null && nullToAbsent
          ? const Value.absent()
          : Value(issuer),
      network: network == null && nullToAbsent
          ? const Value.absent()
          : Value(network),
      typicalRatePct: Value(typicalRatePct),
      rateType: Value(rateType),
      feeType: Value(feeType),
      feeValue: Value(feeValue),
      isMine: Value(isMine),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory LenderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LenderRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      issuer: serializer.fromJson<String?>(json['issuer']),
      network: serializer.fromJson<String?>(json['network']),
      typicalRatePct: serializer.fromJson<double>(json['typicalRatePct']),
      rateType: serializer.fromJson<String>(json['rateType']),
      feeType: serializer.fromJson<String>(json['feeType']),
      feeValue: serializer.fromJson<double>(json['feeValue']),
      isMine: serializer.fromJson<bool>(json['isMine']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'issuer': serializer.toJson<String?>(issuer),
      'network': serializer.toJson<String?>(network),
      'typicalRatePct': serializer.toJson<double>(typicalRatePct),
      'rateType': serializer.toJson<String>(rateType),
      'feeType': serializer.toJson<String>(feeType),
      'feeValue': serializer.toJson<double>(feeValue),
      'isMine': serializer.toJson<bool>(isMine),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LenderRow copyWith({
    String? id,
    String? name,
    String? type,
    Value<String?> issuer = const Value.absent(),
    Value<String?> network = const Value.absent(),
    double? typicalRatePct,
    String? rateType,
    String? feeType,
    double? feeValue,
    bool? isMine,
    Value<String?> notes = const Value.absent(),
  }) => LenderRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    issuer: issuer.present ? issuer.value : this.issuer,
    network: network.present ? network.value : this.network,
    typicalRatePct: typicalRatePct ?? this.typicalRatePct,
    rateType: rateType ?? this.rateType,
    feeType: feeType ?? this.feeType,
    feeValue: feeValue ?? this.feeValue,
    isMine: isMine ?? this.isMine,
    notes: notes.present ? notes.value : this.notes,
  );
  LenderRow copyWithCompanion(LendersCompanion data) {
    return LenderRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      issuer: data.issuer.present ? data.issuer.value : this.issuer,
      network: data.network.present ? data.network.value : this.network,
      typicalRatePct: data.typicalRatePct.present
          ? data.typicalRatePct.value
          : this.typicalRatePct,
      rateType: data.rateType.present ? data.rateType.value : this.rateType,
      feeType: data.feeType.present ? data.feeType.value : this.feeType,
      feeValue: data.feeValue.present ? data.feeValue.value : this.feeValue,
      isMine: data.isMine.present ? data.isMine.value : this.isMine,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LenderRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('issuer: $issuer, ')
          ..write('network: $network, ')
          ..write('typicalRatePct: $typicalRatePct, ')
          ..write('rateType: $rateType, ')
          ..write('feeType: $feeType, ')
          ..write('feeValue: $feeValue, ')
          ..write('isMine: $isMine, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    issuer,
    network,
    typicalRatePct,
    rateType,
    feeType,
    feeValue,
    isMine,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LenderRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.issuer == this.issuer &&
          other.network == this.network &&
          other.typicalRatePct == this.typicalRatePct &&
          other.rateType == this.rateType &&
          other.feeType == this.feeType &&
          other.feeValue == this.feeValue &&
          other.isMine == this.isMine &&
          other.notes == this.notes);
}

class LendersCompanion extends UpdateCompanion<LenderRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> issuer;
  final Value<String?> network;
  final Value<double> typicalRatePct;
  final Value<String> rateType;
  final Value<String> feeType;
  final Value<double> feeValue;
  final Value<bool> isMine;
  final Value<String?> notes;
  final Value<int> rowid;
  const LendersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.issuer = const Value.absent(),
    this.network = const Value.absent(),
    this.typicalRatePct = const Value.absent(),
    this.rateType = const Value.absent(),
    this.feeType = const Value.absent(),
    this.feeValue = const Value.absent(),
    this.isMine = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LendersCompanion.insert({
    required String id,
    required String name,
    this.type = const Value.absent(),
    this.issuer = const Value.absent(),
    this.network = const Value.absent(),
    this.typicalRatePct = const Value.absent(),
    this.rateType = const Value.absent(),
    this.feeType = const Value.absent(),
    this.feeValue = const Value.absent(),
    this.isMine = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<LenderRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? issuer,
    Expression<String>? network,
    Expression<double>? typicalRatePct,
    Expression<String>? rateType,
    Expression<String>? feeType,
    Expression<double>? feeValue,
    Expression<bool>? isMine,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (issuer != null) 'issuer': issuer,
      if (network != null) 'network': network,
      if (typicalRatePct != null) 'typical_rate_pct': typicalRatePct,
      if (rateType != null) 'rate_type': rateType,
      if (feeType != null) 'fee_type': feeType,
      if (feeValue != null) 'fee_value': feeValue,
      if (isMine != null) 'is_mine': isMine,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LendersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? issuer,
    Value<String?>? network,
    Value<double>? typicalRatePct,
    Value<String>? rateType,
    Value<String>? feeType,
    Value<double>? feeValue,
    Value<bool>? isMine,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return LendersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      issuer: issuer ?? this.issuer,
      network: network ?? this.network,
      typicalRatePct: typicalRatePct ?? this.typicalRatePct,
      rateType: rateType ?? this.rateType,
      feeType: feeType ?? this.feeType,
      feeValue: feeValue ?? this.feeValue,
      isMine: isMine ?? this.isMine,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (issuer.present) {
      map['issuer'] = Variable<String>(issuer.value);
    }
    if (network.present) {
      map['network'] = Variable<String>(network.value);
    }
    if (typicalRatePct.present) {
      map['typical_rate_pct'] = Variable<double>(typicalRatePct.value);
    }
    if (rateType.present) {
      map['rate_type'] = Variable<String>(rateType.value);
    }
    if (feeType.present) {
      map['fee_type'] = Variable<String>(feeType.value);
    }
    if (feeValue.present) {
      map['fee_value'] = Variable<double>(feeValue.value);
    }
    if (isMine.present) {
      map['is_mine'] = Variable<bool>(isMine.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LendersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('issuer: $issuer, ')
          ..write('network: $network, ')
          ..write('typicalRatePct: $typicalRatePct, ')
          ..write('rateType: $rateType, ')
          ..write('feeType: $feeType, ')
          ..write('feeValue: $feeValue, ')
          ..write('isMine: $isMine, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BorrowingsTable extends Borrowings
    with TableInfo<$BorrowingsTable, BorrowingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BorrowingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lenderIdMeta = const VerificationMeta(
    'lenderId',
  );
  @override
  late final GeneratedColumn<String> lenderId = GeneratedColumn<String>(
    'lender_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lenderNameMeta = const VerificationMeta(
    'lenderName',
  );
  @override
  late final GeneratedColumn<String> lenderName = GeneratedColumn<String>(
    'lender_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _principalMeta = const VerificationMeta(
    'principal',
  );
  @override
  late final GeneratedColumn<double> principal = GeneratedColumn<double>(
    'principal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _processingFeeMeta = const VerificationMeta(
    'processingFee',
  );
  @override
  late final GeneratedColumn<double> processingFee = GeneratedColumn<double>(
    'processing_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gstOnFeeMeta = const VerificationMeta(
    'gstOnFee',
  );
  @override
  late final GeneratedColumn<double> gstOnFee = GeneratedColumn<double>(
    'gst_on_fee',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _interestRatePctMeta = const VerificationMeta(
    'interestRatePct',
  );
  @override
  late final GeneratedColumn<double> interestRatePct = GeneratedColumn<double>(
    'interest_rate_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rateTypeMeta = const VerificationMeta(
    'rateType',
  );
  @override
  late final GeneratedColumn<String> rateType = GeneratedColumn<String>(
    'rate_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('reducing'),
  );
  static const VerificationMeta _tenureMonthsMeta = const VerificationMeta(
    'tenureMonths',
  );
  @override
  late final GeneratedColumn<int> tenureMonths = GeneratedColumn<int>(
    'tenure_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    lenderId,
    lenderName,
    principal,
    processingFee,
    gstOnFee,
    interestRatePct,
    rateType,
    tenureMonths,
    startDate,
    status,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'borrowings';
  @override
  VerificationContext validateIntegrity(
    Insertable<BorrowingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('lender_id')) {
      context.handle(
        _lenderIdMeta,
        lenderId.isAcceptableOrUnknown(data['lender_id']!, _lenderIdMeta),
      );
    }
    if (data.containsKey('lender_name')) {
      context.handle(
        _lenderNameMeta,
        lenderName.isAcceptableOrUnknown(data['lender_name']!, _lenderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lenderNameMeta);
    }
    if (data.containsKey('principal')) {
      context.handle(
        _principalMeta,
        principal.isAcceptableOrUnknown(data['principal']!, _principalMeta),
      );
    } else if (isInserting) {
      context.missing(_principalMeta);
    }
    if (data.containsKey('processing_fee')) {
      context.handle(
        _processingFeeMeta,
        processingFee.isAcceptableOrUnknown(
          data['processing_fee']!,
          _processingFeeMeta,
        ),
      );
    }
    if (data.containsKey('gst_on_fee')) {
      context.handle(
        _gstOnFeeMeta,
        gstOnFee.isAcceptableOrUnknown(data['gst_on_fee']!, _gstOnFeeMeta),
      );
    }
    if (data.containsKey('interest_rate_pct')) {
      context.handle(
        _interestRatePctMeta,
        interestRatePct.isAcceptableOrUnknown(
          data['interest_rate_pct']!,
          _interestRatePctMeta,
        ),
      );
    }
    if (data.containsKey('rate_type')) {
      context.handle(
        _rateTypeMeta,
        rateType.isAcceptableOrUnknown(data['rate_type']!, _rateTypeMeta),
      );
    }
    if (data.containsKey('tenure_months')) {
      context.handle(
        _tenureMonthsMeta,
        tenureMonths.isAcceptableOrUnknown(
          data['tenure_months']!,
          _tenureMonthsMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BorrowingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BorrowingRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      lenderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lender_id'],
      ),
      lenderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lender_name'],
      )!,
      principal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}principal'],
      )!,
      processingFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}processing_fee'],
      )!,
      gstOnFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_on_fee'],
      )!,
      interestRatePct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interest_rate_pct'],
      )!,
      rateType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rate_type'],
      )!,
      tenureMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tenure_months'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BorrowingsTable createAlias(String alias) {
    return $BorrowingsTable(attachedDatabase, alias);
  }
}

class BorrowingRow extends DataClass implements Insertable<BorrowingRow> {
  final String id;
  final String title;
  final String? lenderId;
  final String lenderName;
  final double principal;
  final double processingFee;
  final double gstOnFee;
  final double interestRatePct;
  final String rateType;
  final int tenureMonths;
  final DateTime startDate;
  final String status;
  final String? notes;
  final DateTime createdAt;
  const BorrowingRow({
    required this.id,
    required this.title,
    this.lenderId,
    required this.lenderName,
    required this.principal,
    required this.processingFee,
    required this.gstOnFee,
    required this.interestRatePct,
    required this.rateType,
    required this.tenureMonths,
    required this.startDate,
    required this.status,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || lenderId != null) {
      map['lender_id'] = Variable<String>(lenderId);
    }
    map['lender_name'] = Variable<String>(lenderName);
    map['principal'] = Variable<double>(principal);
    map['processing_fee'] = Variable<double>(processingFee);
    map['gst_on_fee'] = Variable<double>(gstOnFee);
    map['interest_rate_pct'] = Variable<double>(interestRatePct);
    map['rate_type'] = Variable<String>(rateType);
    map['tenure_months'] = Variable<int>(tenureMonths);
    map['start_date'] = Variable<DateTime>(startDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BorrowingsCompanion toCompanion(bool nullToAbsent) {
    return BorrowingsCompanion(
      id: Value(id),
      title: Value(title),
      lenderId: lenderId == null && nullToAbsent
          ? const Value.absent()
          : Value(lenderId),
      lenderName: Value(lenderName),
      principal: Value(principal),
      processingFee: Value(processingFee),
      gstOnFee: Value(gstOnFee),
      interestRatePct: Value(interestRatePct),
      rateType: Value(rateType),
      tenureMonths: Value(tenureMonths),
      startDate: Value(startDate),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory BorrowingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BorrowingRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      lenderId: serializer.fromJson<String?>(json['lenderId']),
      lenderName: serializer.fromJson<String>(json['lenderName']),
      principal: serializer.fromJson<double>(json['principal']),
      processingFee: serializer.fromJson<double>(json['processingFee']),
      gstOnFee: serializer.fromJson<double>(json['gstOnFee']),
      interestRatePct: serializer.fromJson<double>(json['interestRatePct']),
      rateType: serializer.fromJson<String>(json['rateType']),
      tenureMonths: serializer.fromJson<int>(json['tenureMonths']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'lenderId': serializer.toJson<String?>(lenderId),
      'lenderName': serializer.toJson<String>(lenderName),
      'principal': serializer.toJson<double>(principal),
      'processingFee': serializer.toJson<double>(processingFee),
      'gstOnFee': serializer.toJson<double>(gstOnFee),
      'interestRatePct': serializer.toJson<double>(interestRatePct),
      'rateType': serializer.toJson<String>(rateType),
      'tenureMonths': serializer.toJson<int>(tenureMonths),
      'startDate': serializer.toJson<DateTime>(startDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BorrowingRow copyWith({
    String? id,
    String? title,
    Value<String?> lenderId = const Value.absent(),
    String? lenderName,
    double? principal,
    double? processingFee,
    double? gstOnFee,
    double? interestRatePct,
    String? rateType,
    int? tenureMonths,
    DateTime? startDate,
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => BorrowingRow(
    id: id ?? this.id,
    title: title ?? this.title,
    lenderId: lenderId.present ? lenderId.value : this.lenderId,
    lenderName: lenderName ?? this.lenderName,
    principal: principal ?? this.principal,
    processingFee: processingFee ?? this.processingFee,
    gstOnFee: gstOnFee ?? this.gstOnFee,
    interestRatePct: interestRatePct ?? this.interestRatePct,
    rateType: rateType ?? this.rateType,
    tenureMonths: tenureMonths ?? this.tenureMonths,
    startDate: startDate ?? this.startDate,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  BorrowingRow copyWithCompanion(BorrowingsCompanion data) {
    return BorrowingRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      lenderId: data.lenderId.present ? data.lenderId.value : this.lenderId,
      lenderName: data.lenderName.present
          ? data.lenderName.value
          : this.lenderName,
      principal: data.principal.present ? data.principal.value : this.principal,
      processingFee: data.processingFee.present
          ? data.processingFee.value
          : this.processingFee,
      gstOnFee: data.gstOnFee.present ? data.gstOnFee.value : this.gstOnFee,
      interestRatePct: data.interestRatePct.present
          ? data.interestRatePct.value
          : this.interestRatePct,
      rateType: data.rateType.present ? data.rateType.value : this.rateType,
      tenureMonths: data.tenureMonths.present
          ? data.tenureMonths.value
          : this.tenureMonths,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BorrowingRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('lenderId: $lenderId, ')
          ..write('lenderName: $lenderName, ')
          ..write('principal: $principal, ')
          ..write('processingFee: $processingFee, ')
          ..write('gstOnFee: $gstOnFee, ')
          ..write('interestRatePct: $interestRatePct, ')
          ..write('rateType: $rateType, ')
          ..write('tenureMonths: $tenureMonths, ')
          ..write('startDate: $startDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    lenderId,
    lenderName,
    principal,
    processingFee,
    gstOnFee,
    interestRatePct,
    rateType,
    tenureMonths,
    startDate,
    status,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BorrowingRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.lenderId == this.lenderId &&
          other.lenderName == this.lenderName &&
          other.principal == this.principal &&
          other.processingFee == this.processingFee &&
          other.gstOnFee == this.gstOnFee &&
          other.interestRatePct == this.interestRatePct &&
          other.rateType == this.rateType &&
          other.tenureMonths == this.tenureMonths &&
          other.startDate == this.startDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class BorrowingsCompanion extends UpdateCompanion<BorrowingRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> lenderId;
  final Value<String> lenderName;
  final Value<double> principal;
  final Value<double> processingFee;
  final Value<double> gstOnFee;
  final Value<double> interestRatePct;
  final Value<String> rateType;
  final Value<int> tenureMonths;
  final Value<DateTime> startDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BorrowingsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.lenderId = const Value.absent(),
    this.lenderName = const Value.absent(),
    this.principal = const Value.absent(),
    this.processingFee = const Value.absent(),
    this.gstOnFee = const Value.absent(),
    this.interestRatePct = const Value.absent(),
    this.rateType = const Value.absent(),
    this.tenureMonths = const Value.absent(),
    this.startDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BorrowingsCompanion.insert({
    required String id,
    required String title,
    this.lenderId = const Value.absent(),
    required String lenderName,
    required double principal,
    this.processingFee = const Value.absent(),
    this.gstOnFee = const Value.absent(),
    this.interestRatePct = const Value.absent(),
    this.rateType = const Value.absent(),
    this.tenureMonths = const Value.absent(),
    required DateTime startDate,
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       lenderName = Value(lenderName),
       principal = Value(principal),
       startDate = Value(startDate),
       createdAt = Value(createdAt);
  static Insertable<BorrowingRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? lenderId,
    Expression<String>? lenderName,
    Expression<double>? principal,
    Expression<double>? processingFee,
    Expression<double>? gstOnFee,
    Expression<double>? interestRatePct,
    Expression<String>? rateType,
    Expression<int>? tenureMonths,
    Expression<DateTime>? startDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (lenderId != null) 'lender_id': lenderId,
      if (lenderName != null) 'lender_name': lenderName,
      if (principal != null) 'principal': principal,
      if (processingFee != null) 'processing_fee': processingFee,
      if (gstOnFee != null) 'gst_on_fee': gstOnFee,
      if (interestRatePct != null) 'interest_rate_pct': interestRatePct,
      if (rateType != null) 'rate_type': rateType,
      if (tenureMonths != null) 'tenure_months': tenureMonths,
      if (startDate != null) 'start_date': startDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BorrowingsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? lenderId,
    Value<String>? lenderName,
    Value<double>? principal,
    Value<double>? processingFee,
    Value<double>? gstOnFee,
    Value<double>? interestRatePct,
    Value<String>? rateType,
    Value<int>? tenureMonths,
    Value<DateTime>? startDate,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BorrowingsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      lenderId: lenderId ?? this.lenderId,
      lenderName: lenderName ?? this.lenderName,
      principal: principal ?? this.principal,
      processingFee: processingFee ?? this.processingFee,
      gstOnFee: gstOnFee ?? this.gstOnFee,
      interestRatePct: interestRatePct ?? this.interestRatePct,
      rateType: rateType ?? this.rateType,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (lenderId.present) {
      map['lender_id'] = Variable<String>(lenderId.value);
    }
    if (lenderName.present) {
      map['lender_name'] = Variable<String>(lenderName.value);
    }
    if (principal.present) {
      map['principal'] = Variable<double>(principal.value);
    }
    if (processingFee.present) {
      map['processing_fee'] = Variable<double>(processingFee.value);
    }
    if (gstOnFee.present) {
      map['gst_on_fee'] = Variable<double>(gstOnFee.value);
    }
    if (interestRatePct.present) {
      map['interest_rate_pct'] = Variable<double>(interestRatePct.value);
    }
    if (rateType.present) {
      map['rate_type'] = Variable<String>(rateType.value);
    }
    if (tenureMonths.present) {
      map['tenure_months'] = Variable<int>(tenureMonths.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BorrowingsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('lenderId: $lenderId, ')
          ..write('lenderName: $lenderName, ')
          ..write('principal: $principal, ')
          ..write('processingFee: $processingFee, ')
          ..write('gstOnFee: $gstOnFee, ')
          ..write('interestRatePct: $interestRatePct, ')
          ..write('rateType: $rateType, ')
          ..write('tenureMonths: $tenureMonths, ')
          ..write('startDate: $startDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RepaymentsTable extends Repayments
    with TableInfo<$RepaymentsTable, RepaymentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _borrowingIdMeta = const VerificationMeta(
    'borrowingId',
  );
  @override
  late final GeneratedColumn<String> borrowingId = GeneratedColumn<String>(
    'borrowing_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES borrowings (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, borrowingId, amount, date, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repayments';
  @override
  VerificationContext validateIntegrity(
    Insertable<RepaymentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('borrowing_id')) {
      context.handle(
        _borrowingIdMeta,
        borrowingId.isAcceptableOrUnknown(
          data['borrowing_id']!,
          _borrowingIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_borrowingIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepaymentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepaymentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      borrowingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}borrowing_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $RepaymentsTable createAlias(String alias) {
    return $RepaymentsTable(attachedDatabase, alias);
  }
}

class RepaymentRow extends DataClass implements Insertable<RepaymentRow> {
  final String id;
  final String borrowingId;
  final double amount;
  final DateTime date;
  final String? note;
  const RepaymentRow({
    required this.id,
    required this.borrowingId,
    required this.amount,
    required this.date,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['borrowing_id'] = Variable<String>(borrowingId);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  RepaymentsCompanion toCompanion(bool nullToAbsent) {
    return RepaymentsCompanion(
      id: Value(id),
      borrowingId: Value(borrowingId),
      amount: Value(amount),
      date: Value(date),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory RepaymentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepaymentRow(
      id: serializer.fromJson<String>(json['id']),
      borrowingId: serializer.fromJson<String>(json['borrowingId']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'borrowingId': serializer.toJson<String>(borrowingId),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String?>(note),
    };
  }

  RepaymentRow copyWith({
    String? id,
    String? borrowingId,
    double? amount,
    DateTime? date,
    Value<String?> note = const Value.absent(),
  }) => RepaymentRow(
    id: id ?? this.id,
    borrowingId: borrowingId ?? this.borrowingId,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    note: note.present ? note.value : this.note,
  );
  RepaymentRow copyWithCompanion(RepaymentsCompanion data) {
    return RepaymentRow(
      id: data.id.present ? data.id.value : this.id,
      borrowingId: data.borrowingId.present
          ? data.borrowingId.value
          : this.borrowingId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepaymentRow(')
          ..write('id: $id, ')
          ..write('borrowingId: $borrowingId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, borrowingId, amount, date, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepaymentRow &&
          other.id == this.id &&
          other.borrowingId == this.borrowingId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.note == this.note);
}

class RepaymentsCompanion extends UpdateCompanion<RepaymentRow> {
  final Value<String> id;
  final Value<String> borrowingId;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String?> note;
  final Value<int> rowid;
  const RepaymentsCompanion({
    this.id = const Value.absent(),
    this.borrowingId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RepaymentsCompanion.insert({
    required String id,
    required String borrowingId,
    required double amount,
    required DateTime date,
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       borrowingId = Value(borrowingId),
       amount = Value(amount),
       date = Value(date);
  static Insertable<RepaymentRow> custom({
    Expression<String>? id,
    Expression<String>? borrowingId,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (borrowingId != null) 'borrowing_id': borrowingId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RepaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? borrowingId,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return RepaymentsCompanion(
      id: id ?? this.id,
      borrowingId: borrowingId ?? this.borrowingId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (borrowingId.present) {
      map['borrowing_id'] = Variable<String>(borrowingId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepaymentsCompanion(')
          ..write('id: $id, ')
          ..write('borrowingId: $borrowingId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LendersTable lenders = $LendersTable(this);
  late final $BorrowingsTable borrowings = $BorrowingsTable(this);
  late final $RepaymentsTable repayments = $RepaymentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lenders,
    borrowings,
    repayments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'borrowings',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('repayments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$LendersTableCreateCompanionBuilder =
    LendersCompanion Function({
      required String id,
      required String name,
      Value<String> type,
      Value<String?> issuer,
      Value<String?> network,
      Value<double> typicalRatePct,
      Value<String> rateType,
      Value<String> feeType,
      Value<double> feeValue,
      Value<bool> isMine,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$LendersTableUpdateCompanionBuilder =
    LendersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> type,
      Value<String?> issuer,
      Value<String?> network,
      Value<double> typicalRatePct,
      Value<String> rateType,
      Value<String> feeType,
      Value<double> feeValue,
      Value<bool> isMine,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$LendersTableFilterComposer
    extends Composer<_$AppDatabase, $LendersTable> {
  $$LendersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get typicalRatePct => $composableBuilder(
    column: $table.typicalRatePct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rateType => $composableBuilder(
    column: $table.rateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feeType => $composableBuilder(
    column: $table.feeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get feeValue => $composableBuilder(
    column: $table.feeValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMine => $composableBuilder(
    column: $table.isMine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LendersTableOrderingComposer
    extends Composer<_$AppDatabase, $LendersTable> {
  $$LendersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get network => $composableBuilder(
    column: $table.network,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get typicalRatePct => $composableBuilder(
    column: $table.typicalRatePct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateType => $composableBuilder(
    column: $table.rateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feeType => $composableBuilder(
    column: $table.feeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get feeValue => $composableBuilder(
    column: $table.feeValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMine => $composableBuilder(
    column: $table.isMine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LendersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LendersTable> {
  $$LendersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get issuer =>
      $composableBuilder(column: $table.issuer, builder: (column) => column);

  GeneratedColumn<String> get network =>
      $composableBuilder(column: $table.network, builder: (column) => column);

  GeneratedColumn<double> get typicalRatePct => $composableBuilder(
    column: $table.typicalRatePct,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rateType =>
      $composableBuilder(column: $table.rateType, builder: (column) => column);

  GeneratedColumn<String> get feeType =>
      $composableBuilder(column: $table.feeType, builder: (column) => column);

  GeneratedColumn<double> get feeValue =>
      $composableBuilder(column: $table.feeValue, builder: (column) => column);

  GeneratedColumn<bool> get isMine =>
      $composableBuilder(column: $table.isMine, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$LendersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LendersTable,
          LenderRow,
          $$LendersTableFilterComposer,
          $$LendersTableOrderingComposer,
          $$LendersTableAnnotationComposer,
          $$LendersTableCreateCompanionBuilder,
          $$LendersTableUpdateCompanionBuilder,
          (LenderRow, BaseReferences<_$AppDatabase, $LendersTable, LenderRow>),
          LenderRow,
          PrefetchHooks Function()
        > {
  $$LendersTableTableManager(_$AppDatabase db, $LendersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LendersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LendersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LendersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> issuer = const Value.absent(),
                Value<String?> network = const Value.absent(),
                Value<double> typicalRatePct = const Value.absent(),
                Value<String> rateType = const Value.absent(),
                Value<String> feeType = const Value.absent(),
                Value<double> feeValue = const Value.absent(),
                Value<bool> isMine = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LendersCompanion(
                id: id,
                name: name,
                type: type,
                issuer: issuer,
                network: network,
                typicalRatePct: typicalRatePct,
                rateType: rateType,
                feeType: feeType,
                feeValue: feeValue,
                isMine: isMine,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> type = const Value.absent(),
                Value<String?> issuer = const Value.absent(),
                Value<String?> network = const Value.absent(),
                Value<double> typicalRatePct = const Value.absent(),
                Value<String> rateType = const Value.absent(),
                Value<String> feeType = const Value.absent(),
                Value<double> feeValue = const Value.absent(),
                Value<bool> isMine = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LendersCompanion.insert(
                id: id,
                name: name,
                type: type,
                issuer: issuer,
                network: network,
                typicalRatePct: typicalRatePct,
                rateType: rateType,
                feeType: feeType,
                feeValue: feeValue,
                isMine: isMine,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LendersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LendersTable,
      LenderRow,
      $$LendersTableFilterComposer,
      $$LendersTableOrderingComposer,
      $$LendersTableAnnotationComposer,
      $$LendersTableCreateCompanionBuilder,
      $$LendersTableUpdateCompanionBuilder,
      (LenderRow, BaseReferences<_$AppDatabase, $LendersTable, LenderRow>),
      LenderRow,
      PrefetchHooks Function()
    >;
typedef $$BorrowingsTableCreateCompanionBuilder =
    BorrowingsCompanion Function({
      required String id,
      required String title,
      Value<String?> lenderId,
      required String lenderName,
      required double principal,
      Value<double> processingFee,
      Value<double> gstOnFee,
      Value<double> interestRatePct,
      Value<String> rateType,
      Value<int> tenureMonths,
      required DateTime startDate,
      Value<String> status,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BorrowingsTableUpdateCompanionBuilder =
    BorrowingsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> lenderId,
      Value<String> lenderName,
      Value<double> principal,
      Value<double> processingFee,
      Value<double> gstOnFee,
      Value<double> interestRatePct,
      Value<String> rateType,
      Value<int> tenureMonths,
      Value<DateTime> startDate,
      Value<String> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$BorrowingsTableReferences
    extends BaseReferences<_$AppDatabase, $BorrowingsTable, BorrowingRow> {
  $$BorrowingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RepaymentsTable, List<RepaymentRow>>
  _repaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.repayments,
    aliasName: 'borrowings__id__repayments__borrowing_id',
  );

  $$RepaymentsTableProcessedTableManager get repaymentsRefs {
    final manager = $$RepaymentsTableTableManager(
      $_db,
      $_db.repayments,
    ).filter((f) => f.borrowingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_repaymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BorrowingsTableFilterComposer
    extends Composer<_$AppDatabase, $BorrowingsTable> {
  $$BorrowingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lenderId => $composableBuilder(
    column: $table.lenderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lenderName => $composableBuilder(
    column: $table.lenderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get principal => $composableBuilder(
    column: $table.principal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get processingFee => $composableBuilder(
    column: $table.processingFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstOnFee => $composableBuilder(
    column: $table.gstOnFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get interestRatePct => $composableBuilder(
    column: $table.interestRatePct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rateType => $composableBuilder(
    column: $table.rateType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tenureMonths => $composableBuilder(
    column: $table.tenureMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> repaymentsRefs(
    Expression<bool> Function($$RepaymentsTableFilterComposer f) f,
  ) {
    final $$RepaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repayments,
      getReferencedColumn: (t) => t.borrowingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepaymentsTableFilterComposer(
            $db: $db,
            $table: $db.repayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BorrowingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BorrowingsTable> {
  $$BorrowingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lenderId => $composableBuilder(
    column: $table.lenderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lenderName => $composableBuilder(
    column: $table.lenderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get principal => $composableBuilder(
    column: $table.principal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get processingFee => $composableBuilder(
    column: $table.processingFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstOnFee => $composableBuilder(
    column: $table.gstOnFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get interestRatePct => $composableBuilder(
    column: $table.interestRatePct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateType => $composableBuilder(
    column: $table.rateType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tenureMonths => $composableBuilder(
    column: $table.tenureMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BorrowingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BorrowingsTable> {
  $$BorrowingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get lenderId =>
      $composableBuilder(column: $table.lenderId, builder: (column) => column);

  GeneratedColumn<String> get lenderName => $composableBuilder(
    column: $table.lenderName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get principal =>
      $composableBuilder(column: $table.principal, builder: (column) => column);

  GeneratedColumn<double> get processingFee => $composableBuilder(
    column: $table.processingFee,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gstOnFee =>
      $composableBuilder(column: $table.gstOnFee, builder: (column) => column);

  GeneratedColumn<double> get interestRatePct => $composableBuilder(
    column: $table.interestRatePct,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rateType =>
      $composableBuilder(column: $table.rateType, builder: (column) => column);

  GeneratedColumn<int> get tenureMonths => $composableBuilder(
    column: $table.tenureMonths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> repaymentsRefs<T extends Object>(
    Expression<T> Function($$RepaymentsTableAnnotationComposer a) f,
  ) {
    final $$RepaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repayments,
      getReferencedColumn: (t) => t.borrowingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.repayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BorrowingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BorrowingsTable,
          BorrowingRow,
          $$BorrowingsTableFilterComposer,
          $$BorrowingsTableOrderingComposer,
          $$BorrowingsTableAnnotationComposer,
          $$BorrowingsTableCreateCompanionBuilder,
          $$BorrowingsTableUpdateCompanionBuilder,
          (BorrowingRow, $$BorrowingsTableReferences),
          BorrowingRow,
          PrefetchHooks Function({bool repaymentsRefs})
        > {
  $$BorrowingsTableTableManager(_$AppDatabase db, $BorrowingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BorrowingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BorrowingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BorrowingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> lenderId = const Value.absent(),
                Value<String> lenderName = const Value.absent(),
                Value<double> principal = const Value.absent(),
                Value<double> processingFee = const Value.absent(),
                Value<double> gstOnFee = const Value.absent(),
                Value<double> interestRatePct = const Value.absent(),
                Value<String> rateType = const Value.absent(),
                Value<int> tenureMonths = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BorrowingsCompanion(
                id: id,
                title: title,
                lenderId: lenderId,
                lenderName: lenderName,
                principal: principal,
                processingFee: processingFee,
                gstOnFee: gstOnFee,
                interestRatePct: interestRatePct,
                rateType: rateType,
                tenureMonths: tenureMonths,
                startDate: startDate,
                status: status,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> lenderId = const Value.absent(),
                required String lenderName,
                required double principal,
                Value<double> processingFee = const Value.absent(),
                Value<double> gstOnFee = const Value.absent(),
                Value<double> interestRatePct = const Value.absent(),
                Value<String> rateType = const Value.absent(),
                Value<int> tenureMonths = const Value.absent(),
                required DateTime startDate,
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BorrowingsCompanion.insert(
                id: id,
                title: title,
                lenderId: lenderId,
                lenderName: lenderName,
                principal: principal,
                processingFee: processingFee,
                gstOnFee: gstOnFee,
                interestRatePct: interestRatePct,
                rateType: rateType,
                tenureMonths: tenureMonths,
                startDate: startDate,
                status: status,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BorrowingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({repaymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (repaymentsRefs) db.repayments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (repaymentsRefs)
                    await $_getPrefetchedData<
                      BorrowingRow,
                      $BorrowingsTable,
                      RepaymentRow
                    >(
                      currentTable: table,
                      referencedTable: $$BorrowingsTableReferences
                          ._repaymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BorrowingsTableReferences(
                            db,
                            table,
                            p0,
                          ).repaymentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.borrowingId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BorrowingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BorrowingsTable,
      BorrowingRow,
      $$BorrowingsTableFilterComposer,
      $$BorrowingsTableOrderingComposer,
      $$BorrowingsTableAnnotationComposer,
      $$BorrowingsTableCreateCompanionBuilder,
      $$BorrowingsTableUpdateCompanionBuilder,
      (BorrowingRow, $$BorrowingsTableReferences),
      BorrowingRow,
      PrefetchHooks Function({bool repaymentsRefs})
    >;
typedef $$RepaymentsTableCreateCompanionBuilder =
    RepaymentsCompanion Function({
      required String id,
      required String borrowingId,
      required double amount,
      required DateTime date,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$RepaymentsTableUpdateCompanionBuilder =
    RepaymentsCompanion Function({
      Value<String> id,
      Value<String> borrowingId,
      Value<double> amount,
      Value<DateTime> date,
      Value<String?> note,
      Value<int> rowid,
    });

final class $$RepaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $RepaymentsTable, RepaymentRow> {
  $$RepaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BorrowingsTable _borrowingIdTable(_$AppDatabase db) =>
      db.borrowings.createAlias('repayments__borrowing_id__borrowings__id');

  $$BorrowingsTableProcessedTableManager get borrowingId {
    final $_column = $_itemColumn<String>('borrowing_id')!;

    final manager = $$BorrowingsTableTableManager(
      $_db,
      $_db.borrowings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_borrowingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RepaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $RepaymentsTable> {
  $$RepaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$BorrowingsTableFilterComposer get borrowingId {
    final $$BorrowingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.borrowingId,
      referencedTable: $db.borrowings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BorrowingsTableFilterComposer(
            $db: $db,
            $table: $db.borrowings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $RepaymentsTable> {
  $$RepaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$BorrowingsTableOrderingComposer get borrowingId {
    final $$BorrowingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.borrowingId,
      referencedTable: $db.borrowings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BorrowingsTableOrderingComposer(
            $db: $db,
            $table: $db.borrowings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepaymentsTable> {
  $$RepaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$BorrowingsTableAnnotationComposer get borrowingId {
    final $$BorrowingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.borrowingId,
      referencedTable: $db.borrowings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BorrowingsTableAnnotationComposer(
            $db: $db,
            $table: $db.borrowings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepaymentsTable,
          RepaymentRow,
          $$RepaymentsTableFilterComposer,
          $$RepaymentsTableOrderingComposer,
          $$RepaymentsTableAnnotationComposer,
          $$RepaymentsTableCreateCompanionBuilder,
          $$RepaymentsTableUpdateCompanionBuilder,
          (RepaymentRow, $$RepaymentsTableReferences),
          RepaymentRow,
          PrefetchHooks Function({bool borrowingId})
        > {
  $$RepaymentsTableTableManager(_$AppDatabase db, $RepaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> borrowingId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepaymentsCompanion(
                id: id,
                borrowingId: borrowingId,
                amount: amount,
                date: date,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String borrowingId,
                required double amount,
                required DateTime date,
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepaymentsCompanion.insert(
                id: id,
                borrowingId: borrowingId,
                amount: amount,
                date: date,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RepaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({borrowingId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (borrowingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.borrowingId,
                                referencedTable: $$RepaymentsTableReferences
                                    ._borrowingIdTable(db),
                                referencedColumn: $$RepaymentsTableReferences
                                    ._borrowingIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RepaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepaymentsTable,
      RepaymentRow,
      $$RepaymentsTableFilterComposer,
      $$RepaymentsTableOrderingComposer,
      $$RepaymentsTableAnnotationComposer,
      $$RepaymentsTableCreateCompanionBuilder,
      $$RepaymentsTableUpdateCompanionBuilder,
      (RepaymentRow, $$RepaymentsTableReferences),
      RepaymentRow,
      PrefetchHooks Function({bool borrowingId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LendersTableTableManager get lenders =>
      $$LendersTableTableManager(_db, _db.lenders);
  $$BorrowingsTableTableManager get borrowings =>
      $$BorrowingsTableTableManager(_db, _db.borrowings);
  $$RepaymentsTableTableManager get repayments =>
      $$RepaymentsTableTableManager(_db, _db.repayments);
}
