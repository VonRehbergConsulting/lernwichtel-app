// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ChildrenTable extends Children with TableInfo<$ChildrenTable, Child> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChildrenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, avatar, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'children';
  @override
  VerificationContext validateIntegrity(
    Insertable<Child> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Child map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Child(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ChildrenTable createAlias(String alias) {
    return $ChildrenTable(attachedDatabase, alias);
  }
}

class Child extends DataClass implements Insertable<Child> {
  final int id;
  final String name;

  /// Optionaler Avatar: Emoji ODER Dateipfad zu einem Foto.
  final String? avatar;
  final DateTime createdAt;
  const Child({
    required this.id,
    required this.name,
    this.avatar,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChildrenCompanion toCompanion(bool nullToAbsent) {
    return ChildrenCompanion(
      id: Value(id),
      name: Value(name),
      avatar: avatar == null && nullToAbsent
          ? const Value.absent()
          : Value(avatar),
      createdAt: Value(createdAt),
    );
  }

  factory Child.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Child(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'avatar': serializer.toJson<String?>(avatar),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Child copyWith({
    int? id,
    String? name,
    Value<String?> avatar = const Value.absent(),
    DateTime? createdAt,
  }) => Child(
    id: id ?? this.id,
    name: name ?? this.name,
    avatar: avatar.present ? avatar.value : this.avatar,
    createdAt: createdAt ?? this.createdAt,
  );
  Child copyWithCompanion(ChildrenCompanion data) {
    return Child(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Child(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, avatar, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Child &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatar == this.avatar &&
          other.createdAt == this.createdAt);
}

class ChildrenCompanion extends UpdateCompanion<Child> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> avatar;
  final Value<DateTime> createdAt;
  const ChildrenCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChildrenCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.avatar = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Child> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? avatar,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChildrenCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? avatar,
    Value<DateTime>? createdAt,
  }) {
    return ChildrenCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChildrenCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GraphemesTable extends Graphemes
    with TableInfo<$GraphemesTable, Grapheme> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GraphemesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _graphemeKeyMeta = const VerificationMeta(
    'graphemeKey',
  );
  @override
  late final GeneratedColumn<String> graphemeKey = GeneratedColumn<String>(
    'grapheme_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soundMeta = const VerificationMeta('sound');
  @override
  late final GeneratedColumn<String> sound = GeneratedColumn<String>(
    'sound',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioAssetMeta = const VerificationMeta(
    'audioAsset',
  );
  @override
  late final GeneratedColumn<String> audioAsset = GeneratedColumn<String>(
    'audio_asset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merkhilfeMeta = const VerificationMeta(
    'merkhilfe',
  );
  @override
  late final GeneratedColumn<String> merkhilfe = GeneratedColumn<String>(
    'merkhilfe',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(999),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    symbol,
    graphemeKey,
    kind,
    sound,
    audioAsset,
    merkhilfe,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'graphemes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Grapheme> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('grapheme_key')) {
      context.handle(
        _graphemeKeyMeta,
        graphemeKey.isAcceptableOrUnknown(
          data['grapheme_key']!,
          _graphemeKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_graphemeKeyMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('sound')) {
      context.handle(
        _soundMeta,
        sound.isAcceptableOrUnknown(data['sound']!, _soundMeta),
      );
    }
    if (data.containsKey('audio_asset')) {
      context.handle(
        _audioAssetMeta,
        audioAsset.isAcceptableOrUnknown(data['audio_asset']!, _audioAssetMeta),
      );
    }
    if (data.containsKey('merkhilfe')) {
      context.handle(
        _merkhilfeMeta,
        merkhilfe.isAcceptableOrUnknown(data['merkhilfe']!, _merkhilfeMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Grapheme map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Grapheme(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      graphemeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grapheme_key'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      sound: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound'],
      ),
      audioAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_asset'],
      ),
      merkhilfe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merkhilfe'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $GraphemesTable createAlias(String alias) {
    return $GraphemesTable(attachedDatabase, alias);
  }
}

class Grapheme extends DataClass implements Insertable<Grapheme> {
  final int id;

  /// Anzeige-Symbol, z. B. "m", "sch", "ä".
  final String symbol;

  /// Stabiler Schluessel aus der Seed-JSON, z. B. "m", "ch-ich".
  final String graphemeKey;

  /// "buchstabe" oder "verbindung".
  final String kind;

  /// Beschreibung des reinen Lauts (fuer Aufnahme-Referenz).
  final String? sound;

  /// Asset-Pfad zur Laut-Aufnahme, z. B. "assets/audio/laute/m.mp3".
  final String? audioAsset;

  /// Kindgerechter Merksatz (v. a. fuer Lautverbindungen), z. B.
  /// "au – wie beim Aua!".
  final String? merkhilfe;
  final int sortOrder;
  const Grapheme({
    required this.id,
    required this.symbol,
    required this.graphemeKey,
    required this.kind,
    this.sound,
    this.audioAsset,
    this.merkhilfe,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['symbol'] = Variable<String>(symbol);
    map['grapheme_key'] = Variable<String>(graphemeKey);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || sound != null) {
      map['sound'] = Variable<String>(sound);
    }
    if (!nullToAbsent || audioAsset != null) {
      map['audio_asset'] = Variable<String>(audioAsset);
    }
    if (!nullToAbsent || merkhilfe != null) {
      map['merkhilfe'] = Variable<String>(merkhilfe);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  GraphemesCompanion toCompanion(bool nullToAbsent) {
    return GraphemesCompanion(
      id: Value(id),
      symbol: Value(symbol),
      graphemeKey: Value(graphemeKey),
      kind: Value(kind),
      sound: sound == null && nullToAbsent
          ? const Value.absent()
          : Value(sound),
      audioAsset: audioAsset == null && nullToAbsent
          ? const Value.absent()
          : Value(audioAsset),
      merkhilfe: merkhilfe == null && nullToAbsent
          ? const Value.absent()
          : Value(merkhilfe),
      sortOrder: Value(sortOrder),
    );
  }

  factory Grapheme.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Grapheme(
      id: serializer.fromJson<int>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      graphemeKey: serializer.fromJson<String>(json['graphemeKey']),
      kind: serializer.fromJson<String>(json['kind']),
      sound: serializer.fromJson<String?>(json['sound']),
      audioAsset: serializer.fromJson<String?>(json['audioAsset']),
      merkhilfe: serializer.fromJson<String?>(json['merkhilfe']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'symbol': serializer.toJson<String>(symbol),
      'graphemeKey': serializer.toJson<String>(graphemeKey),
      'kind': serializer.toJson<String>(kind),
      'sound': serializer.toJson<String?>(sound),
      'audioAsset': serializer.toJson<String?>(audioAsset),
      'merkhilfe': serializer.toJson<String?>(merkhilfe),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Grapheme copyWith({
    int? id,
    String? symbol,
    String? graphemeKey,
    String? kind,
    Value<String?> sound = const Value.absent(),
    Value<String?> audioAsset = const Value.absent(),
    Value<String?> merkhilfe = const Value.absent(),
    int? sortOrder,
  }) => Grapheme(
    id: id ?? this.id,
    symbol: symbol ?? this.symbol,
    graphemeKey: graphemeKey ?? this.graphemeKey,
    kind: kind ?? this.kind,
    sound: sound.present ? sound.value : this.sound,
    audioAsset: audioAsset.present ? audioAsset.value : this.audioAsset,
    merkhilfe: merkhilfe.present ? merkhilfe.value : this.merkhilfe,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Grapheme copyWithCompanion(GraphemesCompanion data) {
    return Grapheme(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      graphemeKey: data.graphemeKey.present
          ? data.graphemeKey.value
          : this.graphemeKey,
      kind: data.kind.present ? data.kind.value : this.kind,
      sound: data.sound.present ? data.sound.value : this.sound,
      audioAsset: data.audioAsset.present
          ? data.audioAsset.value
          : this.audioAsset,
      merkhilfe: data.merkhilfe.present ? data.merkhilfe.value : this.merkhilfe,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Grapheme(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('graphemeKey: $graphemeKey, ')
          ..write('kind: $kind, ')
          ..write('sound: $sound, ')
          ..write('audioAsset: $audioAsset, ')
          ..write('merkhilfe: $merkhilfe, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    symbol,
    graphemeKey,
    kind,
    sound,
    audioAsset,
    merkhilfe,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Grapheme &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.graphemeKey == this.graphemeKey &&
          other.kind == this.kind &&
          other.sound == this.sound &&
          other.audioAsset == this.audioAsset &&
          other.merkhilfe == this.merkhilfe &&
          other.sortOrder == this.sortOrder);
}

class GraphemesCompanion extends UpdateCompanion<Grapheme> {
  final Value<int> id;
  final Value<String> symbol;
  final Value<String> graphemeKey;
  final Value<String> kind;
  final Value<String?> sound;
  final Value<String?> audioAsset;
  final Value<String?> merkhilfe;
  final Value<int> sortOrder;
  const GraphemesCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.graphemeKey = const Value.absent(),
    this.kind = const Value.absent(),
    this.sound = const Value.absent(),
    this.audioAsset = const Value.absent(),
    this.merkhilfe = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  GraphemesCompanion.insert({
    this.id = const Value.absent(),
    required String symbol,
    required String graphemeKey,
    required String kind,
    this.sound = const Value.absent(),
    this.audioAsset = const Value.absent(),
    this.merkhilfe = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : symbol = Value(symbol),
       graphemeKey = Value(graphemeKey),
       kind = Value(kind);
  static Insertable<Grapheme> custom({
    Expression<int>? id,
    Expression<String>? symbol,
    Expression<String>? graphemeKey,
    Expression<String>? kind,
    Expression<String>? sound,
    Expression<String>? audioAsset,
    Expression<String>? merkhilfe,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (graphemeKey != null) 'grapheme_key': graphemeKey,
      if (kind != null) 'kind': kind,
      if (sound != null) 'sound': sound,
      if (audioAsset != null) 'audio_asset': audioAsset,
      if (merkhilfe != null) 'merkhilfe': merkhilfe,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  GraphemesCompanion copyWith({
    Value<int>? id,
    Value<String>? symbol,
    Value<String>? graphemeKey,
    Value<String>? kind,
    Value<String?>? sound,
    Value<String?>? audioAsset,
    Value<String?>? merkhilfe,
    Value<int>? sortOrder,
  }) {
    return GraphemesCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      graphemeKey: graphemeKey ?? this.graphemeKey,
      kind: kind ?? this.kind,
      sound: sound ?? this.sound,
      audioAsset: audioAsset ?? this.audioAsset,
      merkhilfe: merkhilfe ?? this.merkhilfe,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (graphemeKey.present) {
      map['grapheme_key'] = Variable<String>(graphemeKey.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (sound.present) {
      map['sound'] = Variable<String>(sound.value);
    }
    if (audioAsset.present) {
      map['audio_asset'] = Variable<String>(audioAsset.value);
    }
    if (merkhilfe.present) {
      map['merkhilfe'] = Variable<String>(merkhilfe.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GraphemesCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('graphemeKey: $graphemeKey, ')
          ..write('kind: $kind, ')
          ..write('sound: $sound, ')
          ..write('audioAsset: $audioAsset, ')
          ..write('merkhilfe: $merkhilfe, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $GraphemeProgressTable extends GraphemeProgress
    with TableInfo<$GraphemeProgressTable, GraphemeProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GraphemeProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _graphemeIdMeta = const VerificationMeta(
    'graphemeId',
  );
  @override
  late final GeneratedColumn<int> graphemeId = GeneratedColumn<int>(
    'grapheme_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES graphemes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('neu'),
  );
  static const VerificationMeta _boxMeta = const VerificationMeta('box');
  @override
  late final GeneratedColumn<int> box = GeneratedColumn<int>(
    'box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  @override
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeen = GeneratedColumn<DateTime>(
    'last_seen',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    childId,
    graphemeId,
    status,
    box,
    repetitions,
    lastSeen,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grapheme_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<GraphemeProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('grapheme_id')) {
      context.handle(
        _graphemeIdMeta,
        graphemeId.isAcceptableOrUnknown(data['grapheme_id']!, _graphemeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_graphemeIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('box')) {
      context.handle(
        _boxMeta,
        box.isAcceptableOrUnknown(data['box']!, _boxMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, graphemeId};
  @override
  GraphemeProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GraphemeProgressData(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      graphemeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grapheme_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      box: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen'],
      ),
    );
  }

  @override
  $GraphemeProgressTable createAlias(String alias) {
    return $GraphemeProgressTable(attachedDatabase, alias);
  }
}

class GraphemeProgressData extends DataClass
    implements Insertable<GraphemeProgressData> {
  final int childId;
  final int graphemeId;

  /// "neu" | "lernend" | "sicher".
  final String status;

  /// Leitner-Box (1..3): hoehere Box = seltener wiederholen.
  final int box;
  final int repetitions;
  final DateTime? lastSeen;
  const GraphemeProgressData({
    required this.childId,
    required this.graphemeId,
    required this.status,
    required this.box,
    required this.repetitions,
    this.lastSeen,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<int>(childId);
    map['grapheme_id'] = Variable<int>(graphemeId);
    map['status'] = Variable<String>(status);
    map['box'] = Variable<int>(box);
    map['repetitions'] = Variable<int>(repetitions);
    if (!nullToAbsent || lastSeen != null) {
      map['last_seen'] = Variable<DateTime>(lastSeen);
    }
    return map;
  }

  GraphemeProgressCompanion toCompanion(bool nullToAbsent) {
    return GraphemeProgressCompanion(
      childId: Value(childId),
      graphemeId: Value(graphemeId),
      status: Value(status),
      box: Value(box),
      repetitions: Value(repetitions),
      lastSeen: lastSeen == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeen),
    );
  }

  factory GraphemeProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GraphemeProgressData(
      childId: serializer.fromJson<int>(json['childId']),
      graphemeId: serializer.fromJson<int>(json['graphemeId']),
      status: serializer.fromJson<String>(json['status']),
      box: serializer.fromJson<int>(json['box']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      lastSeen: serializer.fromJson<DateTime?>(json['lastSeen']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'childId': serializer.toJson<int>(childId),
      'graphemeId': serializer.toJson<int>(graphemeId),
      'status': serializer.toJson<String>(status),
      'box': serializer.toJson<int>(box),
      'repetitions': serializer.toJson<int>(repetitions),
      'lastSeen': serializer.toJson<DateTime?>(lastSeen),
    };
  }

  GraphemeProgressData copyWith({
    int? childId,
    int? graphemeId,
    String? status,
    int? box,
    int? repetitions,
    Value<DateTime?> lastSeen = const Value.absent(),
  }) => GraphemeProgressData(
    childId: childId ?? this.childId,
    graphemeId: graphemeId ?? this.graphemeId,
    status: status ?? this.status,
    box: box ?? this.box,
    repetitions: repetitions ?? this.repetitions,
    lastSeen: lastSeen.present ? lastSeen.value : this.lastSeen,
  );
  GraphemeProgressData copyWithCompanion(GraphemeProgressCompanion data) {
    return GraphemeProgressData(
      childId: data.childId.present ? data.childId.value : this.childId,
      graphemeId: data.graphemeId.present
          ? data.graphemeId.value
          : this.graphemeId,
      status: data.status.present ? data.status.value : this.status,
      box: data.box.present ? data.box.value : this.box,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GraphemeProgressData(')
          ..write('childId: $childId, ')
          ..write('graphemeId: $graphemeId, ')
          ..write('status: $status, ')
          ..write('box: $box, ')
          ..write('repetitions: $repetitions, ')
          ..write('lastSeen: $lastSeen')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(childId, graphemeId, status, box, repetitions, lastSeen);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GraphemeProgressData &&
          other.childId == this.childId &&
          other.graphemeId == this.graphemeId &&
          other.status == this.status &&
          other.box == this.box &&
          other.repetitions == this.repetitions &&
          other.lastSeen == this.lastSeen);
}

class GraphemeProgressCompanion extends UpdateCompanion<GraphemeProgressData> {
  final Value<int> childId;
  final Value<int> graphemeId;
  final Value<String> status;
  final Value<int> box;
  final Value<int> repetitions;
  final Value<DateTime?> lastSeen;
  final Value<int> rowid;
  const GraphemeProgressCompanion({
    this.childId = const Value.absent(),
    this.graphemeId = const Value.absent(),
    this.status = const Value.absent(),
    this.box = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GraphemeProgressCompanion.insert({
    required int childId,
    required int graphemeId,
    this.status = const Value.absent(),
    this.box = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : childId = Value(childId),
       graphemeId = Value(graphemeId);
  static Insertable<GraphemeProgressData> custom({
    Expression<int>? childId,
    Expression<int>? graphemeId,
    Expression<String>? status,
    Expression<int>? box,
    Expression<int>? repetitions,
    Expression<DateTime>? lastSeen,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (graphemeId != null) 'grapheme_id': graphemeId,
      if (status != null) 'status': status,
      if (box != null) 'box': box,
      if (repetitions != null) 'repetitions': repetitions,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GraphemeProgressCompanion copyWith({
    Value<int>? childId,
    Value<int>? graphemeId,
    Value<String>? status,
    Value<int>? box,
    Value<int>? repetitions,
    Value<DateTime?>? lastSeen,
    Value<int>? rowid,
  }) {
    return GraphemeProgressCompanion(
      childId: childId ?? this.childId,
      graphemeId: graphemeId ?? this.graphemeId,
      status: status ?? this.status,
      box: box ?? this.box,
      repetitions: repetitions ?? this.repetitions,
      lastSeen: lastSeen ?? this.lastSeen,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (graphemeId.present) {
      map['grapheme_id'] = Variable<int>(graphemeId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (box.present) {
      map['box'] = Variable<int>(box.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<DateTime>(lastSeen.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GraphemeProgressCompanion(')
          ..write('childId: $childId, ')
          ..write('graphemeId: $graphemeId, ')
          ..write('status: $status, ')
          ..write('box: $box, ')
          ..write('repetitions: $repetitions, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageAssetsTable extends ImageAssets
    with TableInfo<$ImageAssetsTable, ImageAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, filePath, label];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImageAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageAsset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
    );
  }

  @override
  $ImageAssetsTable createAlias(String alias) {
    return $ImageAssetsTable(attachedDatabase, alias);
  }
}

class ImageAsset extends DataClass implements Insertable<ImageAsset> {
  final int id;
  final String filePath;
  final String? label;
  const ImageAsset({required this.id, required this.filePath, this.label});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    return map;
  }

  ImageAssetsCompanion toCompanion(bool nullToAbsent) {
    return ImageAssetsCompanion(
      id: Value(id),
      filePath: Value(filePath),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
    );
  }

  factory ImageAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageAsset(
      id: serializer.fromJson<int>(json['id']),
      filePath: serializer.fromJson<String>(json['filePath']),
      label: serializer.fromJson<String?>(json['label']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'filePath': serializer.toJson<String>(filePath),
      'label': serializer.toJson<String?>(label),
    };
  }

  ImageAsset copyWith({
    int? id,
    String? filePath,
    Value<String?> label = const Value.absent(),
  }) => ImageAsset(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    label: label.present ? label.value : this.label,
  );
  ImageAsset copyWithCompanion(ImageAssetsCompanion data) {
    return ImageAsset(
      id: data.id.present ? data.id.value : this.id,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      label: data.label.present ? data.label.value : this.label,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageAsset(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, filePath, label);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageAsset &&
          other.id == this.id &&
          other.filePath == this.filePath &&
          other.label == this.label);
}

class ImageAssetsCompanion extends UpdateCompanion<ImageAsset> {
  final Value<int> id;
  final Value<String> filePath;
  final Value<String?> label;
  const ImageAssetsCompanion({
    this.id = const Value.absent(),
    this.filePath = const Value.absent(),
    this.label = const Value.absent(),
  });
  ImageAssetsCompanion.insert({
    this.id = const Value.absent(),
    required String filePath,
    this.label = const Value.absent(),
  }) : filePath = Value(filePath);
  static Insertable<ImageAsset> custom({
    Expression<int>? id,
    Expression<String>? filePath,
    Expression<String>? label,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filePath != null) 'file_path': filePath,
      if (label != null) 'label': label,
    });
  }

  ImageAssetsCompanion copyWith({
    Value<int>? id,
    Value<String>? filePath,
    Value<String?>? label,
  }) {
    return ImageAssetsCompanion(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      label: label ?? this.label,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageAssetsCompanion(')
          ..write('id: $id, ')
          ..write('filePath: $filePath, ')
          ..write('label: $label')
          ..write(')'))
        .toString();
  }
}

class $WordsTable extends Words with TableInfo<$WordsTable, Word> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageIdMeta = const VerificationMeta(
    'imageId',
  );
  @override
  late final GeneratedColumn<int> imageId = GeneratedColumn<int>(
    'image_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES image_assets (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, word, imageId, isCustom];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<Word> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('image_id')) {
      context.handle(
        _imageIdMeta,
        imageId.isAcceptableOrUnknown(data['image_id']!, _imageIdMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Word map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Word(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      imageId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}image_id'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class Word extends DataClass implements Insertable<Word> {
  final int id;

  /// Das Wort selbst. Nicht "text" nennen: kollidiert mit Table.text().
  final String word;
  final int? imageId;
  final bool isCustom;
  const Word({
    required this.id,
    required this.word,
    this.imageId,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    if (!nullToAbsent || imageId != null) {
      map['image_id'] = Variable<int>(imageId);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      word: Value(word),
      imageId: imageId == null && nullToAbsent
          ? const Value.absent()
          : Value(imageId),
      isCustom: Value(isCustom),
    );
  }

  factory Word.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Word(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      imageId: serializer.fromJson<int?>(json['imageId']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
      'imageId': serializer.toJson<int?>(imageId),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  Word copyWith({
    int? id,
    String? word,
    Value<int?> imageId = const Value.absent(),
    bool? isCustom,
  }) => Word(
    id: id ?? this.id,
    word: word ?? this.word,
    imageId: imageId.present ? imageId.value : this.imageId,
    isCustom: isCustom ?? this.isCustom,
  );
  Word copyWithCompanion(WordsCompanion data) {
    return Word(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      imageId: data.imageId.present ? data.imageId.value : this.imageId,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Word(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('imageId: $imageId, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, word, imageId, isCustom);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Word &&
          other.id == this.id &&
          other.word == this.word &&
          other.imageId == this.imageId &&
          other.isCustom == this.isCustom);
}

class WordsCompanion extends UpdateCompanion<Word> {
  final Value<int> id;
  final Value<String> word;
  final Value<int?> imageId;
  final Value<bool> isCustom;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.imageId = const Value.absent(),
    this.isCustom = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    this.imageId = const Value.absent(),
    this.isCustom = const Value.absent(),
  }) : word = Value(word);
  static Insertable<Word> custom({
    Expression<int>? id,
    Expression<String>? word,
    Expression<int>? imageId,
    Expression<bool>? isCustom,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (imageId != null) 'image_id': imageId,
      if (isCustom != null) 'is_custom': isCustom,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? word,
    Value<int?>? imageId,
    Value<bool>? isCustom,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      imageId: imageId ?? this.imageId,
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (imageId.present) {
      map['image_id'] = Variable<int>(imageId.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('imageId: $imageId, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }
}

class $WordEnabledTable extends WordEnabled
    with TableInfo<$WordEnabledTable, WordEnabledData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordEnabledTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordIdMeta = const VerificationMeta('wordId');
  @override
  late final GeneratedColumn<int> wordId = GeneratedColumn<int>(
    'word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES words (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [childId, wordId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'word_enabled';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordEnabledData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('word_id')) {
      context.handle(
        _wordIdMeta,
        wordId.isAcceptableOrUnknown(data['word_id']!, _wordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wordIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, wordId};
  @override
  WordEnabledData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordEnabledData(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      wordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}word_id'],
      )!,
    );
  }

  @override
  $WordEnabledTable createAlias(String alias) {
    return $WordEnabledTable(attachedDatabase, alias);
  }
}

class WordEnabledData extends DataClass implements Insertable<WordEnabledData> {
  final int childId;
  final int wordId;
  const WordEnabledData({required this.childId, required this.wordId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<int>(childId);
    map['word_id'] = Variable<int>(wordId);
    return map;
  }

  WordEnabledCompanion toCompanion(bool nullToAbsent) {
    return WordEnabledCompanion(childId: Value(childId), wordId: Value(wordId));
  }

  factory WordEnabledData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordEnabledData(
      childId: serializer.fromJson<int>(json['childId']),
      wordId: serializer.fromJson<int>(json['wordId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'childId': serializer.toJson<int>(childId),
      'wordId': serializer.toJson<int>(wordId),
    };
  }

  WordEnabledData copyWith({int? childId, int? wordId}) => WordEnabledData(
    childId: childId ?? this.childId,
    wordId: wordId ?? this.wordId,
  );
  WordEnabledData copyWithCompanion(WordEnabledCompanion data) {
    return WordEnabledData(
      childId: data.childId.present ? data.childId.value : this.childId,
      wordId: data.wordId.present ? data.wordId.value : this.wordId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordEnabledData(')
          ..write('childId: $childId, ')
          ..write('wordId: $wordId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(childId, wordId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordEnabledData &&
          other.childId == this.childId &&
          other.wordId == this.wordId);
}

class WordEnabledCompanion extends UpdateCompanion<WordEnabledData> {
  final Value<int> childId;
  final Value<int> wordId;
  final Value<int> rowid;
  const WordEnabledCompanion({
    this.childId = const Value.absent(),
    this.wordId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WordEnabledCompanion.insert({
    required int childId,
    required int wordId,
    this.rowid = const Value.absent(),
  }) : childId = Value(childId),
       wordId = Value(wordId);
  static Insertable<WordEnabledData> custom({
    Expression<int>? childId,
    Expression<int>? wordId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (wordId != null) 'word_id': wordId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WordEnabledCompanion copyWith({
    Value<int>? childId,
    Value<int>? wordId,
    Value<int>? rowid,
  }) {
    return WordEnabledCompanion(
      childId: childId ?? this.childId,
      wordId: wordId ?? this.wordId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (wordId.present) {
      map['word_id'] = Variable<int>(wordId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordEnabledCompanion(')
          ..write('childId: $childId, ')
          ..write('wordId: $wordId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressTable extends ReadingProgress
    with TableInfo<$ReadingProgressTable, ReadingProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordsUnlockedMeta = const VerificationMeta(
    'wordsUnlocked',
  );
  @override
  late final GeneratedColumn<int> wordsUnlocked = GeneratedColumn<int>(
    'words_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _combosUnlockedMeta = const VerificationMeta(
    'combosUnlocked',
  );
  @override
  late final GeneratedColumn<int> combosUnlocked = GeneratedColumn<int>(
    'combos_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  @override
  List<GeneratedColumn> get $columns => [
    childId,
    wordsUnlocked,
    combosUnlocked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    }
    if (data.containsKey('words_unlocked')) {
      context.handle(
        _wordsUnlockedMeta,
        wordsUnlocked.isAcceptableOrUnknown(
          data['words_unlocked']!,
          _wordsUnlockedMeta,
        ),
      );
    }
    if (data.containsKey('combos_unlocked')) {
      context.handle(
        _combosUnlockedMeta,
        combosUnlocked.isAcceptableOrUnknown(
          data['combos_unlocked']!,
          _combosUnlockedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId};
  @override
  ReadingProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressData(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      wordsUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}words_unlocked'],
      )!,
      combosUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}combos_unlocked'],
      )!,
    );
  }

  @override
  $ReadingProgressTable createAlias(String alias) {
    return $ReadingProgressTable(attachedDatabase, alias);
  }
}

class ReadingProgressData extends DataClass
    implements Insertable<ReadingProgressData> {
  final int childId;
  final int wordsUnlocked;

  /// Freigeschaltete Lautverbindungen (Batch-Lernen), Start 2.
  final int combosUnlocked;
  const ReadingProgressData({
    required this.childId,
    required this.wordsUnlocked,
    required this.combosUnlocked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<int>(childId);
    map['words_unlocked'] = Variable<int>(wordsUnlocked);
    map['combos_unlocked'] = Variable<int>(combosUnlocked);
    return map;
  }

  ReadingProgressCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressCompanion(
      childId: Value(childId),
      wordsUnlocked: Value(wordsUnlocked),
      combosUnlocked: Value(combosUnlocked),
    );
  }

  factory ReadingProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressData(
      childId: serializer.fromJson<int>(json['childId']),
      wordsUnlocked: serializer.fromJson<int>(json['wordsUnlocked']),
      combosUnlocked: serializer.fromJson<int>(json['combosUnlocked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'childId': serializer.toJson<int>(childId),
      'wordsUnlocked': serializer.toJson<int>(wordsUnlocked),
      'combosUnlocked': serializer.toJson<int>(combosUnlocked),
    };
  }

  ReadingProgressData copyWith({
    int? childId,
    int? wordsUnlocked,
    int? combosUnlocked,
  }) => ReadingProgressData(
    childId: childId ?? this.childId,
    wordsUnlocked: wordsUnlocked ?? this.wordsUnlocked,
    combosUnlocked: combosUnlocked ?? this.combosUnlocked,
  );
  ReadingProgressData copyWithCompanion(ReadingProgressCompanion data) {
    return ReadingProgressData(
      childId: data.childId.present ? data.childId.value : this.childId,
      wordsUnlocked: data.wordsUnlocked.present
          ? data.wordsUnlocked.value
          : this.wordsUnlocked,
      combosUnlocked: data.combosUnlocked.present
          ? data.combosUnlocked.value
          : this.combosUnlocked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressData(')
          ..write('childId: $childId, ')
          ..write('wordsUnlocked: $wordsUnlocked, ')
          ..write('combosUnlocked: $combosUnlocked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(childId, wordsUnlocked, combosUnlocked);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressData &&
          other.childId == this.childId &&
          other.wordsUnlocked == this.wordsUnlocked &&
          other.combosUnlocked == this.combosUnlocked);
}

class ReadingProgressCompanion extends UpdateCompanion<ReadingProgressData> {
  final Value<int> childId;
  final Value<int> wordsUnlocked;
  final Value<int> combosUnlocked;
  const ReadingProgressCompanion({
    this.childId = const Value.absent(),
    this.wordsUnlocked = const Value.absent(),
    this.combosUnlocked = const Value.absent(),
  });
  ReadingProgressCompanion.insert({
    this.childId = const Value.absent(),
    this.wordsUnlocked = const Value.absent(),
    this.combosUnlocked = const Value.absent(),
  });
  static Insertable<ReadingProgressData> custom({
    Expression<int>? childId,
    Expression<int>? wordsUnlocked,
    Expression<int>? combosUnlocked,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (wordsUnlocked != null) 'words_unlocked': wordsUnlocked,
      if (combosUnlocked != null) 'combos_unlocked': combosUnlocked,
    });
  }

  ReadingProgressCompanion copyWith({
    Value<int>? childId,
    Value<int>? wordsUnlocked,
    Value<int>? combosUnlocked,
  }) {
    return ReadingProgressCompanion(
      childId: childId ?? this.childId,
      wordsUnlocked: wordsUnlocked ?? this.wordsUnlocked,
      combosUnlocked: combosUnlocked ?? this.combosUnlocked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (wordsUnlocked.present) {
      map['words_unlocked'] = Variable<int>(wordsUnlocked.value);
    }
    if (combosUnlocked.present) {
      map['combos_unlocked'] = Variable<int>(combosUnlocked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressCompanion(')
          ..write('childId: $childId, ')
          ..write('wordsUnlocked: $wordsUnlocked, ')
          ..write('combosUnlocked: $combosUnlocked')
          ..write(')'))
        .toString();
  }
}

class $MathSkillsTable extends MathSkills
    with TableInfo<$MathSkillsTable, MathSkill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MathSkillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _moduleMeta = const VerificationMeta('module');
  @override
  late final GeneratedColumn<String> module = GeneratedColumn<String>(
    'module',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _correctStreakMeta = const VerificationMeta(
    'correctStreak',
  );
  @override
  late final GeneratedColumn<int> correctStreak = GeneratedColumn<int>(
    'correct_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wrongStreakMeta = const VerificationMeta(
    'wrongStreak',
  );
  @override
  late final GeneratedColumn<int> wrongStreak = GeneratedColumn<int>(
    'wrong_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    childId,
    module,
    level,
    correctStreak,
    wrongStreak,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'math_skills';
  @override
  VerificationContext validateIntegrity(
    Insertable<MathSkill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('module')) {
      context.handle(
        _moduleMeta,
        module.isAcceptableOrUnknown(data['module']!, _moduleMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('correct_streak')) {
      context.handle(
        _correctStreakMeta,
        correctStreak.isAcceptableOrUnknown(
          data['correct_streak']!,
          _correctStreakMeta,
        ),
      );
    }
    if (data.containsKey('wrong_streak')) {
      context.handle(
        _wrongStreakMeta,
        wrongStreak.isAcceptableOrUnknown(
          data['wrong_streak']!,
          _wrongStreakMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, module};
  @override
  MathSkill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MathSkill(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      module: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      correctStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_streak'],
      )!,
      wrongStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_streak'],
      )!,
    );
  }

  @override
  $MathSkillsTable createAlias(String alias) {
    return $MathSkillsTable(attachedDatabase, alias);
  }
}

class MathSkill extends DataClass implements Insertable<MathSkill> {
  final int childId;

  /// "ziffern" | "zehner" | "addieren" | "subtrahieren".
  final String module;
  final int level;
  final int correctStreak;
  final int wrongStreak;
  const MathSkill({
    required this.childId,
    required this.module,
    required this.level,
    required this.correctStreak,
    required this.wrongStreak,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<int>(childId);
    map['module'] = Variable<String>(module);
    map['level'] = Variable<int>(level);
    map['correct_streak'] = Variable<int>(correctStreak);
    map['wrong_streak'] = Variable<int>(wrongStreak);
    return map;
  }

  MathSkillsCompanion toCompanion(bool nullToAbsent) {
    return MathSkillsCompanion(
      childId: Value(childId),
      module: Value(module),
      level: Value(level),
      correctStreak: Value(correctStreak),
      wrongStreak: Value(wrongStreak),
    );
  }

  factory MathSkill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MathSkill(
      childId: serializer.fromJson<int>(json['childId']),
      module: serializer.fromJson<String>(json['module']),
      level: serializer.fromJson<int>(json['level']),
      correctStreak: serializer.fromJson<int>(json['correctStreak']),
      wrongStreak: serializer.fromJson<int>(json['wrongStreak']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'childId': serializer.toJson<int>(childId),
      'module': serializer.toJson<String>(module),
      'level': serializer.toJson<int>(level),
      'correctStreak': serializer.toJson<int>(correctStreak),
      'wrongStreak': serializer.toJson<int>(wrongStreak),
    };
  }

  MathSkill copyWith({
    int? childId,
    String? module,
    int? level,
    int? correctStreak,
    int? wrongStreak,
  }) => MathSkill(
    childId: childId ?? this.childId,
    module: module ?? this.module,
    level: level ?? this.level,
    correctStreak: correctStreak ?? this.correctStreak,
    wrongStreak: wrongStreak ?? this.wrongStreak,
  );
  MathSkill copyWithCompanion(MathSkillsCompanion data) {
    return MathSkill(
      childId: data.childId.present ? data.childId.value : this.childId,
      module: data.module.present ? data.module.value : this.module,
      level: data.level.present ? data.level.value : this.level,
      correctStreak: data.correctStreak.present
          ? data.correctStreak.value
          : this.correctStreak,
      wrongStreak: data.wrongStreak.present
          ? data.wrongStreak.value
          : this.wrongStreak,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MathSkill(')
          ..write('childId: $childId, ')
          ..write('module: $module, ')
          ..write('level: $level, ')
          ..write('correctStreak: $correctStreak, ')
          ..write('wrongStreak: $wrongStreak')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(childId, module, level, correctStreak, wrongStreak);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MathSkill &&
          other.childId == this.childId &&
          other.module == this.module &&
          other.level == this.level &&
          other.correctStreak == this.correctStreak &&
          other.wrongStreak == this.wrongStreak);
}

class MathSkillsCompanion extends UpdateCompanion<MathSkill> {
  final Value<int> childId;
  final Value<String> module;
  final Value<int> level;
  final Value<int> correctStreak;
  final Value<int> wrongStreak;
  final Value<int> rowid;
  const MathSkillsCompanion({
    this.childId = const Value.absent(),
    this.module = const Value.absent(),
    this.level = const Value.absent(),
    this.correctStreak = const Value.absent(),
    this.wrongStreak = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MathSkillsCompanion.insert({
    required int childId,
    required String module,
    this.level = const Value.absent(),
    this.correctStreak = const Value.absent(),
    this.wrongStreak = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : childId = Value(childId),
       module = Value(module);
  static Insertable<MathSkill> custom({
    Expression<int>? childId,
    Expression<String>? module,
    Expression<int>? level,
    Expression<int>? correctStreak,
    Expression<int>? wrongStreak,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (module != null) 'module': module,
      if (level != null) 'level': level,
      if (correctStreak != null) 'correct_streak': correctStreak,
      if (wrongStreak != null) 'wrong_streak': wrongStreak,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MathSkillsCompanion copyWith({
    Value<int>? childId,
    Value<String>? module,
    Value<int>? level,
    Value<int>? correctStreak,
    Value<int>? wrongStreak,
    Value<int>? rowid,
  }) {
    return MathSkillsCompanion(
      childId: childId ?? this.childId,
      module: module ?? this.module,
      level: level ?? this.level,
      correctStreak: correctStreak ?? this.correctStreak,
      wrongStreak: wrongStreak ?? this.wrongStreak,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (module.present) {
      map['module'] = Variable<String>(module.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (correctStreak.present) {
      map['correct_streak'] = Variable<int>(correctStreak.value);
    }
    if (wrongStreak.present) {
      map['wrong_streak'] = Variable<int>(wrongStreak.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MathSkillsCompanion(')
          ..write('childId: $childId, ')
          ..write('module: $module, ')
          ..write('level: $level, ')
          ..write('correctStreak: $correctStreak, ')
          ..write('wrongStreak: $wrongStreak, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MathAttemptsTable extends MathAttempts
    with TableInfo<$MathAttemptsTable, MathAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MathAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _moduleMeta = const VerificationMeta('module');
  @override
  late final GeneratedColumn<String> module = GeneratedColumn<String>(
    'module',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _problemMeta = const VerificationMeta(
    'problem',
  );
  @override
  late final GeneratedColumn<String> problem = GeneratedColumn<String>(
    'problem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    module,
    problem,
    correct,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'math_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<MathAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('module')) {
      context.handle(
        _moduleMeta,
        module.isAcceptableOrUnknown(data['module']!, _moduleMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleMeta);
    }
    if (data.containsKey('problem')) {
      context.handle(
        _problemMeta,
        problem.isAcceptableOrUnknown(data['problem']!, _problemMeta),
      );
    } else if (isInserting) {
      context.missing(_problemMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MathAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MathAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      module: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module'],
      )!,
      problem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}problem'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MathAttemptsTable createAlias(String alias) {
    return $MathAttemptsTable(attachedDatabase, alias);
  }
}

class MathAttempt extends DataClass implements Insertable<MathAttempt> {
  final int id;
  final int childId;
  final String module;
  final String problem;
  final bool correct;
  final DateTime createdAt;
  const MathAttempt({
    required this.id,
    required this.childId,
    required this.module,
    required this.problem,
    required this.correct,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['module'] = Variable<String>(module);
    map['problem'] = Variable<String>(problem);
    map['correct'] = Variable<bool>(correct);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MathAttemptsCompanion toCompanion(bool nullToAbsent) {
    return MathAttemptsCompanion(
      id: Value(id),
      childId: Value(childId),
      module: Value(module),
      problem: Value(problem),
      correct: Value(correct),
      createdAt: Value(createdAt),
    );
  }

  factory MathAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MathAttempt(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      module: serializer.fromJson<String>(json['module']),
      problem: serializer.fromJson<String>(json['problem']),
      correct: serializer.fromJson<bool>(json['correct']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'module': serializer.toJson<String>(module),
      'problem': serializer.toJson<String>(problem),
      'correct': serializer.toJson<bool>(correct),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MathAttempt copyWith({
    int? id,
    int? childId,
    String? module,
    String? problem,
    bool? correct,
    DateTime? createdAt,
  }) => MathAttempt(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    module: module ?? this.module,
    problem: problem ?? this.problem,
    correct: correct ?? this.correct,
    createdAt: createdAt ?? this.createdAt,
  );
  MathAttempt copyWithCompanion(MathAttemptsCompanion data) {
    return MathAttempt(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      module: data.module.present ? data.module.value : this.module,
      problem: data.problem.present ? data.problem.value : this.problem,
      correct: data.correct.present ? data.correct.value : this.correct,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MathAttempt(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('module: $module, ')
          ..write('problem: $problem, ')
          ..write('correct: $correct, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, childId, module, problem, correct, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MathAttempt &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.module == this.module &&
          other.problem == this.problem &&
          other.correct == this.correct &&
          other.createdAt == this.createdAt);
}

class MathAttemptsCompanion extends UpdateCompanion<MathAttempt> {
  final Value<int> id;
  final Value<int> childId;
  final Value<String> module;
  final Value<String> problem;
  final Value<bool> correct;
  final Value<DateTime> createdAt;
  const MathAttemptsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.module = const Value.absent(),
    this.problem = const Value.absent(),
    this.correct = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MathAttemptsCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required String module,
    required String problem,
    required bool correct,
    this.createdAt = const Value.absent(),
  }) : childId = Value(childId),
       module = Value(module),
       problem = Value(problem),
       correct = Value(correct);
  static Insertable<MathAttempt> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<String>? module,
    Expression<String>? problem,
    Expression<bool>? correct,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (module != null) 'module': module,
      if (problem != null) 'problem': problem,
      if (correct != null) 'correct': correct,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MathAttemptsCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<String>? module,
    Value<String>? problem,
    Value<bool>? correct,
    Value<DateTime>? createdAt,
  }) {
    return MathAttemptsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      module: module ?? this.module,
      problem: problem ?? this.problem,
      correct: correct ?? this.correct,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (module.present) {
      map['module'] = Variable<String>(module.value);
    }
    if (problem.present) {
      map['problem'] = Variable<String>(problem.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MathAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('module: $module, ')
          ..write('problem: $problem, ')
          ..write('correct: $correct, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NumberProgressTable extends NumberProgress
    with TableInfo<$NumberProgressTable, NumberProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NumberProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<int> value = GeneratedColumn<int>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    defaultValue: const Constant('neu'),
  );
  static const VerificationMeta _boxMeta = const VerificationMeta('box');
  @override
  late final GeneratedColumn<int> box = GeneratedColumn<int>(
    'box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [childId, value, status, box];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'number_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<NumberProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('box')) {
      context.handle(
        _boxMeta,
        box.isAcceptableOrUnknown(data['box']!, _boxMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, value};
  @override
  NumberProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NumberProgressData(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      box: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box'],
      )!,
    );
  }

  @override
  $NumberProgressTable createAlias(String alias) {
    return $NumberProgressTable(attachedDatabase, alias);
  }
}

class NumberProgressData extends DataClass
    implements Insertable<NumberProgressData> {
  final int childId;
  final int value;
  final String status;
  final int box;
  const NumberProgressData({
    required this.childId,
    required this.value,
    required this.status,
    required this.box,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<int>(childId);
    map['value'] = Variable<int>(value);
    map['status'] = Variable<String>(status);
    map['box'] = Variable<int>(box);
    return map;
  }

  NumberProgressCompanion toCompanion(bool nullToAbsent) {
    return NumberProgressCompanion(
      childId: Value(childId),
      value: Value(value),
      status: Value(status),
      box: Value(box),
    );
  }

  factory NumberProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NumberProgressData(
      childId: serializer.fromJson<int>(json['childId']),
      value: serializer.fromJson<int>(json['value']),
      status: serializer.fromJson<String>(json['status']),
      box: serializer.fromJson<int>(json['box']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'childId': serializer.toJson<int>(childId),
      'value': serializer.toJson<int>(value),
      'status': serializer.toJson<String>(status),
      'box': serializer.toJson<int>(box),
    };
  }

  NumberProgressData copyWith({
    int? childId,
    int? value,
    String? status,
    int? box,
  }) => NumberProgressData(
    childId: childId ?? this.childId,
    value: value ?? this.value,
    status: status ?? this.status,
    box: box ?? this.box,
  );
  NumberProgressData copyWithCompanion(NumberProgressCompanion data) {
    return NumberProgressData(
      childId: data.childId.present ? data.childId.value : this.childId,
      value: data.value.present ? data.value.value : this.value,
      status: data.status.present ? data.status.value : this.status,
      box: data.box.present ? data.box.value : this.box,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NumberProgressData(')
          ..write('childId: $childId, ')
          ..write('value: $value, ')
          ..write('status: $status, ')
          ..write('box: $box')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(childId, value, status, box);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NumberProgressData &&
          other.childId == this.childId &&
          other.value == this.value &&
          other.status == this.status &&
          other.box == this.box);
}

class NumberProgressCompanion extends UpdateCompanion<NumberProgressData> {
  final Value<int> childId;
  final Value<int> value;
  final Value<String> status;
  final Value<int> box;
  final Value<int> rowid;
  const NumberProgressCompanion({
    this.childId = const Value.absent(),
    this.value = const Value.absent(),
    this.status = const Value.absent(),
    this.box = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NumberProgressCompanion.insert({
    required int childId,
    required int value,
    this.status = const Value.absent(),
    this.box = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : childId = Value(childId),
       value = Value(value);
  static Insertable<NumberProgressData> custom({
    Expression<int>? childId,
    Expression<int>? value,
    Expression<String>? status,
    Expression<int>? box,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (value != null) 'value': value,
      if (status != null) 'status': status,
      if (box != null) 'box': box,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NumberProgressCompanion copyWith({
    Value<int>? childId,
    Value<int>? value,
    Value<String>? status,
    Value<int>? box,
    Value<int>? rowid,
  }) {
    return NumberProgressCompanion(
      childId: childId ?? this.childId,
      value: value ?? this.value,
      status: status ?? this.status,
      box: box ?? this.box,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (value.present) {
      map['value'] = Variable<int>(value.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (box.present) {
      map['box'] = Variable<int>(box.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NumberProgressCompanion(')
          ..write('childId: $childId, ')
          ..write('value: $value, ')
          ..write('status: $status, ')
          ..write('box: $box, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SectionUnlocksTable extends SectionUnlocks
    with TableInfo<$SectionUnlocksTable, SectionUnlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionUnlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sectionKeyMeta = const VerificationMeta(
    'sectionKey',
  );
  @override
  late final GeneratedColumn<String> sectionKey = GeneratedColumn<String>(
    'section_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [childId, sectionKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'section_unlocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<SectionUnlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('section_key')) {
      context.handle(
        _sectionKeyMeta,
        sectionKey.isAcceptableOrUnknown(data['section_key']!, _sectionKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {childId, sectionKey};
  @override
  SectionUnlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SectionUnlock(
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      sectionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}section_key'],
      )!,
    );
  }

  @override
  $SectionUnlocksTable createAlias(String alias) {
    return $SectionUnlocksTable(attachedDatabase, alias);
  }
}

class SectionUnlock extends DataClass implements Insertable<SectionUnlock> {
  final int childId;
  final String sectionKey;
  const SectionUnlock({required this.childId, required this.sectionKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['child_id'] = Variable<int>(childId);
    map['section_key'] = Variable<String>(sectionKey);
    return map;
  }

  SectionUnlocksCompanion toCompanion(bool nullToAbsent) {
    return SectionUnlocksCompanion(
      childId: Value(childId),
      sectionKey: Value(sectionKey),
    );
  }

  factory SectionUnlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SectionUnlock(
      childId: serializer.fromJson<int>(json['childId']),
      sectionKey: serializer.fromJson<String>(json['sectionKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'childId': serializer.toJson<int>(childId),
      'sectionKey': serializer.toJson<String>(sectionKey),
    };
  }

  SectionUnlock copyWith({int? childId, String? sectionKey}) => SectionUnlock(
    childId: childId ?? this.childId,
    sectionKey: sectionKey ?? this.sectionKey,
  );
  SectionUnlock copyWithCompanion(SectionUnlocksCompanion data) {
    return SectionUnlock(
      childId: data.childId.present ? data.childId.value : this.childId,
      sectionKey: data.sectionKey.present
          ? data.sectionKey.value
          : this.sectionKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SectionUnlock(')
          ..write('childId: $childId, ')
          ..write('sectionKey: $sectionKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(childId, sectionKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SectionUnlock &&
          other.childId == this.childId &&
          other.sectionKey == this.sectionKey);
}

class SectionUnlocksCompanion extends UpdateCompanion<SectionUnlock> {
  final Value<int> childId;
  final Value<String> sectionKey;
  final Value<int> rowid;
  const SectionUnlocksCompanion({
    this.childId = const Value.absent(),
    this.sectionKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SectionUnlocksCompanion.insert({
    required int childId,
    required String sectionKey,
    this.rowid = const Value.absent(),
  }) : childId = Value(childId),
       sectionKey = Value(sectionKey);
  static Insertable<SectionUnlock> custom({
    Expression<int>? childId,
    Expression<String>? sectionKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (childId != null) 'child_id': childId,
      if (sectionKey != null) 'section_key': sectionKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SectionUnlocksCompanion copyWith({
    Value<int>? childId,
    Value<String>? sectionKey,
    Value<int>? rowid,
  }) {
    return SectionUnlocksCompanion(
      childId: childId ?? this.childId,
      sectionKey: sectionKey ?? this.sectionKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (sectionKey.present) {
      map['section_key'] = Variable<String>(sectionKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionUnlocksCompanion(')
          ..write('childId: $childId, ')
          ..write('sectionKey: $sectionKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FundstueckeTable extends Fundstuecke
    with TableInfo<$FundstueckeTable, Fundstueck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FundstueckeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<int> childId = GeneratedColumn<int>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES children (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _letterMeta = const VerificationMeta('letter');
  @override
  late final GeneratedColumn<String> letter = GeneratedColumn<String>(
    'letter',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    letter,
    filePath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fundstuecke';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fundstueck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('letter')) {
      context.handle(
        _letterMeta,
        letter.isAcceptableOrUnknown(data['letter']!, _letterMeta),
      );
    } else if (isInserting) {
      context.missing(_letterMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fundstueck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fundstueck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}child_id'],
      )!,
      letter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}letter'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FundstueckeTable createAlias(String alias) {
    return $FundstueckeTable(attachedDatabase, alias);
  }
}

class Fundstueck extends DataClass implements Insertable<Fundstueck> {
  final int id;
  final int childId;

  /// Kleingeschriebenes Symbol des gejagten Lauts, z. B. "m".
  final String letter;

  /// Pfad zur gespeicherten Foto-Datei (im App-Dokumente-Ordner).
  final String filePath;
  final DateTime createdAt;
  const Fundstueck({
    required this.id,
    required this.childId,
    required this.letter,
    required this.filePath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<int>(childId);
    map['letter'] = Variable<String>(letter);
    map['file_path'] = Variable<String>(filePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FundstueckeCompanion toCompanion(bool nullToAbsent) {
    return FundstueckeCompanion(
      id: Value(id),
      childId: Value(childId),
      letter: Value(letter),
      filePath: Value(filePath),
      createdAt: Value(createdAt),
    );
  }

  factory Fundstueck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fundstueck(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<int>(json['childId']),
      letter: serializer.fromJson<String>(json['letter']),
      filePath: serializer.fromJson<String>(json['filePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<int>(childId),
      'letter': serializer.toJson<String>(letter),
      'filePath': serializer.toJson<String>(filePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Fundstueck copyWith({
    int? id,
    int? childId,
    String? letter,
    String? filePath,
    DateTime? createdAt,
  }) => Fundstueck(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    letter: letter ?? this.letter,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
  );
  Fundstueck copyWithCompanion(FundstueckeCompanion data) {
    return Fundstueck(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      letter: data.letter.present ? data.letter.value : this.letter,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fundstueck(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('letter: $letter, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, childId, letter, filePath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fundstueck &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.letter == this.letter &&
          other.filePath == this.filePath &&
          other.createdAt == this.createdAt);
}

class FundstueckeCompanion extends UpdateCompanion<Fundstueck> {
  final Value<int> id;
  final Value<int> childId;
  final Value<String> letter;
  final Value<String> filePath;
  final Value<DateTime> createdAt;
  const FundstueckeCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.letter = const Value.absent(),
    this.filePath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FundstueckeCompanion.insert({
    this.id = const Value.absent(),
    required int childId,
    required String letter,
    required String filePath,
    this.createdAt = const Value.absent(),
  }) : childId = Value(childId),
       letter = Value(letter),
       filePath = Value(filePath);
  static Insertable<Fundstueck> custom({
    Expression<int>? id,
    Expression<int>? childId,
    Expression<String>? letter,
    Expression<String>? filePath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (letter != null) 'letter': letter,
      if (filePath != null) 'file_path': filePath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FundstueckeCompanion copyWith({
    Value<int>? id,
    Value<int>? childId,
    Value<String>? letter,
    Value<String>? filePath,
    Value<DateTime>? createdAt,
  }) {
    return FundstueckeCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      letter: letter ?? this.letter,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<int>(childId.value);
    }
    if (letter.present) {
      map['letter'] = Variable<String>(letter.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FundstueckeCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('letter: $letter, ')
          ..write('filePath: $filePath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _metaKeyMeta = const VerificationMeta(
    'metaKey',
  );
  @override
  late final GeneratedColumn<String> metaKey = GeneratedColumn<String>(
    'meta_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intValueMeta = const VerificationMeta(
    'intValue',
  );
  @override
  late final GeneratedColumn<int> intValue = GeneratedColumn<int>(
    'int_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [metaKey, intValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('meta_key')) {
      context.handle(
        _metaKeyMeta,
        metaKey.isAcceptableOrUnknown(data['meta_key']!, _metaKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_metaKeyMeta);
    }
    if (data.containsKey('int_value')) {
      context.handle(
        _intValueMeta,
        intValue.isAcceptableOrUnknown(data['int_value']!, _intValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {metaKey};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      metaKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta_key'],
      )!,
      intValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}int_value'],
      ),
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String metaKey;
  final int? intValue;
  const AppMetaData({required this.metaKey, this.intValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['meta_key'] = Variable<String>(metaKey);
    if (!nullToAbsent || intValue != null) {
      map['int_value'] = Variable<int>(intValue);
    }
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(
      metaKey: Value(metaKey),
      intValue: intValue == null && nullToAbsent
          ? const Value.absent()
          : Value(intValue),
    );
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      metaKey: serializer.fromJson<String>(json['metaKey']),
      intValue: serializer.fromJson<int?>(json['intValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'metaKey': serializer.toJson<String>(metaKey),
      'intValue': serializer.toJson<int?>(intValue),
    };
  }

  AppMetaData copyWith({
    String? metaKey,
    Value<int?> intValue = const Value.absent(),
  }) => AppMetaData(
    metaKey: metaKey ?? this.metaKey,
    intValue: intValue.present ? intValue.value : this.intValue,
  );
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      metaKey: data.metaKey.present ? data.metaKey.value : this.metaKey,
      intValue: data.intValue.present ? data.intValue.value : this.intValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('metaKey: $metaKey, ')
          ..write('intValue: $intValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(metaKey, intValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.metaKey == this.metaKey &&
          other.intValue == this.intValue);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> metaKey;
  final Value<int?> intValue;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.metaKey = const Value.absent(),
    this.intValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String metaKey,
    this.intValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : metaKey = Value(metaKey);
  static Insertable<AppMetaData> custom({
    Expression<String>? metaKey,
    Expression<int>? intValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (metaKey != null) 'meta_key': metaKey,
      if (intValue != null) 'int_value': intValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? metaKey,
    Value<int?>? intValue,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      metaKey: metaKey ?? this.metaKey,
      intValue: intValue ?? this.intValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (metaKey.present) {
      map['meta_key'] = Variable<String>(metaKey.value);
    }
    if (intValue.present) {
      map['int_value'] = Variable<int>(intValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('metaKey: $metaKey, ')
          ..write('intValue: $intValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChildrenTable children = $ChildrenTable(this);
  late final $GraphemesTable graphemes = $GraphemesTable(this);
  late final $GraphemeProgressTable graphemeProgress = $GraphemeProgressTable(
    this,
  );
  late final $ImageAssetsTable imageAssets = $ImageAssetsTable(this);
  late final $WordsTable words = $WordsTable(this);
  late final $WordEnabledTable wordEnabled = $WordEnabledTable(this);
  late final $ReadingProgressTable readingProgress = $ReadingProgressTable(
    this,
  );
  late final $MathSkillsTable mathSkills = $MathSkillsTable(this);
  late final $MathAttemptsTable mathAttempts = $MathAttemptsTable(this);
  late final $NumberProgressTable numberProgress = $NumberProgressTable(this);
  late final $SectionUnlocksTable sectionUnlocks = $SectionUnlocksTable(this);
  late final $FundstueckeTable fundstuecke = $FundstueckeTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    children,
    graphemes,
    graphemeProgress,
    imageAssets,
    words,
    wordEnabled,
    readingProgress,
    mathSkills,
    mathAttempts,
    numberProgress,
    sectionUnlocks,
    fundstuecke,
    appMeta,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'children',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grapheme_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'graphemes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grapheme_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'image_assets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('words', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'children',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_enabled', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'words',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('word_enabled', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'children',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reading_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'children',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('math_skills', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'children',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('math_attempts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'children',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('number_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'children',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('section_unlocks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'children',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fundstuecke', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ChildrenTableCreateCompanionBuilder =
    ChildrenCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> avatar,
      Value<DateTime> createdAt,
    });
typedef $$ChildrenTableUpdateCompanionBuilder =
    ChildrenCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> avatar,
      Value<DateTime> createdAt,
    });

final class $$ChildrenTableReferences
    extends BaseReferences<_$AppDatabase, $ChildrenTable, Child> {
  $$ChildrenTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GraphemeProgressTable, List<GraphemeProgressData>>
  _graphemeProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.graphemeProgress,
    aliasName: 'children__id__grapheme_progress__child_id',
  );

  $$GraphemeProgressTableProcessedTableManager get graphemeProgressRefs {
    final manager = $$GraphemeProgressTableTableManager(
      $_db,
      $_db.graphemeProgress,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _graphemeProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WordEnabledTable, List<WordEnabledData>>
  _wordEnabledRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordEnabled,
    aliasName: 'children__id__word_enabled__child_id',
  );

  $$WordEnabledTableProcessedTableManager get wordEnabledRefs {
    final manager = $$WordEnabledTableTableManager(
      $_db,
      $_db.wordEnabled,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordEnabledRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingProgressTable, List<ReadingProgressData>>
  _readingProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingProgress,
    aliasName: 'children__id__reading_progress__child_id',
  );

  $$ReadingProgressTableProcessedTableManager get readingProgressRefs {
    final manager = $$ReadingProgressTableTableManager(
      $_db,
      $_db.readingProgress,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readingProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MathSkillsTable, List<MathSkill>>
  _mathSkillsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mathSkills,
    aliasName: 'children__id__math_skills__child_id',
  );

  $$MathSkillsTableProcessedTableManager get mathSkillsRefs {
    final manager = $$MathSkillsTableTableManager(
      $_db,
      $_db.mathSkills,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mathSkillsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MathAttemptsTable, List<MathAttempt>>
  _mathAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mathAttempts,
    aliasName: 'children__id__math_attempts__child_id',
  );

  $$MathAttemptsTableProcessedTableManager get mathAttemptsRefs {
    final manager = $$MathAttemptsTableTableManager(
      $_db,
      $_db.mathAttempts,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_mathAttemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$NumberProgressTable, List<NumberProgressData>>
  _numberProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.numberProgress,
    aliasName: 'children__id__number_progress__child_id',
  );

  $$NumberProgressTableProcessedTableManager get numberProgressRefs {
    final manager = $$NumberProgressTableTableManager(
      $_db,
      $_db.numberProgress,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_numberProgressRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SectionUnlocksTable, List<SectionUnlock>>
  _sectionUnlocksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sectionUnlocks,
    aliasName: 'children__id__section_unlocks__child_id',
  );

  $$SectionUnlocksTableProcessedTableManager get sectionUnlocksRefs {
    final manager = $$SectionUnlocksTableTableManager(
      $_db,
      $_db.sectionUnlocks,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sectionUnlocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FundstueckeTable, List<Fundstueck>>
  _fundstueckeRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fundstuecke,
    aliasName: 'children__id__fundstuecke__child_id',
  );

  $$FundstueckeTableProcessedTableManager get fundstueckeRefs {
    final manager = $$FundstueckeTableTableManager(
      $_db,
      $_db.fundstuecke,
    ).filter((f) => f.childId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fundstueckeRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ChildrenTableFilterComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> graphemeProgressRefs(
    Expression<bool> Function($$GraphemeProgressTableFilterComposer f) f,
  ) {
    final $$GraphemeProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.graphemeProgress,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GraphemeProgressTableFilterComposer(
            $db: $db,
            $table: $db.graphemeProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> wordEnabledRefs(
    Expression<bool> Function($$WordEnabledTableFilterComposer f) f,
  ) {
    final $$WordEnabledTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordEnabled,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordEnabledTableFilterComposer(
            $db: $db,
            $table: $db.wordEnabled,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingProgressRefs(
    Expression<bool> Function($$ReadingProgressTableFilterComposer f) f,
  ) {
    final $$ReadingProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingProgress,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingProgressTableFilterComposer(
            $db: $db,
            $table: $db.readingProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mathSkillsRefs(
    Expression<bool> Function($$MathSkillsTableFilterComposer f) f,
  ) {
    final $$MathSkillsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mathSkills,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MathSkillsTableFilterComposer(
            $db: $db,
            $table: $db.mathSkills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mathAttemptsRefs(
    Expression<bool> Function($$MathAttemptsTableFilterComposer f) f,
  ) {
    final $$MathAttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mathAttempts,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MathAttemptsTableFilterComposer(
            $db: $db,
            $table: $db.mathAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> numberProgressRefs(
    Expression<bool> Function($$NumberProgressTableFilterComposer f) f,
  ) {
    final $$NumberProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.numberProgress,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NumberProgressTableFilterComposer(
            $db: $db,
            $table: $db.numberProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sectionUnlocksRefs(
    Expression<bool> Function($$SectionUnlocksTableFilterComposer f) f,
  ) {
    final $$SectionUnlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sectionUnlocks,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionUnlocksTableFilterComposer(
            $db: $db,
            $table: $db.sectionUnlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fundstueckeRefs(
    Expression<bool> Function($$FundstueckeTableFilterComposer f) f,
  ) {
    final $$FundstueckeTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fundstuecke,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundstueckeTableFilterComposer(
            $db: $db,
            $table: $db.fundstuecke,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChildrenTableOrderingComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChildrenTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChildrenTable> {
  $$ChildrenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> graphemeProgressRefs<T extends Object>(
    Expression<T> Function($$GraphemeProgressTableAnnotationComposer a) f,
  ) {
    final $$GraphemeProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.graphemeProgress,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GraphemeProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.graphemeProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> wordEnabledRefs<T extends Object>(
    Expression<T> Function($$WordEnabledTableAnnotationComposer a) f,
  ) {
    final $$WordEnabledTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordEnabled,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordEnabledTableAnnotationComposer(
            $db: $db,
            $table: $db.wordEnabled,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingProgressRefs<T extends Object>(
    Expression<T> Function($$ReadingProgressTableAnnotationComposer a) f,
  ) {
    final $$ReadingProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingProgress,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.readingProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mathSkillsRefs<T extends Object>(
    Expression<T> Function($$MathSkillsTableAnnotationComposer a) f,
  ) {
    final $$MathSkillsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mathSkills,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MathSkillsTableAnnotationComposer(
            $db: $db,
            $table: $db.mathSkills,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mathAttemptsRefs<T extends Object>(
    Expression<T> Function($$MathAttemptsTableAnnotationComposer a) f,
  ) {
    final $$MathAttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mathAttempts,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MathAttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.mathAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> numberProgressRefs<T extends Object>(
    Expression<T> Function($$NumberProgressTableAnnotationComposer a) f,
  ) {
    final $$NumberProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.numberProgress,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NumberProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.numberProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sectionUnlocksRefs<T extends Object>(
    Expression<T> Function($$SectionUnlocksTableAnnotationComposer a) f,
  ) {
    final $$SectionUnlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sectionUnlocks,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionUnlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.sectionUnlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> fundstueckeRefs<T extends Object>(
    Expression<T> Function($$FundstueckeTableAnnotationComposer a) f,
  ) {
    final $$FundstueckeTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fundstuecke,
      getReferencedColumn: (t) => t.childId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundstueckeTableAnnotationComposer(
            $db: $db,
            $table: $db.fundstuecke,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ChildrenTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChildrenTable,
          Child,
          $$ChildrenTableFilterComposer,
          $$ChildrenTableOrderingComposer,
          $$ChildrenTableAnnotationComposer,
          $$ChildrenTableCreateCompanionBuilder,
          $$ChildrenTableUpdateCompanionBuilder,
          (Child, $$ChildrenTableReferences),
          Child,
          PrefetchHooks Function({
            bool graphemeProgressRefs,
            bool wordEnabledRefs,
            bool readingProgressRefs,
            bool mathSkillsRefs,
            bool mathAttemptsRefs,
            bool numberProgressRefs,
            bool sectionUnlocksRefs,
            bool fundstueckeRefs,
          })
        > {
  $$ChildrenTableTableManager(_$AppDatabase db, $ChildrenTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChildrenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChildrenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChildrenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChildrenCompanion(
                id: id,
                name: name,
                avatar: avatar,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> avatar = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ChildrenCompanion.insert(
                id: id,
                name: name,
                avatar: avatar,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ChildrenTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                graphemeProgressRefs = false,
                wordEnabledRefs = false,
                readingProgressRefs = false,
                mathSkillsRefs = false,
                mathAttemptsRefs = false,
                numberProgressRefs = false,
                sectionUnlocksRefs = false,
                fundstueckeRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (graphemeProgressRefs) db.graphemeProgress,
                    if (wordEnabledRefs) db.wordEnabled,
                    if (readingProgressRefs) db.readingProgress,
                    if (mathSkillsRefs) db.mathSkills,
                    if (mathAttemptsRefs) db.mathAttempts,
                    if (numberProgressRefs) db.numberProgress,
                    if (sectionUnlocksRefs) db.sectionUnlocks,
                    if (fundstueckeRefs) db.fundstuecke,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (graphemeProgressRefs)
                        await $_getPrefetchedData<
                          Child,
                          $ChildrenTable,
                          GraphemeProgressData
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._graphemeProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).graphemeProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wordEnabledRefs)
                        await $_getPrefetchedData<
                          Child,
                          $ChildrenTable,
                          WordEnabledData
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._wordEnabledRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).wordEnabledRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readingProgressRefs)
                        await $_getPrefetchedData<
                          Child,
                          $ChildrenTable,
                          ReadingProgressData
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._readingProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).readingProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mathSkillsRefs)
                        await $_getPrefetchedData<
                          Child,
                          $ChildrenTable,
                          MathSkill
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._mathSkillsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).mathSkillsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mathAttemptsRefs)
                        await $_getPrefetchedData<
                          Child,
                          $ChildrenTable,
                          MathAttempt
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._mathAttemptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).mathAttemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (numberProgressRefs)
                        await $_getPrefetchedData<
                          Child,
                          $ChildrenTable,
                          NumberProgressData
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._numberProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).numberProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sectionUnlocksRefs)
                        await $_getPrefetchedData<
                          Child,
                          $ChildrenTable,
                          SectionUnlock
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._sectionUnlocksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).sectionUnlocksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (fundstueckeRefs)
                        await $_getPrefetchedData<
                          Child,
                          $ChildrenTable,
                          Fundstueck
                        >(
                          currentTable: table,
                          referencedTable: $$ChildrenTableReferences
                              ._fundstueckeRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ChildrenTableReferences(
                                db,
                                table,
                                p0,
                              ).fundstueckeRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.childId == item.id,
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

typedef $$ChildrenTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChildrenTable,
      Child,
      $$ChildrenTableFilterComposer,
      $$ChildrenTableOrderingComposer,
      $$ChildrenTableAnnotationComposer,
      $$ChildrenTableCreateCompanionBuilder,
      $$ChildrenTableUpdateCompanionBuilder,
      (Child, $$ChildrenTableReferences),
      Child,
      PrefetchHooks Function({
        bool graphemeProgressRefs,
        bool wordEnabledRefs,
        bool readingProgressRefs,
        bool mathSkillsRefs,
        bool mathAttemptsRefs,
        bool numberProgressRefs,
        bool sectionUnlocksRefs,
        bool fundstueckeRefs,
      })
    >;
typedef $$GraphemesTableCreateCompanionBuilder =
    GraphemesCompanion Function({
      Value<int> id,
      required String symbol,
      required String graphemeKey,
      required String kind,
      Value<String?> sound,
      Value<String?> audioAsset,
      Value<String?> merkhilfe,
      Value<int> sortOrder,
    });
typedef $$GraphemesTableUpdateCompanionBuilder =
    GraphemesCompanion Function({
      Value<int> id,
      Value<String> symbol,
      Value<String> graphemeKey,
      Value<String> kind,
      Value<String?> sound,
      Value<String?> audioAsset,
      Value<String?> merkhilfe,
      Value<int> sortOrder,
    });

final class $$GraphemesTableReferences
    extends BaseReferences<_$AppDatabase, $GraphemesTable, Grapheme> {
  $$GraphemesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GraphemeProgressTable, List<GraphemeProgressData>>
  _graphemeProgressRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.graphemeProgress,
    aliasName: 'graphemes__id__grapheme_progress__grapheme_id',
  );

  $$GraphemeProgressTableProcessedTableManager get graphemeProgressRefs {
    final manager = $$GraphemeProgressTableTableManager(
      $_db,
      $_db.graphemeProgress,
    ).filter((f) => f.graphemeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _graphemeProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GraphemesTableFilterComposer
    extends Composer<_$AppDatabase, $GraphemesTable> {
  $$GraphemesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get graphemeKey => $composableBuilder(
    column: $table.graphemeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioAsset => $composableBuilder(
    column: $table.audioAsset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merkhilfe => $composableBuilder(
    column: $table.merkhilfe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> graphemeProgressRefs(
    Expression<bool> Function($$GraphemeProgressTableFilterComposer f) f,
  ) {
    final $$GraphemeProgressTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.graphemeProgress,
      getReferencedColumn: (t) => t.graphemeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GraphemeProgressTableFilterComposer(
            $db: $db,
            $table: $db.graphemeProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GraphemesTableOrderingComposer
    extends Composer<_$AppDatabase, $GraphemesTable> {
  $$GraphemesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get graphemeKey => $composableBuilder(
    column: $table.graphemeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioAsset => $composableBuilder(
    column: $table.audioAsset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merkhilfe => $composableBuilder(
    column: $table.merkhilfe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GraphemesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GraphemesTable> {
  $$GraphemesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get graphemeKey => $composableBuilder(
    column: $table.graphemeKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get sound =>
      $composableBuilder(column: $table.sound, builder: (column) => column);

  GeneratedColumn<String> get audioAsset => $composableBuilder(
    column: $table.audioAsset,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merkhilfe =>
      $composableBuilder(column: $table.merkhilfe, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> graphemeProgressRefs<T extends Object>(
    Expression<T> Function($$GraphemeProgressTableAnnotationComposer a) f,
  ) {
    final $$GraphemeProgressTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.graphemeProgress,
      getReferencedColumn: (t) => t.graphemeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GraphemeProgressTableAnnotationComposer(
            $db: $db,
            $table: $db.graphemeProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GraphemesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GraphemesTable,
          Grapheme,
          $$GraphemesTableFilterComposer,
          $$GraphemesTableOrderingComposer,
          $$GraphemesTableAnnotationComposer,
          $$GraphemesTableCreateCompanionBuilder,
          $$GraphemesTableUpdateCompanionBuilder,
          (Grapheme, $$GraphemesTableReferences),
          Grapheme,
          PrefetchHooks Function({bool graphemeProgressRefs})
        > {
  $$GraphemesTableTableManager(_$AppDatabase db, $GraphemesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GraphemesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GraphemesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GraphemesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> graphemeKey = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> sound = const Value.absent(),
                Value<String?> audioAsset = const Value.absent(),
                Value<String?> merkhilfe = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => GraphemesCompanion(
                id: id,
                symbol: symbol,
                graphemeKey: graphemeKey,
                kind: kind,
                sound: sound,
                audioAsset: audioAsset,
                merkhilfe: merkhilfe,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String symbol,
                required String graphemeKey,
                required String kind,
                Value<String?> sound = const Value.absent(),
                Value<String?> audioAsset = const Value.absent(),
                Value<String?> merkhilfe = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => GraphemesCompanion.insert(
                id: id,
                symbol: symbol,
                graphemeKey: graphemeKey,
                kind: kind,
                sound: sound,
                audioAsset: audioAsset,
                merkhilfe: merkhilfe,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GraphemesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({graphemeProgressRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (graphemeProgressRefs) db.graphemeProgress,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (graphemeProgressRefs)
                    await $_getPrefetchedData<
                      Grapheme,
                      $GraphemesTable,
                      GraphemeProgressData
                    >(
                      currentTable: table,
                      referencedTable: $$GraphemesTableReferences
                          ._graphemeProgressRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$GraphemesTableReferences(
                            db,
                            table,
                            p0,
                          ).graphemeProgressRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.graphemeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GraphemesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GraphemesTable,
      Grapheme,
      $$GraphemesTableFilterComposer,
      $$GraphemesTableOrderingComposer,
      $$GraphemesTableAnnotationComposer,
      $$GraphemesTableCreateCompanionBuilder,
      $$GraphemesTableUpdateCompanionBuilder,
      (Grapheme, $$GraphemesTableReferences),
      Grapheme,
      PrefetchHooks Function({bool graphemeProgressRefs})
    >;
typedef $$GraphemeProgressTableCreateCompanionBuilder =
    GraphemeProgressCompanion Function({
      required int childId,
      required int graphemeId,
      Value<String> status,
      Value<int> box,
      Value<int> repetitions,
      Value<DateTime?> lastSeen,
      Value<int> rowid,
    });
typedef $$GraphemeProgressTableUpdateCompanionBuilder =
    GraphemeProgressCompanion Function({
      Value<int> childId,
      Value<int> graphemeId,
      Value<String> status,
      Value<int> box,
      Value<int> repetitions,
      Value<DateTime?> lastSeen,
      Value<int> rowid,
    });

final class $$GraphemeProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $GraphemeProgressTable,
          GraphemeProgressData
        > {
  $$GraphemeProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('grapheme_progress__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GraphemesTable _graphemeIdTable(_$AppDatabase db) =>
      db.graphemes.createAlias('grapheme_progress__grapheme_id__graphemes__id');

  $$GraphemesTableProcessedTableManager get graphemeId {
    final $_column = $_itemColumn<int>('grapheme_id')!;

    final manager = $$GraphemesTableTableManager(
      $_db,
      $_db.graphemes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_graphemeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GraphemeProgressTableFilterComposer
    extends Composer<_$AppDatabase, $GraphemeProgressTable> {
  $$GraphemeProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GraphemesTableFilterComposer get graphemeId {
    final $$GraphemesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.graphemeId,
      referencedTable: $db.graphemes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GraphemesTableFilterComposer(
            $db: $db,
            $table: $db.graphemes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GraphemeProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $GraphemeProgressTable> {
  $$GraphemeProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GraphemesTableOrderingComposer get graphemeId {
    final $$GraphemesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.graphemeId,
      referencedTable: $db.graphemes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GraphemesTableOrderingComposer(
            $db: $db,
            $table: $db.graphemes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GraphemeProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $GraphemeProgressTable> {
  $$GraphemeProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get box =>
      $composableBuilder(column: $table.box, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GraphemesTableAnnotationComposer get graphemeId {
    final $$GraphemesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.graphemeId,
      referencedTable: $db.graphemes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GraphemesTableAnnotationComposer(
            $db: $db,
            $table: $db.graphemes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GraphemeProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GraphemeProgressTable,
          GraphemeProgressData,
          $$GraphemeProgressTableFilterComposer,
          $$GraphemeProgressTableOrderingComposer,
          $$GraphemeProgressTableAnnotationComposer,
          $$GraphemeProgressTableCreateCompanionBuilder,
          $$GraphemeProgressTableUpdateCompanionBuilder,
          (GraphemeProgressData, $$GraphemeProgressTableReferences),
          GraphemeProgressData,
          PrefetchHooks Function({bool childId, bool graphemeId})
        > {
  $$GraphemeProgressTableTableManager(
    _$AppDatabase db,
    $GraphemeProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GraphemeProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GraphemeProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GraphemeProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> childId = const Value.absent(),
                Value<int> graphemeId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<DateTime?> lastSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GraphemeProgressCompanion(
                childId: childId,
                graphemeId: graphemeId,
                status: status,
                box: box,
                repetitions: repetitions,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int childId,
                required int graphemeId,
                Value<String> status = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<DateTime?> lastSeen = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GraphemeProgressCompanion.insert(
                childId: childId,
                graphemeId: graphemeId,
                status: status,
                box: box,
                repetitions: repetitions,
                lastSeen: lastSeen,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GraphemeProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false, graphemeId = false}) {
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
                    if (childId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.childId,
                                referencedTable:
                                    $$GraphemeProgressTableReferences
                                        ._childIdTable(db),
                                referencedColumn:
                                    $$GraphemeProgressTableReferences
                                        ._childIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (graphemeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.graphemeId,
                                referencedTable:
                                    $$GraphemeProgressTableReferences
                                        ._graphemeIdTable(db),
                                referencedColumn:
                                    $$GraphemeProgressTableReferences
                                        ._graphemeIdTable(db)
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

typedef $$GraphemeProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GraphemeProgressTable,
      GraphemeProgressData,
      $$GraphemeProgressTableFilterComposer,
      $$GraphemeProgressTableOrderingComposer,
      $$GraphemeProgressTableAnnotationComposer,
      $$GraphemeProgressTableCreateCompanionBuilder,
      $$GraphemeProgressTableUpdateCompanionBuilder,
      (GraphemeProgressData, $$GraphemeProgressTableReferences),
      GraphemeProgressData,
      PrefetchHooks Function({bool childId, bool graphemeId})
    >;
typedef $$ImageAssetsTableCreateCompanionBuilder =
    ImageAssetsCompanion Function({
      Value<int> id,
      required String filePath,
      Value<String?> label,
    });
typedef $$ImageAssetsTableUpdateCompanionBuilder =
    ImageAssetsCompanion Function({
      Value<int> id,
      Value<String> filePath,
      Value<String?> label,
    });

final class $$ImageAssetsTableReferences
    extends BaseReferences<_$AppDatabase, $ImageAssetsTable, ImageAsset> {
  $$ImageAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WordsTable, List<Word>> _wordsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.words,
    aliasName: 'image_assets__id__words__image_id',
  );

  $$WordsTableProcessedTableManager get wordsRefs {
    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.imageId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImageAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $ImageAssetsTable> {
  $$ImageAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wordsRefs(
    Expression<bool> Function($$WordsTableFilterComposer f) f,
  ) {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.imageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImageAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImageAssetsTable> {
  $$ImageAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImageAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImageAssetsTable> {
  $$ImageAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  Expression<T> wordsRefs<T extends Object>(
    Expression<T> Function($$WordsTableAnnotationComposer a) f,
  ) {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.imageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImageAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImageAssetsTable,
          ImageAsset,
          $$ImageAssetsTableFilterComposer,
          $$ImageAssetsTableOrderingComposer,
          $$ImageAssetsTableAnnotationComposer,
          $$ImageAssetsTableCreateCompanionBuilder,
          $$ImageAssetsTableUpdateCompanionBuilder,
          (ImageAsset, $$ImageAssetsTableReferences),
          ImageAsset,
          PrefetchHooks Function({bool wordsRefs})
        > {
  $$ImageAssetsTableTableManager(_$AppDatabase db, $ImageAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImageAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImageAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImageAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> label = const Value.absent(),
              }) => ImageAssetsCompanion(
                id: id,
                filePath: filePath,
                label: label,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String filePath,
                Value<String?> label = const Value.absent(),
              }) => ImageAssetsCompanion.insert(
                id: id,
                filePath: filePath,
                label: label,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImageAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (wordsRefs) db.words],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordsRefs)
                    await $_getPrefetchedData<
                      ImageAsset,
                      $ImageAssetsTable,
                      Word
                    >(
                      currentTable: table,
                      referencedTable: $$ImageAssetsTableReferences
                          ._wordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ImageAssetsTableReferences(db, table, p0).wordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.imageId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ImageAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImageAssetsTable,
      ImageAsset,
      $$ImageAssetsTableFilterComposer,
      $$ImageAssetsTableOrderingComposer,
      $$ImageAssetsTableAnnotationComposer,
      $$ImageAssetsTableCreateCompanionBuilder,
      $$ImageAssetsTableUpdateCompanionBuilder,
      (ImageAsset, $$ImageAssetsTableReferences),
      ImageAsset,
      PrefetchHooks Function({bool wordsRefs})
    >;
typedef $$WordsTableCreateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      required String word,
      Value<int?> imageId,
      Value<bool> isCustom,
    });
typedef $$WordsTableUpdateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      Value<String> word,
      Value<int?> imageId,
      Value<bool> isCustom,
    });

final class $$WordsTableReferences
    extends BaseReferences<_$AppDatabase, $WordsTable, Word> {
  $$WordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ImageAssetsTable _imageIdTable(_$AppDatabase db) =>
      db.imageAssets.createAlias('words__image_id__image_assets__id');

  $$ImageAssetsTableProcessedTableManager? get imageId {
    final $_column = $_itemColumn<int>('image_id');
    if ($_column == null) return null;
    final manager = $$ImageAssetsTableTableManager(
      $_db,
      $_db.imageAssets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_imageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WordEnabledTable, List<WordEnabledData>>
  _wordEnabledRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.wordEnabled,
    aliasName: 'words__id__word_enabled__word_id',
  );

  $$WordEnabledTableProcessedTableManager get wordEnabledRefs {
    final manager = $$WordEnabledTableTableManager(
      $_db,
      $_db.wordEnabled,
    ).filter((f) => f.wordId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_wordEnabledRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  $$ImageAssetsTableFilterComposer get imageId {
    final $$ImageAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.imageId,
      referencedTable: $db.imageAssets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImageAssetsTableFilterComposer(
            $db: $db,
            $table: $db.imageAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> wordEnabledRefs(
    Expression<bool> Function($$WordEnabledTableFilterComposer f) f,
  ) {
    final $$WordEnabledTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordEnabled,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordEnabledTableFilterComposer(
            $db: $db,
            $table: $db.wordEnabled,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImageAssetsTableOrderingComposer get imageId {
    final $$ImageAssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.imageId,
      referencedTable: $db.imageAssets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImageAssetsTableOrderingComposer(
            $db: $db,
            $table: $db.imageAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  $$ImageAssetsTableAnnotationComposer get imageId {
    final $$ImageAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.imageId,
      referencedTable: $db.imageAssets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImageAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.imageAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> wordEnabledRefs<T extends Object>(
    Expression<T> Function($$WordEnabledTableAnnotationComposer a) f,
  ) {
    final $$WordEnabledTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.wordEnabled,
      getReferencedColumn: (t) => t.wordId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordEnabledTableAnnotationComposer(
            $db: $db,
            $table: $db.wordEnabled,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          Word,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (Word, $$WordsTableReferences),
          Word,
          PrefetchHooks Function({bool imageId, bool wordEnabledRefs})
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<int?> imageId = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                word: word,
                imageId: imageId,
                isCustom: isCustom,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String word,
                Value<int?> imageId = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                word: word,
                imageId: imageId,
                isCustom: isCustom,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$WordsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({imageId = false, wordEnabledRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (wordEnabledRefs) db.wordEnabled],
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
                    if (imageId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.imageId,
                                referencedTable: $$WordsTableReferences
                                    ._imageIdTable(db),
                                referencedColumn: $$WordsTableReferences
                                    ._imageIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (wordEnabledRefs)
                    await $_getPrefetchedData<
                      Word,
                      $WordsTable,
                      WordEnabledData
                    >(
                      currentTable: table,
                      referencedTable: $$WordsTableReferences
                          ._wordEnabledRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WordsTableReferences(db, table, p0).wordEnabledRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.wordId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      Word,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (Word, $$WordsTableReferences),
      Word,
      PrefetchHooks Function({bool imageId, bool wordEnabledRefs})
    >;
typedef $$WordEnabledTableCreateCompanionBuilder =
    WordEnabledCompanion Function({
      required int childId,
      required int wordId,
      Value<int> rowid,
    });
typedef $$WordEnabledTableUpdateCompanionBuilder =
    WordEnabledCompanion Function({
      Value<int> childId,
      Value<int> wordId,
      Value<int> rowid,
    });

final class $$WordEnabledTableReferences
    extends BaseReferences<_$AppDatabase, $WordEnabledTable, WordEnabledData> {
  $$WordEnabledTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('word_enabled__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WordsTable _wordIdTable(_$AppDatabase db) =>
      db.words.createAlias('word_enabled__word_id__words__id');

  $$WordsTableProcessedTableManager get wordId {
    final $_column = $_itemColumn<int>('word_id')!;

    final manager = $$WordsTableTableManager(
      $_db,
      $_db.words,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wordIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WordEnabledTableFilterComposer
    extends Composer<_$AppDatabase, $WordEnabledTable> {
  $$WordEnabledTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableFilterComposer get wordId {
    final $$WordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableFilterComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordEnabledTableOrderingComposer
    extends Composer<_$AppDatabase, $WordEnabledTable> {
  $$WordEnabledTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableOrderingComposer get wordId {
    final $$WordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableOrderingComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordEnabledTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordEnabledTable> {
  $$WordEnabledTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WordsTableAnnotationComposer get wordId {
    final $$WordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wordId,
      referencedTable: $db.words,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WordsTableAnnotationComposer(
            $db: $db,
            $table: $db.words,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WordEnabledTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordEnabledTable,
          WordEnabledData,
          $$WordEnabledTableFilterComposer,
          $$WordEnabledTableOrderingComposer,
          $$WordEnabledTableAnnotationComposer,
          $$WordEnabledTableCreateCompanionBuilder,
          $$WordEnabledTableUpdateCompanionBuilder,
          (WordEnabledData, $$WordEnabledTableReferences),
          WordEnabledData,
          PrefetchHooks Function({bool childId, bool wordId})
        > {
  $$WordEnabledTableTableManager(_$AppDatabase db, $WordEnabledTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordEnabledTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordEnabledTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordEnabledTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> childId = const Value.absent(),
                Value<int> wordId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WordEnabledCompanion(
                childId: childId,
                wordId: wordId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int childId,
                required int wordId,
                Value<int> rowid = const Value.absent(),
              }) => WordEnabledCompanion.insert(
                childId: childId,
                wordId: wordId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WordEnabledTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false, wordId = false}) {
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
                    if (childId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.childId,
                                referencedTable: $$WordEnabledTableReferences
                                    ._childIdTable(db),
                                referencedColumn: $$WordEnabledTableReferences
                                    ._childIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (wordId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wordId,
                                referencedTable: $$WordEnabledTableReferences
                                    ._wordIdTable(db),
                                referencedColumn: $$WordEnabledTableReferences
                                    ._wordIdTable(db)
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

typedef $$WordEnabledTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordEnabledTable,
      WordEnabledData,
      $$WordEnabledTableFilterComposer,
      $$WordEnabledTableOrderingComposer,
      $$WordEnabledTableAnnotationComposer,
      $$WordEnabledTableCreateCompanionBuilder,
      $$WordEnabledTableUpdateCompanionBuilder,
      (WordEnabledData, $$WordEnabledTableReferences),
      WordEnabledData,
      PrefetchHooks Function({bool childId, bool wordId})
    >;
typedef $$ReadingProgressTableCreateCompanionBuilder =
    ReadingProgressCompanion Function({
      Value<int> childId,
      Value<int> wordsUnlocked,
      Value<int> combosUnlocked,
    });
typedef $$ReadingProgressTableUpdateCompanionBuilder =
    ReadingProgressCompanion Function({
      Value<int> childId,
      Value<int> wordsUnlocked,
      Value<int> combosUnlocked,
    });

final class $$ReadingProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReadingProgressTable,
          ReadingProgressData
        > {
  $$ReadingProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('reading_progress__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingProgressTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get wordsUnlocked => $composableBuilder(
    column: $table.wordsUnlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get combosUnlocked => $composableBuilder(
    column: $table.combosUnlocked,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get wordsUnlocked => $composableBuilder(
    column: $table.wordsUnlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get combosUnlocked => $composableBuilder(
    column: $table.combosUnlocked,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressTable> {
  $$ReadingProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get wordsUnlocked => $composableBuilder(
    column: $table.wordsUnlocked,
    builder: (column) => column,
  );

  GeneratedColumn<int> get combosUnlocked => $composableBuilder(
    column: $table.combosUnlocked,
    builder: (column) => column,
  );

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingProgressTable,
          ReadingProgressData,
          $$ReadingProgressTableFilterComposer,
          $$ReadingProgressTableOrderingComposer,
          $$ReadingProgressTableAnnotationComposer,
          $$ReadingProgressTableCreateCompanionBuilder,
          $$ReadingProgressTableUpdateCompanionBuilder,
          (ReadingProgressData, $$ReadingProgressTableReferences),
          ReadingProgressData,
          PrefetchHooks Function({bool childId})
        > {
  $$ReadingProgressTableTableManager(
    _$AppDatabase db,
    $ReadingProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> childId = const Value.absent(),
                Value<int> wordsUnlocked = const Value.absent(),
                Value<int> combosUnlocked = const Value.absent(),
              }) => ReadingProgressCompanion(
                childId: childId,
                wordsUnlocked: wordsUnlocked,
                combosUnlocked: combosUnlocked,
              ),
          createCompanionCallback:
              ({
                Value<int> childId = const Value.absent(),
                Value<int> wordsUnlocked = const Value.absent(),
                Value<int> combosUnlocked = const Value.absent(),
              }) => ReadingProgressCompanion.insert(
                childId: childId,
                wordsUnlocked: wordsUnlocked,
                combosUnlocked: combosUnlocked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadingProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.childId,
                                referencedTable:
                                    $$ReadingProgressTableReferences
                                        ._childIdTable(db),
                                referencedColumn:
                                    $$ReadingProgressTableReferences
                                        ._childIdTable(db)
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

typedef $$ReadingProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingProgressTable,
      ReadingProgressData,
      $$ReadingProgressTableFilterComposer,
      $$ReadingProgressTableOrderingComposer,
      $$ReadingProgressTableAnnotationComposer,
      $$ReadingProgressTableCreateCompanionBuilder,
      $$ReadingProgressTableUpdateCompanionBuilder,
      (ReadingProgressData, $$ReadingProgressTableReferences),
      ReadingProgressData,
      PrefetchHooks Function({bool childId})
    >;
typedef $$MathSkillsTableCreateCompanionBuilder =
    MathSkillsCompanion Function({
      required int childId,
      required String module,
      Value<int> level,
      Value<int> correctStreak,
      Value<int> wrongStreak,
      Value<int> rowid,
    });
typedef $$MathSkillsTableUpdateCompanionBuilder =
    MathSkillsCompanion Function({
      Value<int> childId,
      Value<String> module,
      Value<int> level,
      Value<int> correctStreak,
      Value<int> wrongStreak,
      Value<int> rowid,
    });

final class $$MathSkillsTableReferences
    extends BaseReferences<_$AppDatabase, $MathSkillsTable, MathSkill> {
  $$MathSkillsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('math_skills__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MathSkillsTableFilterComposer
    extends Composer<_$AppDatabase, $MathSkillsTable> {
  $$MathSkillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctStreak => $composableBuilder(
    column: $table.correctStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongStreak => $composableBuilder(
    column: $table.wrongStreak,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MathSkillsTableOrderingComposer
    extends Composer<_$AppDatabase, $MathSkillsTable> {
  $$MathSkillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctStreak => $composableBuilder(
    column: $table.correctStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongStreak => $composableBuilder(
    column: $table.wrongStreak,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MathSkillsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MathSkillsTable> {
  $$MathSkillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get module =>
      $composableBuilder(column: $table.module, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get correctStreak => $composableBuilder(
    column: $table.correctStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wrongStreak => $composableBuilder(
    column: $table.wrongStreak,
    builder: (column) => column,
  );

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MathSkillsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MathSkillsTable,
          MathSkill,
          $$MathSkillsTableFilterComposer,
          $$MathSkillsTableOrderingComposer,
          $$MathSkillsTableAnnotationComposer,
          $$MathSkillsTableCreateCompanionBuilder,
          $$MathSkillsTableUpdateCompanionBuilder,
          (MathSkill, $$MathSkillsTableReferences),
          MathSkill,
          PrefetchHooks Function({bool childId})
        > {
  $$MathSkillsTableTableManager(_$AppDatabase db, $MathSkillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MathSkillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MathSkillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MathSkillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> childId = const Value.absent(),
                Value<String> module = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> correctStreak = const Value.absent(),
                Value<int> wrongStreak = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MathSkillsCompanion(
                childId: childId,
                module: module,
                level: level,
                correctStreak: correctStreak,
                wrongStreak: wrongStreak,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int childId,
                required String module,
                Value<int> level = const Value.absent(),
                Value<int> correctStreak = const Value.absent(),
                Value<int> wrongStreak = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MathSkillsCompanion.insert(
                childId: childId,
                module: module,
                level: level,
                correctStreak: correctStreak,
                wrongStreak: wrongStreak,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MathSkillsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.childId,
                                referencedTable: $$MathSkillsTableReferences
                                    ._childIdTable(db),
                                referencedColumn: $$MathSkillsTableReferences
                                    ._childIdTable(db)
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

typedef $$MathSkillsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MathSkillsTable,
      MathSkill,
      $$MathSkillsTableFilterComposer,
      $$MathSkillsTableOrderingComposer,
      $$MathSkillsTableAnnotationComposer,
      $$MathSkillsTableCreateCompanionBuilder,
      $$MathSkillsTableUpdateCompanionBuilder,
      (MathSkill, $$MathSkillsTableReferences),
      MathSkill,
      PrefetchHooks Function({bool childId})
    >;
typedef $$MathAttemptsTableCreateCompanionBuilder =
    MathAttemptsCompanion Function({
      Value<int> id,
      required int childId,
      required String module,
      required String problem,
      required bool correct,
      Value<DateTime> createdAt,
    });
typedef $$MathAttemptsTableUpdateCompanionBuilder =
    MathAttemptsCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<String> module,
      Value<String> problem,
      Value<bool> correct,
      Value<DateTime> createdAt,
    });

final class $$MathAttemptsTableReferences
    extends BaseReferences<_$AppDatabase, $MathAttemptsTable, MathAttempt> {
  $$MathAttemptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('math_attempts__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MathAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $MathAttemptsTable> {
  $$MathAttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get problem => $composableBuilder(
    column: $table.problem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MathAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $MathAttemptsTable> {
  $$MathAttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get problem => $composableBuilder(
    column: $table.problem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MathAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MathAttemptsTable> {
  $$MathAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get module =>
      $composableBuilder(column: $table.module, builder: (column) => column);

  GeneratedColumn<String> get problem =>
      $composableBuilder(column: $table.problem, builder: (column) => column);

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MathAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MathAttemptsTable,
          MathAttempt,
          $$MathAttemptsTableFilterComposer,
          $$MathAttemptsTableOrderingComposer,
          $$MathAttemptsTableAnnotationComposer,
          $$MathAttemptsTableCreateCompanionBuilder,
          $$MathAttemptsTableUpdateCompanionBuilder,
          (MathAttempt, $$MathAttemptsTableReferences),
          MathAttempt,
          PrefetchHooks Function({bool childId})
        > {
  $$MathAttemptsTableTableManager(_$AppDatabase db, $MathAttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MathAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MathAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MathAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<String> module = const Value.absent(),
                Value<String> problem = const Value.absent(),
                Value<bool> correct = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MathAttemptsCompanion(
                id: id,
                childId: childId,
                module: module,
                problem: problem,
                correct: correct,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required String module,
                required String problem,
                required bool correct,
                Value<DateTime> createdAt = const Value.absent(),
              }) => MathAttemptsCompanion.insert(
                id: id,
                childId: childId,
                module: module,
                problem: problem,
                correct: correct,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MathAttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.childId,
                                referencedTable: $$MathAttemptsTableReferences
                                    ._childIdTable(db),
                                referencedColumn: $$MathAttemptsTableReferences
                                    ._childIdTable(db)
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

typedef $$MathAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MathAttemptsTable,
      MathAttempt,
      $$MathAttemptsTableFilterComposer,
      $$MathAttemptsTableOrderingComposer,
      $$MathAttemptsTableAnnotationComposer,
      $$MathAttemptsTableCreateCompanionBuilder,
      $$MathAttemptsTableUpdateCompanionBuilder,
      (MathAttempt, $$MathAttemptsTableReferences),
      MathAttempt,
      PrefetchHooks Function({bool childId})
    >;
typedef $$NumberProgressTableCreateCompanionBuilder =
    NumberProgressCompanion Function({
      required int childId,
      required int value,
      Value<String> status,
      Value<int> box,
      Value<int> rowid,
    });
typedef $$NumberProgressTableUpdateCompanionBuilder =
    NumberProgressCompanion Function({
      Value<int> childId,
      Value<int> value,
      Value<String> status,
      Value<int> box,
      Value<int> rowid,
    });

final class $$NumberProgressTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NumberProgressTable,
          NumberProgressData
        > {
  $$NumberProgressTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('number_progress__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NumberProgressTableFilterComposer
    extends Composer<_$AppDatabase, $NumberProgressTable> {
  $$NumberProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NumberProgressTableOrderingComposer
    extends Composer<_$AppDatabase, $NumberProgressTable> {
  $$NumberProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NumberProgressTableAnnotationComposer
    extends Composer<_$AppDatabase, $NumberProgressTable> {
  $$NumberProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get box =>
      $composableBuilder(column: $table.box, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NumberProgressTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NumberProgressTable,
          NumberProgressData,
          $$NumberProgressTableFilterComposer,
          $$NumberProgressTableOrderingComposer,
          $$NumberProgressTableAnnotationComposer,
          $$NumberProgressTableCreateCompanionBuilder,
          $$NumberProgressTableUpdateCompanionBuilder,
          (NumberProgressData, $$NumberProgressTableReferences),
          NumberProgressData,
          PrefetchHooks Function({bool childId})
        > {
  $$NumberProgressTableTableManager(
    _$AppDatabase db,
    $NumberProgressTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NumberProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NumberProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NumberProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> childId = const Value.absent(),
                Value<int> value = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NumberProgressCompanion(
                childId: childId,
                value: value,
                status: status,
                box: box,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int childId,
                required int value,
                Value<String> status = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NumberProgressCompanion.insert(
                childId: childId,
                value: value,
                status: status,
                box: box,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NumberProgressTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.childId,
                                referencedTable: $$NumberProgressTableReferences
                                    ._childIdTable(db),
                                referencedColumn:
                                    $$NumberProgressTableReferences
                                        ._childIdTable(db)
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

typedef $$NumberProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NumberProgressTable,
      NumberProgressData,
      $$NumberProgressTableFilterComposer,
      $$NumberProgressTableOrderingComposer,
      $$NumberProgressTableAnnotationComposer,
      $$NumberProgressTableCreateCompanionBuilder,
      $$NumberProgressTableUpdateCompanionBuilder,
      (NumberProgressData, $$NumberProgressTableReferences),
      NumberProgressData,
      PrefetchHooks Function({bool childId})
    >;
typedef $$SectionUnlocksTableCreateCompanionBuilder =
    SectionUnlocksCompanion Function({
      required int childId,
      required String sectionKey,
      Value<int> rowid,
    });
typedef $$SectionUnlocksTableUpdateCompanionBuilder =
    SectionUnlocksCompanion Function({
      Value<int> childId,
      Value<String> sectionKey,
      Value<int> rowid,
    });

final class $$SectionUnlocksTableReferences
    extends BaseReferences<_$AppDatabase, $SectionUnlocksTable, SectionUnlock> {
  $$SectionUnlocksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('section_unlocks__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SectionUnlocksTableFilterComposer
    extends Composer<_$AppDatabase, $SectionUnlocksTable> {
  $$SectionUnlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sectionKey => $composableBuilder(
    column: $table.sectionKey,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SectionUnlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $SectionUnlocksTable> {
  $$SectionUnlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sectionKey => $composableBuilder(
    column: $table.sectionKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SectionUnlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectionUnlocksTable> {
  $$SectionUnlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sectionKey => $composableBuilder(
    column: $table.sectionKey,
    builder: (column) => column,
  );

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SectionUnlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectionUnlocksTable,
          SectionUnlock,
          $$SectionUnlocksTableFilterComposer,
          $$SectionUnlocksTableOrderingComposer,
          $$SectionUnlocksTableAnnotationComposer,
          $$SectionUnlocksTableCreateCompanionBuilder,
          $$SectionUnlocksTableUpdateCompanionBuilder,
          (SectionUnlock, $$SectionUnlocksTableReferences),
          SectionUnlock,
          PrefetchHooks Function({bool childId})
        > {
  $$SectionUnlocksTableTableManager(
    _$AppDatabase db,
    $SectionUnlocksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectionUnlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectionUnlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectionUnlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> childId = const Value.absent(),
                Value<String> sectionKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SectionUnlocksCompanion(
                childId: childId,
                sectionKey: sectionKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int childId,
                required String sectionKey,
                Value<int> rowid = const Value.absent(),
              }) => SectionUnlocksCompanion.insert(
                childId: childId,
                sectionKey: sectionKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SectionUnlocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.childId,
                                referencedTable: $$SectionUnlocksTableReferences
                                    ._childIdTable(db),
                                referencedColumn:
                                    $$SectionUnlocksTableReferences
                                        ._childIdTable(db)
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

typedef $$SectionUnlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectionUnlocksTable,
      SectionUnlock,
      $$SectionUnlocksTableFilterComposer,
      $$SectionUnlocksTableOrderingComposer,
      $$SectionUnlocksTableAnnotationComposer,
      $$SectionUnlocksTableCreateCompanionBuilder,
      $$SectionUnlocksTableUpdateCompanionBuilder,
      (SectionUnlock, $$SectionUnlocksTableReferences),
      SectionUnlock,
      PrefetchHooks Function({bool childId})
    >;
typedef $$FundstueckeTableCreateCompanionBuilder =
    FundstueckeCompanion Function({
      Value<int> id,
      required int childId,
      required String letter,
      required String filePath,
      Value<DateTime> createdAt,
    });
typedef $$FundstueckeTableUpdateCompanionBuilder =
    FundstueckeCompanion Function({
      Value<int> id,
      Value<int> childId,
      Value<String> letter,
      Value<String> filePath,
      Value<DateTime> createdAt,
    });

final class $$FundstueckeTableReferences
    extends BaseReferences<_$AppDatabase, $FundstueckeTable, Fundstueck> {
  $$FundstueckeTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChildrenTable _childIdTable(_$AppDatabase db) =>
      db.children.createAlias('fundstuecke__child_id__children__id');

  $$ChildrenTableProcessedTableManager get childId {
    final $_column = $_itemColumn<int>('child_id')!;

    final manager = $$ChildrenTableTableManager(
      $_db,
      $_db.children,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_childIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FundstueckeTableFilterComposer
    extends Composer<_$AppDatabase, $FundstueckeTable> {
  $$FundstueckeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get letter => $composableBuilder(
    column: $table.letter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ChildrenTableFilterComposer get childId {
    final $$ChildrenTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableFilterComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FundstueckeTableOrderingComposer
    extends Composer<_$AppDatabase, $FundstueckeTable> {
  $$FundstueckeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get letter => $composableBuilder(
    column: $table.letter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ChildrenTableOrderingComposer get childId {
    final $$ChildrenTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableOrderingComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FundstueckeTableAnnotationComposer
    extends Composer<_$AppDatabase, $FundstueckeTable> {
  $$FundstueckeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get letter =>
      $composableBuilder(column: $table.letter, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ChildrenTableAnnotationComposer get childId {
    final $$ChildrenTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.childId,
      referencedTable: $db.children,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ChildrenTableAnnotationComposer(
            $db: $db,
            $table: $db.children,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FundstueckeTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FundstueckeTable,
          Fundstueck,
          $$FundstueckeTableFilterComposer,
          $$FundstueckeTableOrderingComposer,
          $$FundstueckeTableAnnotationComposer,
          $$FundstueckeTableCreateCompanionBuilder,
          $$FundstueckeTableUpdateCompanionBuilder,
          (Fundstueck, $$FundstueckeTableReferences),
          Fundstueck,
          PrefetchHooks Function({bool childId})
        > {
  $$FundstueckeTableTableManager(_$AppDatabase db, $FundstueckeTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FundstueckeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FundstueckeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FundstueckeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> childId = const Value.absent(),
                Value<String> letter = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FundstueckeCompanion(
                id: id,
                childId: childId,
                letter: letter,
                filePath: filePath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int childId,
                required String letter,
                required String filePath,
                Value<DateTime> createdAt = const Value.absent(),
              }) => FundstueckeCompanion.insert(
                id: id,
                childId: childId,
                letter: letter,
                filePath: filePath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FundstueckeTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({childId = false}) {
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
                    if (childId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.childId,
                                referencedTable: $$FundstueckeTableReferences
                                    ._childIdTable(db),
                                referencedColumn: $$FundstueckeTableReferences
                                    ._childIdTable(db)
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

typedef $$FundstueckeTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FundstueckeTable,
      Fundstueck,
      $$FundstueckeTableFilterComposer,
      $$FundstueckeTableOrderingComposer,
      $$FundstueckeTableAnnotationComposer,
      $$FundstueckeTableCreateCompanionBuilder,
      $$FundstueckeTableUpdateCompanionBuilder,
      (Fundstueck, $$FundstueckeTableReferences),
      Fundstueck,
      PrefetchHooks Function({bool childId})
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String metaKey,
      Value<int?> intValue,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> metaKey,
      Value<int?> intValue,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intValue => $composableBuilder(
    column: $table.intValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get metaKey => $composableBuilder(
    column: $table.metaKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intValue => $composableBuilder(
    column: $table.intValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get metaKey =>
      $composableBuilder(column: $table.metaKey, builder: (column) => column);

  GeneratedColumn<int> get intValue =>
      $composableBuilder(column: $table.intValue, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> metaKey = const Value.absent(),
                Value<int?> intValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(
                metaKey: metaKey,
                intValue: intValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String metaKey,
                Value<int?> intValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion.insert(
                metaKey: metaKey,
                intValue: intValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
      AppMetaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChildrenTableTableManager get children =>
      $$ChildrenTableTableManager(_db, _db.children);
  $$GraphemesTableTableManager get graphemes =>
      $$GraphemesTableTableManager(_db, _db.graphemes);
  $$GraphemeProgressTableTableManager get graphemeProgress =>
      $$GraphemeProgressTableTableManager(_db, _db.graphemeProgress);
  $$ImageAssetsTableTableManager get imageAssets =>
      $$ImageAssetsTableTableManager(_db, _db.imageAssets);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$WordEnabledTableTableManager get wordEnabled =>
      $$WordEnabledTableTableManager(_db, _db.wordEnabled);
  $$ReadingProgressTableTableManager get readingProgress =>
      $$ReadingProgressTableTableManager(_db, _db.readingProgress);
  $$MathSkillsTableTableManager get mathSkills =>
      $$MathSkillsTableTableManager(_db, _db.mathSkills);
  $$MathAttemptsTableTableManager get mathAttempts =>
      $$MathAttemptsTableTableManager(_db, _db.mathAttempts);
  $$NumberProgressTableTableManager get numberProgress =>
      $$NumberProgressTableTableManager(_db, _db.numberProgress);
  $$SectionUnlocksTableTableManager get sectionUnlocks =>
      $$SectionUnlocksTableTableManager(_db, _db.sectionUnlocks);
  $$FundstueckeTableTableManager get fundstuecke =>
      $$FundstueckeTableTableManager(_db, _db.fundstuecke);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
}
