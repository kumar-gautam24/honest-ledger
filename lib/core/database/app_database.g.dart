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
  static const VerificationMeta _feeCapMeta = const VerificationMeta('feeCap');
  @override
  late final GeneratedColumn<double> feeCap = GeneratedColumn<double>(
    'fee_cap',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
    feeCap,
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
    if (data.containsKey('fee_cap')) {
      context.handle(
        _feeCapMeta,
        feeCap.isAcceptableOrUnknown(data['fee_cap']!, _feeCapMeta),
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
      feeCap: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fee_cap'],
      ),
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
  final double? feeCap;
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
    this.feeCap,
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
    if (!nullToAbsent || feeCap != null) {
      map['fee_cap'] = Variable<double>(feeCap);
    }
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
      feeCap: feeCap == null && nullToAbsent
          ? const Value.absent()
          : Value(feeCap),
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
      feeCap: serializer.fromJson<double?>(json['feeCap']),
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
      'feeCap': serializer.toJson<double?>(feeCap),
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
    Value<double?> feeCap = const Value.absent(),
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
    feeCap: feeCap.present ? feeCap.value : this.feeCap,
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
      feeCap: data.feeCap.present ? data.feeCap.value : this.feeCap,
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
          ..write('feeCap: $feeCap, ')
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
    feeCap,
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
          other.feeCap == this.feeCap &&
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
  final Value<double?> feeCap;
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
    this.feeCap = const Value.absent(),
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
    this.feeCap = const Value.absent(),
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
    Expression<double>? feeCap,
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
      if (feeCap != null) 'fee_cap': feeCap,
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
    Value<double?>? feeCap,
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
      feeCap: feeCap ?? this.feeCap,
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
    if (feeCap.present) {
      map['fee_cap'] = Variable<double>(feeCap.value);
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
          ..write('feeCap: $feeCap, ')
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('flexibleLoan'),
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
  static const VerificationMeta _foreclosureFeeMeta = const VerificationMeta(
    'foreclosureFee',
  );
  @override
  late final GeneratedColumn<double> foreclosureFee = GeneratedColumn<double>(
    'foreclosure_fee',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstOnInterestMeta = const VerificationMeta(
    'gstOnInterest',
  );
  @override
  late final GeneratedColumn<bool> gstOnInterest = GeneratedColumn<bool>(
    'gst_on_interest',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("gst_on_interest" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isNoCostEmiMeta = const VerificationMeta(
    'isNoCostEmi',
  );
  @override
  late final GeneratedColumn<bool> isNoCostEmi = GeneratedColumn<bool>(
    'is_no_cost_emi',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_no_cost_emi" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _feeFinancedMeta = const VerificationMeta(
    'feeFinanced',
  );
  @override
  late final GeneratedColumn<bool> feeFinanced = GeneratedColumn<bool>(
    'fee_financed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fee_financed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _minPaymentMeta = const VerificationMeta(
    'minPayment',
  );
  @override
  late final GeneratedColumn<double> minPayment = GeneratedColumn<double>(
    'min_payment',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
    kind,
    lenderId,
    lenderName,
    principal,
    processingFee,
    gstOnFee,
    foreclosureFee,
    gstOnInterest,
    isNoCostEmi,
    feeFinanced,
    interestRatePct,
    rateType,
    tenureMonths,
    minPayment,
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
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
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
    if (data.containsKey('foreclosure_fee')) {
      context.handle(
        _foreclosureFeeMeta,
        foreclosureFee.isAcceptableOrUnknown(
          data['foreclosure_fee']!,
          _foreclosureFeeMeta,
        ),
      );
    }
    if (data.containsKey('gst_on_interest')) {
      context.handle(
        _gstOnInterestMeta,
        gstOnInterest.isAcceptableOrUnknown(
          data['gst_on_interest']!,
          _gstOnInterestMeta,
        ),
      );
    }
    if (data.containsKey('is_no_cost_emi')) {
      context.handle(
        _isNoCostEmiMeta,
        isNoCostEmi.isAcceptableOrUnknown(
          data['is_no_cost_emi']!,
          _isNoCostEmiMeta,
        ),
      );
    }
    if (data.containsKey('fee_financed')) {
      context.handle(
        _feeFinancedMeta,
        feeFinanced.isAcceptableOrUnknown(
          data['fee_financed']!,
          _feeFinancedMeta,
        ),
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
    if (data.containsKey('min_payment')) {
      context.handle(
        _minPaymentMeta,
        minPayment.isAcceptableOrUnknown(data['min_payment']!, _minPaymentMeta),
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
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
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
      foreclosureFee: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}foreclosure_fee'],
      ),
      gstOnInterest: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}gst_on_interest'],
      )!,
      isNoCostEmi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_no_cost_emi'],
      )!,
      feeFinanced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fee_financed'],
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
      minPayment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_payment'],
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
  final String kind;
  final String? lenderId;
  final String lenderName;
  final double principal;
  final double processingFee;
  final double gstOnFee;
  final double? foreclosureFee;
  final bool gstOnInterest;
  final bool isNoCostEmi;
  final bool feeFinanced;
  final double interestRatePct;
  final String rateType;
  final int tenureMonths;
  final double minPayment;
  final DateTime startDate;
  final String status;
  final String? notes;
  final DateTime createdAt;
  const BorrowingRow({
    required this.id,
    required this.title,
    required this.kind,
    this.lenderId,
    required this.lenderName,
    required this.principal,
    required this.processingFee,
    required this.gstOnFee,
    this.foreclosureFee,
    required this.gstOnInterest,
    required this.isNoCostEmi,
    required this.feeFinanced,
    required this.interestRatePct,
    required this.rateType,
    required this.tenureMonths,
    required this.minPayment,
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
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || lenderId != null) {
      map['lender_id'] = Variable<String>(lenderId);
    }
    map['lender_name'] = Variable<String>(lenderName);
    map['principal'] = Variable<double>(principal);
    map['processing_fee'] = Variable<double>(processingFee);
    map['gst_on_fee'] = Variable<double>(gstOnFee);
    if (!nullToAbsent || foreclosureFee != null) {
      map['foreclosure_fee'] = Variable<double>(foreclosureFee);
    }
    map['gst_on_interest'] = Variable<bool>(gstOnInterest);
    map['is_no_cost_emi'] = Variable<bool>(isNoCostEmi);
    map['fee_financed'] = Variable<bool>(feeFinanced);
    map['interest_rate_pct'] = Variable<double>(interestRatePct);
    map['rate_type'] = Variable<String>(rateType);
    map['tenure_months'] = Variable<int>(tenureMonths);
    map['min_payment'] = Variable<double>(minPayment);
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
      kind: Value(kind),
      lenderId: lenderId == null && nullToAbsent
          ? const Value.absent()
          : Value(lenderId),
      lenderName: Value(lenderName),
      principal: Value(principal),
      processingFee: Value(processingFee),
      gstOnFee: Value(gstOnFee),
      foreclosureFee: foreclosureFee == null && nullToAbsent
          ? const Value.absent()
          : Value(foreclosureFee),
      gstOnInterest: Value(gstOnInterest),
      isNoCostEmi: Value(isNoCostEmi),
      feeFinanced: Value(feeFinanced),
      interestRatePct: Value(interestRatePct),
      rateType: Value(rateType),
      tenureMonths: Value(tenureMonths),
      minPayment: Value(minPayment),
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
      kind: serializer.fromJson<String>(json['kind']),
      lenderId: serializer.fromJson<String?>(json['lenderId']),
      lenderName: serializer.fromJson<String>(json['lenderName']),
      principal: serializer.fromJson<double>(json['principal']),
      processingFee: serializer.fromJson<double>(json['processingFee']),
      gstOnFee: serializer.fromJson<double>(json['gstOnFee']),
      foreclosureFee: serializer.fromJson<double?>(json['foreclosureFee']),
      gstOnInterest: serializer.fromJson<bool>(json['gstOnInterest']),
      isNoCostEmi: serializer.fromJson<bool>(json['isNoCostEmi']),
      feeFinanced: serializer.fromJson<bool>(json['feeFinanced']),
      interestRatePct: serializer.fromJson<double>(json['interestRatePct']),
      rateType: serializer.fromJson<String>(json['rateType']),
      tenureMonths: serializer.fromJson<int>(json['tenureMonths']),
      minPayment: serializer.fromJson<double>(json['minPayment']),
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
      'kind': serializer.toJson<String>(kind),
      'lenderId': serializer.toJson<String?>(lenderId),
      'lenderName': serializer.toJson<String>(lenderName),
      'principal': serializer.toJson<double>(principal),
      'processingFee': serializer.toJson<double>(processingFee),
      'gstOnFee': serializer.toJson<double>(gstOnFee),
      'foreclosureFee': serializer.toJson<double?>(foreclosureFee),
      'gstOnInterest': serializer.toJson<bool>(gstOnInterest),
      'isNoCostEmi': serializer.toJson<bool>(isNoCostEmi),
      'feeFinanced': serializer.toJson<bool>(feeFinanced),
      'interestRatePct': serializer.toJson<double>(interestRatePct),
      'rateType': serializer.toJson<String>(rateType),
      'tenureMonths': serializer.toJson<int>(tenureMonths),
      'minPayment': serializer.toJson<double>(minPayment),
      'startDate': serializer.toJson<DateTime>(startDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BorrowingRow copyWith({
    String? id,
    String? title,
    String? kind,
    Value<String?> lenderId = const Value.absent(),
    String? lenderName,
    double? principal,
    double? processingFee,
    double? gstOnFee,
    Value<double?> foreclosureFee = const Value.absent(),
    bool? gstOnInterest,
    bool? isNoCostEmi,
    bool? feeFinanced,
    double? interestRatePct,
    String? rateType,
    int? tenureMonths,
    double? minPayment,
    DateTime? startDate,
    String? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => BorrowingRow(
    id: id ?? this.id,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    lenderId: lenderId.present ? lenderId.value : this.lenderId,
    lenderName: lenderName ?? this.lenderName,
    principal: principal ?? this.principal,
    processingFee: processingFee ?? this.processingFee,
    gstOnFee: gstOnFee ?? this.gstOnFee,
    foreclosureFee: foreclosureFee.present
        ? foreclosureFee.value
        : this.foreclosureFee,
    gstOnInterest: gstOnInterest ?? this.gstOnInterest,
    isNoCostEmi: isNoCostEmi ?? this.isNoCostEmi,
    feeFinanced: feeFinanced ?? this.feeFinanced,
    interestRatePct: interestRatePct ?? this.interestRatePct,
    rateType: rateType ?? this.rateType,
    tenureMonths: tenureMonths ?? this.tenureMonths,
    minPayment: minPayment ?? this.minPayment,
    startDate: startDate ?? this.startDate,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  BorrowingRow copyWithCompanion(BorrowingsCompanion data) {
    return BorrowingRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      kind: data.kind.present ? data.kind.value : this.kind,
      lenderId: data.lenderId.present ? data.lenderId.value : this.lenderId,
      lenderName: data.lenderName.present
          ? data.lenderName.value
          : this.lenderName,
      principal: data.principal.present ? data.principal.value : this.principal,
      processingFee: data.processingFee.present
          ? data.processingFee.value
          : this.processingFee,
      gstOnFee: data.gstOnFee.present ? data.gstOnFee.value : this.gstOnFee,
      foreclosureFee: data.foreclosureFee.present
          ? data.foreclosureFee.value
          : this.foreclosureFee,
      gstOnInterest: data.gstOnInterest.present
          ? data.gstOnInterest.value
          : this.gstOnInterest,
      isNoCostEmi: data.isNoCostEmi.present
          ? data.isNoCostEmi.value
          : this.isNoCostEmi,
      feeFinanced: data.feeFinanced.present
          ? data.feeFinanced.value
          : this.feeFinanced,
      interestRatePct: data.interestRatePct.present
          ? data.interestRatePct.value
          : this.interestRatePct,
      rateType: data.rateType.present ? data.rateType.value : this.rateType,
      tenureMonths: data.tenureMonths.present
          ? data.tenureMonths.value
          : this.tenureMonths,
      minPayment: data.minPayment.present
          ? data.minPayment.value
          : this.minPayment,
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
          ..write('kind: $kind, ')
          ..write('lenderId: $lenderId, ')
          ..write('lenderName: $lenderName, ')
          ..write('principal: $principal, ')
          ..write('processingFee: $processingFee, ')
          ..write('gstOnFee: $gstOnFee, ')
          ..write('foreclosureFee: $foreclosureFee, ')
          ..write('gstOnInterest: $gstOnInterest, ')
          ..write('isNoCostEmi: $isNoCostEmi, ')
          ..write('feeFinanced: $feeFinanced, ')
          ..write('interestRatePct: $interestRatePct, ')
          ..write('rateType: $rateType, ')
          ..write('tenureMonths: $tenureMonths, ')
          ..write('minPayment: $minPayment, ')
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
    kind,
    lenderId,
    lenderName,
    principal,
    processingFee,
    gstOnFee,
    foreclosureFee,
    gstOnInterest,
    isNoCostEmi,
    feeFinanced,
    interestRatePct,
    rateType,
    tenureMonths,
    minPayment,
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
          other.kind == this.kind &&
          other.lenderId == this.lenderId &&
          other.lenderName == this.lenderName &&
          other.principal == this.principal &&
          other.processingFee == this.processingFee &&
          other.gstOnFee == this.gstOnFee &&
          other.foreclosureFee == this.foreclosureFee &&
          other.gstOnInterest == this.gstOnInterest &&
          other.isNoCostEmi == this.isNoCostEmi &&
          other.feeFinanced == this.feeFinanced &&
          other.interestRatePct == this.interestRatePct &&
          other.rateType == this.rateType &&
          other.tenureMonths == this.tenureMonths &&
          other.minPayment == this.minPayment &&
          other.startDate == this.startDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class BorrowingsCompanion extends UpdateCompanion<BorrowingRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> kind;
  final Value<String?> lenderId;
  final Value<String> lenderName;
  final Value<double> principal;
  final Value<double> processingFee;
  final Value<double> gstOnFee;
  final Value<double?> foreclosureFee;
  final Value<bool> gstOnInterest;
  final Value<bool> isNoCostEmi;
  final Value<bool> feeFinanced;
  final Value<double> interestRatePct;
  final Value<String> rateType;
  final Value<int> tenureMonths;
  final Value<double> minPayment;
  final Value<DateTime> startDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BorrowingsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.kind = const Value.absent(),
    this.lenderId = const Value.absent(),
    this.lenderName = const Value.absent(),
    this.principal = const Value.absent(),
    this.processingFee = const Value.absent(),
    this.gstOnFee = const Value.absent(),
    this.foreclosureFee = const Value.absent(),
    this.gstOnInterest = const Value.absent(),
    this.isNoCostEmi = const Value.absent(),
    this.feeFinanced = const Value.absent(),
    this.interestRatePct = const Value.absent(),
    this.rateType = const Value.absent(),
    this.tenureMonths = const Value.absent(),
    this.minPayment = const Value.absent(),
    this.startDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BorrowingsCompanion.insert({
    required String id,
    required String title,
    this.kind = const Value.absent(),
    this.lenderId = const Value.absent(),
    required String lenderName,
    required double principal,
    this.processingFee = const Value.absent(),
    this.gstOnFee = const Value.absent(),
    this.foreclosureFee = const Value.absent(),
    this.gstOnInterest = const Value.absent(),
    this.isNoCostEmi = const Value.absent(),
    this.feeFinanced = const Value.absent(),
    this.interestRatePct = const Value.absent(),
    this.rateType = const Value.absent(),
    this.tenureMonths = const Value.absent(),
    this.minPayment = const Value.absent(),
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
    Expression<String>? kind,
    Expression<String>? lenderId,
    Expression<String>? lenderName,
    Expression<double>? principal,
    Expression<double>? processingFee,
    Expression<double>? gstOnFee,
    Expression<double>? foreclosureFee,
    Expression<bool>? gstOnInterest,
    Expression<bool>? isNoCostEmi,
    Expression<bool>? feeFinanced,
    Expression<double>? interestRatePct,
    Expression<String>? rateType,
    Expression<int>? tenureMonths,
    Expression<double>? minPayment,
    Expression<DateTime>? startDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (kind != null) 'kind': kind,
      if (lenderId != null) 'lender_id': lenderId,
      if (lenderName != null) 'lender_name': lenderName,
      if (principal != null) 'principal': principal,
      if (processingFee != null) 'processing_fee': processingFee,
      if (gstOnFee != null) 'gst_on_fee': gstOnFee,
      if (foreclosureFee != null) 'foreclosure_fee': foreclosureFee,
      if (gstOnInterest != null) 'gst_on_interest': gstOnInterest,
      if (isNoCostEmi != null) 'is_no_cost_emi': isNoCostEmi,
      if (feeFinanced != null) 'fee_financed': feeFinanced,
      if (interestRatePct != null) 'interest_rate_pct': interestRatePct,
      if (rateType != null) 'rate_type': rateType,
      if (tenureMonths != null) 'tenure_months': tenureMonths,
      if (minPayment != null) 'min_payment': minPayment,
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
    Value<String>? kind,
    Value<String?>? lenderId,
    Value<String>? lenderName,
    Value<double>? principal,
    Value<double>? processingFee,
    Value<double>? gstOnFee,
    Value<double?>? foreclosureFee,
    Value<bool>? gstOnInterest,
    Value<bool>? isNoCostEmi,
    Value<bool>? feeFinanced,
    Value<double>? interestRatePct,
    Value<String>? rateType,
    Value<int>? tenureMonths,
    Value<double>? minPayment,
    Value<DateTime>? startDate,
    Value<String>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BorrowingsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      lenderId: lenderId ?? this.lenderId,
      lenderName: lenderName ?? this.lenderName,
      principal: principal ?? this.principal,
      processingFee: processingFee ?? this.processingFee,
      gstOnFee: gstOnFee ?? this.gstOnFee,
      foreclosureFee: foreclosureFee ?? this.foreclosureFee,
      gstOnInterest: gstOnInterest ?? this.gstOnInterest,
      isNoCostEmi: isNoCostEmi ?? this.isNoCostEmi,
      feeFinanced: feeFinanced ?? this.feeFinanced,
      interestRatePct: interestRatePct ?? this.interestRatePct,
      rateType: rateType ?? this.rateType,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      minPayment: minPayment ?? this.minPayment,
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
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
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
    if (foreclosureFee.present) {
      map['foreclosure_fee'] = Variable<double>(foreclosureFee.value);
    }
    if (gstOnInterest.present) {
      map['gst_on_interest'] = Variable<bool>(gstOnInterest.value);
    }
    if (isNoCostEmi.present) {
      map['is_no_cost_emi'] = Variable<bool>(isNoCostEmi.value);
    }
    if (feeFinanced.present) {
      map['fee_financed'] = Variable<bool>(feeFinanced.value);
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
    if (minPayment.present) {
      map['min_payment'] = Variable<double>(minPayment.value);
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
          ..write('kind: $kind, ')
          ..write('lenderId: $lenderId, ')
          ..write('lenderName: $lenderName, ')
          ..write('principal: $principal, ')
          ..write('processingFee: $processingFee, ')
          ..write('gstOnFee: $gstOnFee, ')
          ..write('foreclosureFee: $foreclosureFee, ')
          ..write('gstOnInterest: $gstOnInterest, ')
          ..write('isNoCostEmi: $isNoCostEmi, ')
          ..write('feeFinanced: $feeFinanced, ')
          ..write('interestRatePct: $interestRatePct, ')
          ..write('rateType: $rateType, ')
          ..write('tenureMonths: $tenureMonths, ')
          ..write('minPayment: $minPayment, ')
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
  static const VerificationMeta _installmentNoMeta = const VerificationMeta(
    'installmentNo',
  );
  @override
  late final GeneratedColumn<int> installmentNo = GeneratedColumn<int>(
    'installment_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [
    id,
    borrowingId,
    amount,
    date,
    installmentNo,
    note,
  ];
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
    if (data.containsKey('installment_no')) {
      context.handle(
        _installmentNoMeta,
        installmentNo.isAcceptableOrUnknown(
          data['installment_no']!,
          _installmentNoMeta,
        ),
      );
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
      installmentNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_no'],
      ),
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
  final int? installmentNo;
  final String? note;
  const RepaymentRow({
    required this.id,
    required this.borrowingId,
    required this.amount,
    required this.date,
    this.installmentNo,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['borrowing_id'] = Variable<String>(borrowingId);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || installmentNo != null) {
      map['installment_no'] = Variable<int>(installmentNo);
    }
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
      installmentNo: installmentNo == null && nullToAbsent
          ? const Value.absent()
          : Value(installmentNo),
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
      installmentNo: serializer.fromJson<int?>(json['installmentNo']),
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
      'installmentNo': serializer.toJson<int?>(installmentNo),
      'note': serializer.toJson<String?>(note),
    };
  }

  RepaymentRow copyWith({
    String? id,
    String? borrowingId,
    double? amount,
    DateTime? date,
    Value<int?> installmentNo = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => RepaymentRow(
    id: id ?? this.id,
    borrowingId: borrowingId ?? this.borrowingId,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    installmentNo: installmentNo.present
        ? installmentNo.value
        : this.installmentNo,
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
      installmentNo: data.installmentNo.present
          ? data.installmentNo.value
          : this.installmentNo,
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
          ..write('installmentNo: $installmentNo, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, borrowingId, amount, date, installmentNo, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepaymentRow &&
          other.id == this.id &&
          other.borrowingId == this.borrowingId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.installmentNo == this.installmentNo &&
          other.note == this.note);
}

class RepaymentsCompanion extends UpdateCompanion<RepaymentRow> {
  final Value<String> id;
  final Value<String> borrowingId;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<int?> installmentNo;
  final Value<String?> note;
  final Value<int> rowid;
  const RepaymentsCompanion({
    this.id = const Value.absent(),
    this.borrowingId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.installmentNo = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RepaymentsCompanion.insert({
    required String id,
    required String borrowingId,
    required double amount,
    required DateTime date,
    this.installmentNo = const Value.absent(),
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
    Expression<int>? installmentNo,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (borrowingId != null) 'borrowing_id': borrowingId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (installmentNo != null) 'installment_no': installmentNo,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RepaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? borrowingId,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<int?>? installmentNo,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return RepaymentsCompanion(
      id: id ?? this.id,
      borrowingId: borrowingId ?? this.borrowingId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      installmentNo: installmentNo ?? this.installmentNo,
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
    if (installmentNo.present) {
      map['installment_no'] = Variable<int>(installmentNo.value);
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
          ..write('installmentNo: $installmentNo, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringItemsTable extends RecurringItems
    with TableInfo<$RecurringItemsTable, RecurringItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('subscription'),
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
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monthly'),
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
    'next_due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    type,
    amount,
    frequency,
    nextDueDate,
    category,
    isActive,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringItemRow> instance, {
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
  RecurringItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_date'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
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
  $RecurringItemsTable createAlias(String alias) {
    return $RecurringItemsTable(attachedDatabase, alias);
  }
}

class RecurringItemRow extends DataClass
    implements Insertable<RecurringItemRow> {
  final String id;
  final String title;
  final String type;
  final double amount;
  final String frequency;
  final DateTime nextDueDate;
  final String? category;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;
  const RecurringItemRow({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.frequency,
    required this.nextDueDate,
    this.category,
    required this.isActive,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['frequency'] = Variable<String>(frequency);
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecurringItemsCompanion toCompanion(bool nullToAbsent) {
    return RecurringItemsCompanion(
      id: Value(id),
      title: Value(title),
      type: Value(type),
      amount: Value(amount),
      frequency: Value(frequency),
      nextDueDate: Value(nextDueDate),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      isActive: Value(isActive),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory RecurringItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringItemRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      frequency: serializer.fromJson<String>(json['frequency']),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
      category: serializer.fromJson<String?>(json['category']),
      isActive: serializer.fromJson<bool>(json['isActive']),
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
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'frequency': serializer.toJson<String>(frequency),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
      'category': serializer.toJson<String?>(category),
      'isActive': serializer.toJson<bool>(isActive),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecurringItemRow copyWith({
    String? id,
    String? title,
    String? type,
    double? amount,
    String? frequency,
    DateTime? nextDueDate,
    Value<String?> category = const Value.absent(),
    bool? isActive,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => RecurringItemRow(
    id: id ?? this.id,
    title: title ?? this.title,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    frequency: frequency ?? this.frequency,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    category: category.present ? category.value : this.category,
    isActive: isActive ?? this.isActive,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  RecurringItemRow copyWithCompanion(RecurringItemsCompanion data) {
    return RecurringItemRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      category: data.category.present ? data.category.value : this.category,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringItemRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('category: $category, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    type,
    amount,
    frequency,
    nextDueDate,
    category,
    isActive,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringItemRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.frequency == this.frequency &&
          other.nextDueDate == this.nextDueDate &&
          other.category == this.category &&
          other.isActive == this.isActive &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class RecurringItemsCompanion extends UpdateCompanion<RecurringItemRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> type;
  final Value<double> amount;
  final Value<String> frequency;
  final Value<DateTime> nextDueDate;
  final Value<String?> category;
  final Value<bool> isActive;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RecurringItemsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.category = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringItemsCompanion.insert({
    required String id,
    required String title,
    this.type = const Value.absent(),
    required double amount,
    this.frequency = const Value.absent(),
    required DateTime nextDueDate,
    this.category = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       amount = Value(amount),
       nextDueDate = Value(nextDueDate),
       createdAt = Value(createdAt);
  static Insertable<RecurringItemRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<String>? frequency,
    Expression<DateTime>? nextDueDate,
    Expression<String>? category,
    Expression<bool>? isActive,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (frequency != null) 'frequency': frequency,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (category != null) 'category': category,
      if (isActive != null) 'is_active': isActive,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? type,
    Value<double>? amount,
    Value<String>? frequency,
    Value<DateTime>? nextDueDate,
    Value<String?>? category,
    Value<bool>? isActive,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RecurringItemsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('RecurringItemsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('category: $category, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, CardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statementDayMeta = const VerificationMeta(
    'statementDay',
  );
  @override
  late final GeneratedColumn<int> statementDay = GeneratedColumn<int>(
    'statement_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditLimitMeta = const VerificationMeta(
    'creditLimit',
  );
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
    'credit_limit',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    lenderId,
    statementDay,
    dueDay,
    creditLimit,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lender_id')) {
      context.handle(
        _lenderIdMeta,
        lenderId.isAcceptableOrUnknown(data['lender_id']!, _lenderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lenderIdMeta);
    }
    if (data.containsKey('statement_day')) {
      context.handle(
        _statementDayMeta,
        statementDay.isAcceptableOrUnknown(
          data['statement_day']!,
          _statementDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_statementDayMeta);
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDayMeta);
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
        _creditLimitMeta,
        creditLimit.isAcceptableOrUnknown(
          data['credit_limit']!,
          _creditLimitMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
  CardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lenderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lender_id'],
      )!,
      statementDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}statement_day'],
      )!,
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      )!,
      creditLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}credit_limit'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class CardRow extends DataClass implements Insertable<CardRow> {
  final String id;
  final String lenderId;

  /// Day of month the statement is generated (1–31, clamped to month end).
  final int statementDay;

  /// Day of month the bill is due (1–31, clamped).
  final int dueDay;
  final double? creditLimit;
  final bool isActive;
  final DateTime createdAt;
  const CardRow({
    required this.id,
    required this.lenderId,
    required this.statementDay,
    required this.dueDay,
    this.creditLimit,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lender_id'] = Variable<String>(lenderId);
    map['statement_day'] = Variable<int>(statementDay);
    map['due_day'] = Variable<int>(dueDay);
    if (!nullToAbsent || creditLimit != null) {
      map['credit_limit'] = Variable<double>(creditLimit);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      lenderId: Value(lenderId),
      statementDay: Value(statementDay),
      dueDay: Value(dueDay),
      creditLimit: creditLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(creditLimit),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory CardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardRow(
      id: serializer.fromJson<String>(json['id']),
      lenderId: serializer.fromJson<String>(json['lenderId']),
      statementDay: serializer.fromJson<int>(json['statementDay']),
      dueDay: serializer.fromJson<int>(json['dueDay']),
      creditLimit: serializer.fromJson<double?>(json['creditLimit']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lenderId': serializer.toJson<String>(lenderId),
      'statementDay': serializer.toJson<int>(statementDay),
      'dueDay': serializer.toJson<int>(dueDay),
      'creditLimit': serializer.toJson<double?>(creditLimit),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CardRow copyWith({
    String? id,
    String? lenderId,
    int? statementDay,
    int? dueDay,
    Value<double?> creditLimit = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => CardRow(
    id: id ?? this.id,
    lenderId: lenderId ?? this.lenderId,
    statementDay: statementDay ?? this.statementDay,
    dueDay: dueDay ?? this.dueDay,
    creditLimit: creditLimit.present ? creditLimit.value : this.creditLimit,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  CardRow copyWithCompanion(CardsCompanion data) {
    return CardRow(
      id: data.id.present ? data.id.value : this.id,
      lenderId: data.lenderId.present ? data.lenderId.value : this.lenderId,
      statementDay: data.statementDay.present
          ? data.statementDay.value
          : this.statementDay,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      creditLimit: data.creditLimit.present
          ? data.creditLimit.value
          : this.creditLimit,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardRow(')
          ..write('id: $id, ')
          ..write('lenderId: $lenderId, ')
          ..write('statementDay: $statementDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lenderId,
    statementDay,
    dueDay,
    creditLimit,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardRow &&
          other.id == this.id &&
          other.lenderId == this.lenderId &&
          other.statementDay == this.statementDay &&
          other.dueDay == this.dueDay &&
          other.creditLimit == this.creditLimit &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class CardsCompanion extends UpdateCompanion<CardRow> {
  final Value<String> id;
  final Value<String> lenderId;
  final Value<int> statementDay;
  final Value<int> dueDay;
  final Value<double?> creditLimit;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.lenderId = const Value.absent(),
    this.statementDay = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String id,
    required String lenderId,
    required int statementDay,
    required int dueDay,
    this.creditLimit = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lenderId = Value(lenderId),
       statementDay = Value(statementDay),
       dueDay = Value(dueDay),
       createdAt = Value(createdAt);
  static Insertable<CardRow> custom({
    Expression<String>? id,
    Expression<String>? lenderId,
    Expression<int>? statementDay,
    Expression<int>? dueDay,
    Expression<double>? creditLimit,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lenderId != null) 'lender_id': lenderId,
      if (statementDay != null) 'statement_day': statementDay,
      if (dueDay != null) 'due_day': dueDay,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith({
    Value<String>? id,
    Value<String>? lenderId,
    Value<int>? statementDay,
    Value<int>? dueDay,
    Value<double?>? creditLimit,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      lenderId: lenderId ?? this.lenderId,
      statementDay: statementDay ?? this.statementDay,
      dueDay: dueDay ?? this.dueDay,
      creditLimit: creditLimit ?? this.creditLimit,
      isActive: isActive ?? this.isActive,
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
    if (lenderId.present) {
      map['lender_id'] = Variable<String>(lenderId.value);
    }
    if (statementDay.present) {
      map['statement_day'] = Variable<int>(statementDay.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('lenderId: $lenderId, ')
          ..write('statementDay: $statementDay, ')
          ..write('dueDay: $dueDay, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardStatementsTable extends CardStatements
    with TableInfo<$CardStatementsTable, CardStatementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardStatementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cards (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cycleMonthMeta = const VerificationMeta(
    'cycleMonth',
  );
  @override
  late final GeneratedColumn<DateTime> cycleMonth = GeneratedColumn<DateTime>(
    'cycle_month',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statementAmountMeta = const VerificationMeta(
    'statementAmount',
  );
  @override
  late final GeneratedColumn<double> statementAmount = GeneratedColumn<double>(
    'statement_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paidAmountMeta = const VerificationMeta(
    'paidAmount',
  );
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
    'paid_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paidDateMeta = const VerificationMeta(
    'paidDate',
  );
  @override
  late final GeneratedColumn<DateTime> paidDate = GeneratedColumn<DateTime>(
    'paid_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    cardId,
    cycleMonth,
    statementAmount,
    dueDate,
    paidAmount,
    paidDate,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_statements';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardStatementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('cycle_month')) {
      context.handle(
        _cycleMonthMeta,
        cycleMonth.isAcceptableOrUnknown(data['cycle_month']!, _cycleMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleMonthMeta);
    }
    if (data.containsKey('statement_amount')) {
      context.handle(
        _statementAmountMeta,
        statementAmount.isAcceptableOrUnknown(
          data['statement_amount']!,
          _statementAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_statementAmountMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
        _paidAmountMeta,
        paidAmount.isAcceptableOrUnknown(data['paid_amount']!, _paidAmountMeta),
      );
    }
    if (data.containsKey('paid_date')) {
      context.handle(
        _paidDateMeta,
        paidDate.isAcceptableOrUnknown(data['paid_date']!, _paidDateMeta),
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cardId, cycleMonth},
  ];
  @override
  CardStatementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardStatementRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      cycleMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cycle_month'],
      )!,
      statementAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}statement_amount'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      paidAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}paid_amount'],
      )!,
      paidDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $CardStatementsTable createAlias(String alias) {
    return $CardStatementsTable(attachedDatabase, alias);
  }
}

class CardStatementRow extends DataClass
    implements Insertable<CardStatementRow> {
  final String id;
  final String cardId;

  /// First day of the month the statement was generated in.
  final DateTime cycleMonth;
  final double statementAmount;
  final DateTime dueDate;
  final double paidAmount;
  final DateTime? paidDate;
  final String? notes;
  const CardStatementRow({
    required this.id,
    required this.cardId,
    required this.cycleMonth,
    required this.statementAmount,
    required this.dueDate,
    required this.paidAmount,
    this.paidDate,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['cycle_month'] = Variable<DateTime>(cycleMonth);
    map['statement_amount'] = Variable<double>(statementAmount);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['paid_amount'] = Variable<double>(paidAmount);
    if (!nullToAbsent || paidDate != null) {
      map['paid_date'] = Variable<DateTime>(paidDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  CardStatementsCompanion toCompanion(bool nullToAbsent) {
    return CardStatementsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      cycleMonth: Value(cycleMonth),
      statementAmount: Value(statementAmount),
      dueDate: Value(dueDate),
      paidAmount: Value(paidAmount),
      paidDate: paidDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paidDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory CardStatementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardStatementRow(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      cycleMonth: serializer.fromJson<DateTime>(json['cycleMonth']),
      statementAmount: serializer.fromJson<double>(json['statementAmount']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      paidDate: serializer.fromJson<DateTime?>(json['paidDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'cycleMonth': serializer.toJson<DateTime>(cycleMonth),
      'statementAmount': serializer.toJson<double>(statementAmount),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'paidDate': serializer.toJson<DateTime?>(paidDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  CardStatementRow copyWith({
    String? id,
    String? cardId,
    DateTime? cycleMonth,
    double? statementAmount,
    DateTime? dueDate,
    double? paidAmount,
    Value<DateTime?> paidDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => CardStatementRow(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    cycleMonth: cycleMonth ?? this.cycleMonth,
    statementAmount: statementAmount ?? this.statementAmount,
    dueDate: dueDate ?? this.dueDate,
    paidAmount: paidAmount ?? this.paidAmount,
    paidDate: paidDate.present ? paidDate.value : this.paidDate,
    notes: notes.present ? notes.value : this.notes,
  );
  CardStatementRow copyWithCompanion(CardStatementsCompanion data) {
    return CardStatementRow(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      cycleMonth: data.cycleMonth.present
          ? data.cycleMonth.value
          : this.cycleMonth,
      statementAmount: data.statementAmount.present
          ? data.statementAmount.value
          : this.statementAmount,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      paidAmount: data.paidAmount.present
          ? data.paidAmount.value
          : this.paidAmount,
      paidDate: data.paidDate.present ? data.paidDate.value : this.paidDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardStatementRow(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('cycleMonth: $cycleMonth, ')
          ..write('statementAmount: $statementAmount, ')
          ..write('dueDate: $dueDate, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paidDate: $paidDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardId,
    cycleMonth,
    statementAmount,
    dueDate,
    paidAmount,
    paidDate,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardStatementRow &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.cycleMonth == this.cycleMonth &&
          other.statementAmount == this.statementAmount &&
          other.dueDate == this.dueDate &&
          other.paidAmount == this.paidAmount &&
          other.paidDate == this.paidDate &&
          other.notes == this.notes);
}

class CardStatementsCompanion extends UpdateCompanion<CardStatementRow> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<DateTime> cycleMonth;
  final Value<double> statementAmount;
  final Value<DateTime> dueDate;
  final Value<double> paidAmount;
  final Value<DateTime?> paidDate;
  final Value<String?> notes;
  final Value<int> rowid;
  const CardStatementsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.cycleMonth = const Value.absent(),
    this.statementAmount = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardStatementsCompanion.insert({
    required String id,
    required String cardId,
    required DateTime cycleMonth,
    required double statementAmount,
    required DateTime dueDate,
    this.paidAmount = const Value.absent(),
    this.paidDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardId = Value(cardId),
       cycleMonth = Value(cycleMonth),
       statementAmount = Value(statementAmount),
       dueDate = Value(dueDate);
  static Insertable<CardStatementRow> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<DateTime>? cycleMonth,
    Expression<double>? statementAmount,
    Expression<DateTime>? dueDate,
    Expression<double>? paidAmount,
    Expression<DateTime>? paidDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (cycleMonth != null) 'cycle_month': cycleMonth,
      if (statementAmount != null) 'statement_amount': statementAmount,
      if (dueDate != null) 'due_date': dueDate,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (paidDate != null) 'paid_date': paidDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardStatementsCompanion copyWith({
    Value<String>? id,
    Value<String>? cardId,
    Value<DateTime>? cycleMonth,
    Value<double>? statementAmount,
    Value<DateTime>? dueDate,
    Value<double>? paidAmount,
    Value<DateTime?>? paidDate,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return CardStatementsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      cycleMonth: cycleMonth ?? this.cycleMonth,
      statementAmount: statementAmount ?? this.statementAmount,
      dueDate: dueDate ?? this.dueDate,
      paidAmount: paidAmount ?? this.paidAmount,
      paidDate: paidDate ?? this.paidDate,
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
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (cycleMonth.present) {
      map['cycle_month'] = Variable<DateTime>(cycleMonth.value);
    }
    if (statementAmount.present) {
      map['statement_amount'] = Variable<double>(statementAmount.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (paidDate.present) {
      map['paid_date'] = Variable<DateTime>(paidDate.value);
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
    return (StringBuffer('CardStatementsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('cycleMonth: $cycleMonth, ')
          ..write('statementAmount: $statementAmount, ')
          ..write('dueDate: $dueDate, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('paidDate: $paidDate, ')
          ..write('notes: $notes, ')
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
  late final $RecurringItemsTable recurringItems = $RecurringItemsTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $CardStatementsTable cardStatements = $CardStatementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    lenders,
    borrowings,
    repayments,
    recurringItems,
    cards,
    cardStatements,
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
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_statements', kind: UpdateKind.delete)],
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
      Value<double?> feeCap,
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
      Value<double?> feeCap,
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

  ColumnFilters<double> get feeCap => $composableBuilder(
    column: $table.feeCap,
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

  ColumnOrderings<double> get feeCap => $composableBuilder(
    column: $table.feeCap,
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

  GeneratedColumn<double> get feeCap =>
      $composableBuilder(column: $table.feeCap, builder: (column) => column);

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
                Value<double?> feeCap = const Value.absent(),
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
                feeCap: feeCap,
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
                Value<double?> feeCap = const Value.absent(),
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
                feeCap: feeCap,
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
      Value<String> kind,
      Value<String?> lenderId,
      required String lenderName,
      required double principal,
      Value<double> processingFee,
      Value<double> gstOnFee,
      Value<double?> foreclosureFee,
      Value<bool> gstOnInterest,
      Value<bool> isNoCostEmi,
      Value<bool> feeFinanced,
      Value<double> interestRatePct,
      Value<String> rateType,
      Value<int> tenureMonths,
      Value<double> minPayment,
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
      Value<String> kind,
      Value<String?> lenderId,
      Value<String> lenderName,
      Value<double> principal,
      Value<double> processingFee,
      Value<double> gstOnFee,
      Value<double?> foreclosureFee,
      Value<bool> gstOnInterest,
      Value<bool> isNoCostEmi,
      Value<bool> feeFinanced,
      Value<double> interestRatePct,
      Value<String> rateType,
      Value<int> tenureMonths,
      Value<double> minPayment,
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
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

  ColumnFilters<double> get foreclosureFee => $composableBuilder(
    column: $table.foreclosureFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get gstOnInterest => $composableBuilder(
    column: $table.gstOnInterest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNoCostEmi => $composableBuilder(
    column: $table.isNoCostEmi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get feeFinanced => $composableBuilder(
    column: $table.feeFinanced,
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

  ColumnFilters<double> get minPayment => $composableBuilder(
    column: $table.minPayment,
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
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

  ColumnOrderings<double> get foreclosureFee => $composableBuilder(
    column: $table.foreclosureFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get gstOnInterest => $composableBuilder(
    column: $table.gstOnInterest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNoCostEmi => $composableBuilder(
    column: $table.isNoCostEmi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get feeFinanced => $composableBuilder(
    column: $table.feeFinanced,
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

  ColumnOrderings<double> get minPayment => $composableBuilder(
    column: $table.minPayment,
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

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

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

  GeneratedColumn<double> get foreclosureFee => $composableBuilder(
    column: $table.foreclosureFee,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get gstOnInterest => $composableBuilder(
    column: $table.gstOnInterest,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isNoCostEmi => $composableBuilder(
    column: $table.isNoCostEmi,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get feeFinanced => $composableBuilder(
    column: $table.feeFinanced,
    builder: (column) => column,
  );

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

  GeneratedColumn<double> get minPayment => $composableBuilder(
    column: $table.minPayment,
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
                Value<String> kind = const Value.absent(),
                Value<String?> lenderId = const Value.absent(),
                Value<String> lenderName = const Value.absent(),
                Value<double> principal = const Value.absent(),
                Value<double> processingFee = const Value.absent(),
                Value<double> gstOnFee = const Value.absent(),
                Value<double?> foreclosureFee = const Value.absent(),
                Value<bool> gstOnInterest = const Value.absent(),
                Value<bool> isNoCostEmi = const Value.absent(),
                Value<bool> feeFinanced = const Value.absent(),
                Value<double> interestRatePct = const Value.absent(),
                Value<String> rateType = const Value.absent(),
                Value<int> tenureMonths = const Value.absent(),
                Value<double> minPayment = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BorrowingsCompanion(
                id: id,
                title: title,
                kind: kind,
                lenderId: lenderId,
                lenderName: lenderName,
                principal: principal,
                processingFee: processingFee,
                gstOnFee: gstOnFee,
                foreclosureFee: foreclosureFee,
                gstOnInterest: gstOnInterest,
                isNoCostEmi: isNoCostEmi,
                feeFinanced: feeFinanced,
                interestRatePct: interestRatePct,
                rateType: rateType,
                tenureMonths: tenureMonths,
                minPayment: minPayment,
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
                Value<String> kind = const Value.absent(),
                Value<String?> lenderId = const Value.absent(),
                required String lenderName,
                required double principal,
                Value<double> processingFee = const Value.absent(),
                Value<double> gstOnFee = const Value.absent(),
                Value<double?> foreclosureFee = const Value.absent(),
                Value<bool> gstOnInterest = const Value.absent(),
                Value<bool> isNoCostEmi = const Value.absent(),
                Value<bool> feeFinanced = const Value.absent(),
                Value<double> interestRatePct = const Value.absent(),
                Value<String> rateType = const Value.absent(),
                Value<int> tenureMonths = const Value.absent(),
                Value<double> minPayment = const Value.absent(),
                required DateTime startDate,
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BorrowingsCompanion.insert(
                id: id,
                title: title,
                kind: kind,
                lenderId: lenderId,
                lenderName: lenderName,
                principal: principal,
                processingFee: processingFee,
                gstOnFee: gstOnFee,
                foreclosureFee: foreclosureFee,
                gstOnInterest: gstOnInterest,
                isNoCostEmi: isNoCostEmi,
                feeFinanced: feeFinanced,
                interestRatePct: interestRatePct,
                rateType: rateType,
                tenureMonths: tenureMonths,
                minPayment: minPayment,
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
      Value<int?> installmentNo,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$RepaymentsTableUpdateCompanionBuilder =
    RepaymentsCompanion Function({
      Value<String> id,
      Value<String> borrowingId,
      Value<double> amount,
      Value<DateTime> date,
      Value<int?> installmentNo,
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

  ColumnFilters<int> get installmentNo => $composableBuilder(
    column: $table.installmentNo,
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

  ColumnOrderings<int> get installmentNo => $composableBuilder(
    column: $table.installmentNo,
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

  GeneratedColumn<int> get installmentNo => $composableBuilder(
    column: $table.installmentNo,
    builder: (column) => column,
  );

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
                Value<int?> installmentNo = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepaymentsCompanion(
                id: id,
                borrowingId: borrowingId,
                amount: amount,
                date: date,
                installmentNo: installmentNo,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String borrowingId,
                required double amount,
                required DateTime date,
                Value<int?> installmentNo = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepaymentsCompanion.insert(
                id: id,
                borrowingId: borrowingId,
                amount: amount,
                date: date,
                installmentNo: installmentNo,
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
typedef $$RecurringItemsTableCreateCompanionBuilder =
    RecurringItemsCompanion Function({
      required String id,
      required String title,
      Value<String> type,
      required double amount,
      Value<String> frequency,
      required DateTime nextDueDate,
      Value<String?> category,
      Value<bool> isActive,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$RecurringItemsTableUpdateCompanionBuilder =
    RecurringItemsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> type,
      Value<double> amount,
      Value<String> frequency,
      Value<DateTime> nextDueDate,
      Value<String?> category,
      Value<bool> isActive,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$RecurringItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringItemsTable> {
  $$RecurringItemsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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
}

class $$RecurringItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringItemsTable> {
  $$RecurringItemsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
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

class $$RecurringItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringItemsTable> {
  $$RecurringItemsTableAnnotationComposer({
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecurringItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringItemsTable,
          RecurringItemRow,
          $$RecurringItemsTableFilterComposer,
          $$RecurringItemsTableOrderingComposer,
          $$RecurringItemsTableAnnotationComposer,
          $$RecurringItemsTableCreateCompanionBuilder,
          $$RecurringItemsTableUpdateCompanionBuilder,
          (
            RecurringItemRow,
            BaseReferences<
              _$AppDatabase,
              $RecurringItemsTable,
              RecurringItemRow
            >,
          ),
          RecurringItemRow,
          PrefetchHooks Function()
        > {
  $$RecurringItemsTableTableManager(
    _$AppDatabase db,
    $RecurringItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<DateTime> nextDueDate = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringItemsCompanion(
                id: id,
                title: title,
                type: type,
                amount: amount,
                frequency: frequency,
                nextDueDate: nextDueDate,
                category: category,
                isActive: isActive,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String> type = const Value.absent(),
                required double amount,
                Value<String> frequency = const Value.absent(),
                required DateTime nextDueDate,
                Value<String?> category = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => RecurringItemsCompanion.insert(
                id: id,
                title: title,
                type: type,
                amount: amount,
                frequency: frequency,
                nextDueDate: nextDueDate,
                category: category,
                isActive: isActive,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringItemsTable,
      RecurringItemRow,
      $$RecurringItemsTableFilterComposer,
      $$RecurringItemsTableOrderingComposer,
      $$RecurringItemsTableAnnotationComposer,
      $$RecurringItemsTableCreateCompanionBuilder,
      $$RecurringItemsTableUpdateCompanionBuilder,
      (
        RecurringItemRow,
        BaseReferences<_$AppDatabase, $RecurringItemsTable, RecurringItemRow>,
      ),
      RecurringItemRow,
      PrefetchHooks Function()
    >;
typedef $$CardsTableCreateCompanionBuilder =
    CardsCompanion Function({
      required String id,
      required String lenderId,
      required int statementDay,
      required int dueDay,
      Value<double?> creditLimit,
      Value<bool> isActive,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CardsTableUpdateCompanionBuilder =
    CardsCompanion Function({
      Value<String> id,
      Value<String> lenderId,
      Value<int> statementDay,
      Value<int> dueDay,
      Value<double?> creditLimit,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, CardRow> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardStatementsTable, List<CardStatementRow>>
  _cardStatementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardStatements,
    aliasName: 'cards__id__card_statements__card_id',
  );

  $$CardStatementsTableProcessedTableManager get cardStatementsRefs {
    final manager = $$CardStatementsTableTableManager(
      $_db,
      $_db.cardStatements,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardStatementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
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

  ColumnFilters<String> get lenderId => $composableBuilder(
    column: $table.lenderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardStatementsRefs(
    Expression<bool> Function($$CardStatementsTableFilterComposer f) f,
  ) {
    final $$CardStatementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardStatements,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardStatementsTableFilterComposer(
            $db: $db,
            $table: $db.cardStatements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
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

  ColumnOrderings<String> get lenderId => $composableBuilder(
    column: $table.lenderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lenderId =>
      $composableBuilder(column: $table.lenderId, builder: (column) => column);

  GeneratedColumn<int> get statementDay => $composableBuilder(
    column: $table.statementDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
    column: $table.creditLimit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> cardStatementsRefs<T extends Object>(
    Expression<T> Function($$CardStatementsTableAnnotationComposer a) f,
  ) {
    final $$CardStatementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardStatements,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardStatementsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardStatements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          CardRow,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (CardRow, $$CardsTableReferences),
          CardRow,
          PrefetchHooks Function({bool cardStatementsRefs})
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lenderId = const Value.absent(),
                Value<int> statementDay = const Value.absent(),
                Value<int> dueDay = const Value.absent(),
                Value<double?> creditLimit = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                lenderId: lenderId,
                statementDay: statementDay,
                dueDay: dueDay,
                creditLimit: creditLimit,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lenderId,
                required int statementDay,
                required int dueDay,
                Value<double?> creditLimit = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                lenderId: lenderId,
                statementDay: statementDay,
                dueDay: dueDay,
                creditLimit: creditLimit,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CardsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cardStatementsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cardStatementsRefs) db.cardStatements,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardStatementsRefs)
                    await $_getPrefetchedData<
                      CardRow,
                      $CardsTable,
                      CardStatementRow
                    >(
                      currentTable: table,
                      referencedTable: $$CardsTableReferences
                          ._cardStatementsRefsTable(db),
                      managerFromTypedResult: (p0) => $$CardsTableReferences(
                        db,
                        table,
                        p0,
                      ).cardStatementsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.cardId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      CardRow,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (CardRow, $$CardsTableReferences),
      CardRow,
      PrefetchHooks Function({bool cardStatementsRefs})
    >;
typedef $$CardStatementsTableCreateCompanionBuilder =
    CardStatementsCompanion Function({
      required String id,
      required String cardId,
      required DateTime cycleMonth,
      required double statementAmount,
      required DateTime dueDate,
      Value<double> paidAmount,
      Value<DateTime?> paidDate,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$CardStatementsTableUpdateCompanionBuilder =
    CardStatementsCompanion Function({
      Value<String> id,
      Value<String> cardId,
      Value<DateTime> cycleMonth,
      Value<double> statementAmount,
      Value<DateTime> dueDate,
      Value<double> paidAmount,
      Value<DateTime?> paidDate,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$CardStatementsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CardStatementsTable, CardStatementRow> {
  $$CardStatementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('card_statements__card_id__cards__id');

  $$CardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardStatementsTableFilterComposer
    extends Composer<_$AppDatabase, $CardStatementsTable> {
  $$CardStatementsTableFilterComposer({
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

  ColumnFilters<DateTime> get cycleMonth => $composableBuilder(
    column: $table.cycleMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get statementAmount => $composableBuilder(
    column: $table.statementAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardStatementsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardStatementsTable> {
  $$CardStatementsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get cycleMonth => $composableBuilder(
    column: $table.cycleMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get statementAmount => $composableBuilder(
    column: $table.statementAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidDate => $composableBuilder(
    column: $table.paidDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardStatementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardStatementsTable> {
  $$CardStatementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get cycleMonth => $composableBuilder(
    column: $table.cycleMonth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get statementAmount => $composableBuilder(
    column: $table.statementAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
    column: $table.paidAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidDate =>
      $composableBuilder(column: $table.paidDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardStatementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardStatementsTable,
          CardStatementRow,
          $$CardStatementsTableFilterComposer,
          $$CardStatementsTableOrderingComposer,
          $$CardStatementsTableAnnotationComposer,
          $$CardStatementsTableCreateCompanionBuilder,
          $$CardStatementsTableUpdateCompanionBuilder,
          (CardStatementRow, $$CardStatementsTableReferences),
          CardStatementRow,
          PrefetchHooks Function({bool cardId})
        > {
  $$CardStatementsTableTableManager(
    _$AppDatabase db,
    $CardStatementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardStatementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardStatementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardStatementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardId = const Value.absent(),
                Value<DateTime> cycleMonth = const Value.absent(),
                Value<double> statementAmount = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<double> paidAmount = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardStatementsCompanion(
                id: id,
                cardId: cardId,
                cycleMonth: cycleMonth,
                statementAmount: statementAmount,
                dueDate: dueDate,
                paidAmount: paidAmount,
                paidDate: paidDate,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardId,
                required DateTime cycleMonth,
                required double statementAmount,
                required DateTime dueDate,
                Value<double> paidAmount = const Value.absent(),
                Value<DateTime?> paidDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardStatementsCompanion.insert(
                id: id,
                cardId: cardId,
                cycleMonth: cycleMonth,
                statementAmount: statementAmount,
                dueDate: dueDate,
                paidAmount: paidAmount,
                paidDate: paidDate,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardStatementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
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
                    if (cardId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardId,
                                referencedTable: $$CardStatementsTableReferences
                                    ._cardIdTable(db),
                                referencedColumn:
                                    $$CardStatementsTableReferences
                                        ._cardIdTable(db)
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

typedef $$CardStatementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardStatementsTable,
      CardStatementRow,
      $$CardStatementsTableFilterComposer,
      $$CardStatementsTableOrderingComposer,
      $$CardStatementsTableAnnotationComposer,
      $$CardStatementsTableCreateCompanionBuilder,
      $$CardStatementsTableUpdateCompanionBuilder,
      (CardStatementRow, $$CardStatementsTableReferences),
      CardStatementRow,
      PrefetchHooks Function({bool cardId})
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
  $$RecurringItemsTableTableManager get recurringItems =>
      $$RecurringItemsTableTableManager(_db, _db.recurringItems);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$CardStatementsTableTableManager get cardStatements =>
      $$CardStatementsTableTableManager(_db, _db.cardStatements);
}
