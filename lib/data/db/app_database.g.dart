// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ReleasesTable extends Releases
    with TableInfo<$ReleasesTable, ReleaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReleasesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _groupNameMeta = const VerificationMeta(
    'groupName',
  );
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
    'group_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _releaseDateMeta = const VerificationMeta(
    'releaseDate',
  );
  @override
  late final GeneratedColumn<String> releaseDate = GeneratedColumn<String>(
    'release_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _productUriMeta = const VerificationMeta(
    'productUri',
  );
  @override
  late final GeneratedColumn<String> productUri = GeneratedColumn<String>(
    'product_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardlistUriMeta = const VerificationMeta(
    'cardlistUri',
  );
  @override
  late final GeneratedColumn<String> cardlistUri = GeneratedColumn<String>(
    'cardlist_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardCountMeta = const VerificationMeta(
    'cardCount',
  );
  @override
  late final GeneratedColumn<int> cardCount = GeneratedColumn<int>(
    'card_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortIndexMeta = const VerificationMeta(
    'sortIndex',
  );
  @override
  late final GeneratedColumn<int> sortIndex = GeneratedColumn<int>(
    'sort_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    groupName,
    genre,
    releaseDate,
    imageUrl,
    thumbnailUrl,
    productUri,
    cardlistUri,
    cardCount,
    sortIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'releases';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReleaseRow> instance, {
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
    if (data.containsKey('group_name')) {
      context.handle(
        _groupNameMeta,
        groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta),
      );
    } else if (isInserting) {
      context.missing(_groupNameMeta);
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('release_date')) {
      context.handle(
        _releaseDateMeta,
        releaseDate.isAcceptableOrUnknown(
          data['release_date']!,
          _releaseDateMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('product_uri')) {
      context.handle(
        _productUriMeta,
        productUri.isAcceptableOrUnknown(data['product_uri']!, _productUriMeta),
      );
    }
    if (data.containsKey('cardlist_uri')) {
      context.handle(
        _cardlistUriMeta,
        cardlistUri.isAcceptableOrUnknown(
          data['cardlist_uri']!,
          _cardlistUriMeta,
        ),
      );
    }
    if (data.containsKey('card_count')) {
      context.handle(
        _cardCountMeta,
        cardCount.isAcceptableOrUnknown(data['card_count']!, _cardCountMeta),
      );
    }
    if (data.containsKey('sort_index')) {
      context.handle(
        _sortIndexMeta,
        sortIndex.isAcceptableOrUnknown(data['sort_index']!, _sortIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReleaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReleaseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      groupName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_name'],
      )!,
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      releaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_date'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      ),
      productUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_uri'],
      ),
      cardlistUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cardlist_uri'],
      ),
      cardCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_count'],
      )!,
      sortIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_index'],
      )!,
    );
  }

  @override
  $ReleasesTable createAlias(String alias) {
    return $ReleasesTable(attachedDatabase, alias);
  }
}

class ReleaseRow extends DataClass implements Insertable<ReleaseRow> {
  final String id;
  final String name;
  final String groupName;
  final String? genre;
  final String? releaseDate;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? productUri;
  final String? cardlistUri;
  final int cardCount;

  /// Position in the API's chronological release ordering.
  final int sortIndex;
  const ReleaseRow({
    required this.id,
    required this.name,
    required this.groupName,
    this.genre,
    this.releaseDate,
    this.imageUrl,
    this.thumbnailUrl,
    this.productUri,
    this.cardlistUri,
    required this.cardCount,
    required this.sortIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['group_name'] = Variable<String>(groupName);
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || releaseDate != null) {
      map['release_date'] = Variable<String>(releaseDate);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    if (!nullToAbsent || thumbnailUrl != null) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    }
    if (!nullToAbsent || productUri != null) {
      map['product_uri'] = Variable<String>(productUri);
    }
    if (!nullToAbsent || cardlistUri != null) {
      map['cardlist_uri'] = Variable<String>(cardlistUri);
    }
    map['card_count'] = Variable<int>(cardCount);
    map['sort_index'] = Variable<int>(sortIndex);
    return map;
  }

  ReleasesCompanion toCompanion(bool nullToAbsent) {
    return ReleasesCompanion(
      id: Value(id),
      name: Value(name),
      groupName: Value(groupName),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      releaseDate: releaseDate == null && nullToAbsent
          ? const Value.absent()
          : Value(releaseDate),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      thumbnailUrl: thumbnailUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailUrl),
      productUri: productUri == null && nullToAbsent
          ? const Value.absent()
          : Value(productUri),
      cardlistUri: cardlistUri == null && nullToAbsent
          ? const Value.absent()
          : Value(cardlistUri),
      cardCount: Value(cardCount),
      sortIndex: Value(sortIndex),
    );
  }

  factory ReleaseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReleaseRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      groupName: serializer.fromJson<String>(json['groupName']),
      genre: serializer.fromJson<String?>(json['genre']),
      releaseDate: serializer.fromJson<String?>(json['releaseDate']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      thumbnailUrl: serializer.fromJson<String?>(json['thumbnailUrl']),
      productUri: serializer.fromJson<String?>(json['productUri']),
      cardlistUri: serializer.fromJson<String?>(json['cardlistUri']),
      cardCount: serializer.fromJson<int>(json['cardCount']),
      sortIndex: serializer.fromJson<int>(json['sortIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'groupName': serializer.toJson<String>(groupName),
      'genre': serializer.toJson<String?>(genre),
      'releaseDate': serializer.toJson<String?>(releaseDate),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'thumbnailUrl': serializer.toJson<String?>(thumbnailUrl),
      'productUri': serializer.toJson<String?>(productUri),
      'cardlistUri': serializer.toJson<String?>(cardlistUri),
      'cardCount': serializer.toJson<int>(cardCount),
      'sortIndex': serializer.toJson<int>(sortIndex),
    };
  }

  ReleaseRow copyWith({
    String? id,
    String? name,
    String? groupName,
    Value<String?> genre = const Value.absent(),
    Value<String?> releaseDate = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    Value<String?> thumbnailUrl = const Value.absent(),
    Value<String?> productUri = const Value.absent(),
    Value<String?> cardlistUri = const Value.absent(),
    int? cardCount,
    int? sortIndex,
  }) => ReleaseRow(
    id: id ?? this.id,
    name: name ?? this.name,
    groupName: groupName ?? this.groupName,
    genre: genre.present ? genre.value : this.genre,
    releaseDate: releaseDate.present ? releaseDate.value : this.releaseDate,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    thumbnailUrl: thumbnailUrl.present ? thumbnailUrl.value : this.thumbnailUrl,
    productUri: productUri.present ? productUri.value : this.productUri,
    cardlistUri: cardlistUri.present ? cardlistUri.value : this.cardlistUri,
    cardCount: cardCount ?? this.cardCount,
    sortIndex: sortIndex ?? this.sortIndex,
  );
  ReleaseRow copyWithCompanion(ReleasesCompanion data) {
    return ReleaseRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      genre: data.genre.present ? data.genre.value : this.genre,
      releaseDate: data.releaseDate.present
          ? data.releaseDate.value
          : this.releaseDate,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      productUri: data.productUri.present
          ? data.productUri.value
          : this.productUri,
      cardlistUri: data.cardlistUri.present
          ? data.cardlistUri.value
          : this.cardlistUri,
      cardCount: data.cardCount.present ? data.cardCount.value : this.cardCount,
      sortIndex: data.sortIndex.present ? data.sortIndex.value : this.sortIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReleaseRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupName: $groupName, ')
          ..write('genre: $genre, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('productUri: $productUri, ')
          ..write('cardlistUri: $cardlistUri, ')
          ..write('cardCount: $cardCount, ')
          ..write('sortIndex: $sortIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    groupName,
    genre,
    releaseDate,
    imageUrl,
    thumbnailUrl,
    productUri,
    cardlistUri,
    cardCount,
    sortIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReleaseRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.groupName == this.groupName &&
          other.genre == this.genre &&
          other.releaseDate == this.releaseDate &&
          other.imageUrl == this.imageUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.productUri == this.productUri &&
          other.cardlistUri == this.cardlistUri &&
          other.cardCount == this.cardCount &&
          other.sortIndex == this.sortIndex);
}

class ReleasesCompanion extends UpdateCompanion<ReleaseRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> groupName;
  final Value<String?> genre;
  final Value<String?> releaseDate;
  final Value<String?> imageUrl;
  final Value<String?> thumbnailUrl;
  final Value<String?> productUri;
  final Value<String?> cardlistUri;
  final Value<int> cardCount;
  final Value<int> sortIndex;
  final Value<int> rowid;
  const ReleasesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.groupName = const Value.absent(),
    this.genre = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.productUri = const Value.absent(),
    this.cardlistUri = const Value.absent(),
    this.cardCount = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReleasesCompanion.insert({
    required String id,
    required String name,
    required String groupName,
    this.genre = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.productUri = const Value.absent(),
    this.cardlistUri = const Value.absent(),
    this.cardCount = const Value.absent(),
    this.sortIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       groupName = Value(groupName);
  static Insertable<ReleaseRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? groupName,
    Expression<String>? genre,
    Expression<String>? releaseDate,
    Expression<String>? imageUrl,
    Expression<String>? thumbnailUrl,
    Expression<String>? productUri,
    Expression<String>? cardlistUri,
    Expression<int>? cardCount,
    Expression<int>? sortIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (groupName != null) 'group_name': groupName,
      if (genre != null) 'genre': genre,
      if (releaseDate != null) 'release_date': releaseDate,
      if (imageUrl != null) 'image_url': imageUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (productUri != null) 'product_uri': productUri,
      if (cardlistUri != null) 'cardlist_uri': cardlistUri,
      if (cardCount != null) 'card_count': cardCount,
      if (sortIndex != null) 'sort_index': sortIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReleasesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? groupName,
    Value<String?>? genre,
    Value<String?>? releaseDate,
    Value<String?>? imageUrl,
    Value<String?>? thumbnailUrl,
    Value<String?>? productUri,
    Value<String?>? cardlistUri,
    Value<int>? cardCount,
    Value<int>? sortIndex,
    Value<int>? rowid,
  }) {
    return ReleasesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      groupName: groupName ?? this.groupName,
      genre: genre ?? this.genre,
      releaseDate: releaseDate ?? this.releaseDate,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      productUri: productUri ?? this.productUri,
      cardlistUri: cardlistUri ?? this.cardlistUri,
      cardCount: cardCount ?? this.cardCount,
      sortIndex: sortIndex ?? this.sortIndex,
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
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<String>(releaseDate.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (productUri.present) {
      map['product_uri'] = Variable<String>(productUri.value);
    }
    if (cardlistUri.present) {
      map['cardlist_uri'] = Variable<String>(cardlistUri.value);
    }
    if (cardCount.present) {
      map['card_count'] = Variable<int>(cardCount.value);
    }
    if (sortIndex.present) {
      map['sort_index'] = Variable<int>(sortIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReleasesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupName: $groupName, ')
          ..write('genre: $genre, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('productUri: $productUri, ')
          ..write('cardlistUri: $cardlistUri, ')
          ..write('cardCount: $cardCount, ')
          ..write('sortIndex: $sortIndex, ')
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
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parallelIdMeta = const VerificationMeta(
    'parallelId',
  );
  @override
  late final GeneratedColumn<int> parallelId = GeneratedColumn<int>(
    'parallel_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorsMeta = const VerificationMeta('colors');
  @override
  late final GeneratedColumn<String> colors = GeneratedColumn<String>(
    'colors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _colorCountMeta = const VerificationMeta(
    'colorCount',
  );
  @override
  late final GeneratedColumn<int> colorCount = GeneratedColumn<int>(
    'color_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplementalStarsMeta = const VerificationMeta(
    'supplementalStars',
  );
  @override
  late final GeneratedColumn<int> supplementalStars = GeneratedColumn<int>(
    'supplemental_stars',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playCostMeta = const VerificationMeta(
    'playCost',
  );
  @override
  late final GeneratedColumn<int> playCost = GeneratedColumn<int>(
    'play_cost',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _useCostMeta = const VerificationMeta(
    'useCost',
  );
  @override
  late final GeneratedColumn<int> useCost = GeneratedColumn<int>(
    'use_cost',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<int> cost = GeneratedColumn<int>(
    'cost',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dpMeta = const VerificationMeta('dp');
  @override
  late final GeneratedColumn<int> dp = GeneratedColumn<int>(
    'dp',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _formMeta = const VerificationMeta('form');
  @override
  late final GeneratedColumn<String> form = GeneratedColumn<String>(
    'form',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attributeMeta = const VerificationMeta(
    'attribute',
  );
  @override
  late final GeneratedColumn<String> attribute = GeneratedColumn<String>(
    'attribute',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockIconMeta = const VerificationMeta(
    'blockIcon',
  );
  @override
  late final GeneratedColumn<int> blockIcon = GeneratedColumn<int>(
    'block_icon',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _traitsMeta = const VerificationMeta('traits');
  @override
  late final GeneratedColumn<String> traits = GeneratedColumn<String>(
    'traits',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _keywordsMeta = const VerificationMeta(
    'keywords',
  );
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
    'keywords',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _effectMeta = const VerificationMeta('effect');
  @override
  late final GeneratedColumn<String> effect = GeneratedColumn<String>(
    'effect',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inheritedEffectMeta = const VerificationMeta(
    'inheritedEffect',
  );
  @override
  late final GeneratedColumn<String> inheritedEffect = GeneratedColumn<String>(
    'inherited_effect',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _securityEffectMeta = const VerificationMeta(
    'securityEffect',
  );
  @override
  late final GeneratedColumn<String> securityEffect = GeneratedColumn<String>(
    'security_effect',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _digivolveCostMinMeta = const VerificationMeta(
    'digivolveCostMin',
  );
  @override
  late final GeneratedColumn<int> digivolveCostMin = GeneratedColumn<int>(
    'digivolve_cost_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _digivolveCostMaxMeta = const VerificationMeta(
    'digivolveCostMax',
  );
  @override
  late final GeneratedColumn<int> digivolveCostMax = GeneratedColumn<int>(
    'digivolve_cost_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _digivolutionRequirementsMeta =
      const VerificationMeta('digivolutionRequirements');
  @override
  late final GeneratedColumn<String> digivolutionRequirements =
      GeneratedColumn<String>(
        'digivolution_requirements',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _dualFaceMeta = const VerificationMeta(
    'dualFace',
  );
  @override
  late final GeneratedColumn<String> dualFace = GeneratedColumn<String>(
    'dual_face',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dualCategoryMeta = const VerificationMeta(
    'dualCategory',
  );
  @override
  late final GeneratedColumn<String> dualCategory = GeneratedColumn<String>(
    'dual_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  static const VerificationMeta _faqsMeta = const VerificationMeta('faqs');
  @override
  late final GeneratedColumn<String> faqs = GeneratedColumn<String>(
    'faqs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _errataMeta = const VerificationMeta('errata');
  @override
  late final GeneratedColumn<String> errata = GeneratedColumn<String>(
    'errata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _limitationsMeta = const VerificationMeta(
    'limitations',
  );
  @override
  late final GeneratedColumn<String> limitations = GeneratedColumn<String>(
    'limitations',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _copyLimitMeta = const VerificationMeta(
    'copyLimit',
  );
  @override
  late final GeneratedColumn<int> copyLimit = GeneratedColumn<int>(
    'copy_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _releaseIdsMeta = const VerificationMeta(
    'releaseIds',
  );
  @override
  late final GeneratedColumn<String> releaseIds = GeneratedColumn<String>(
    'release_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _numberSortMeta = const VerificationMeta(
    'numberSort',
  );
  @override
  late final GeneratedColumn<String> numberSort = GeneratedColumn<String>(
    'number_sort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    parallelId,
    name,
    category,
    colors,
    colorCount,
    rarity,
    supplementalStars,
    level,
    playCost,
    useCost,
    cost,
    dp,
    form,
    attribute,
    blockIcon,
    traits,
    keywords,
    effect,
    inheritedEffect,
    securityEffect,
    digivolveCostMin,
    digivolveCostMax,
    digivolutionRequirements,
    dualFace,
    dualCategory,
    notes,
    faqs,
    errata,
    limitations,
    copyLimit,
    imageUrl,
    releaseIds,
    isPrimary,
    numberSort,
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
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('parallel_id')) {
      context.handle(
        _parallelIdMeta,
        parallelId.isAcceptableOrUnknown(data['parallel_id']!, _parallelIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('colors')) {
      context.handle(
        _colorsMeta,
        colors.isAcceptableOrUnknown(data['colors']!, _colorsMeta),
      );
    }
    if (data.containsKey('color_count')) {
      context.handle(
        _colorCountMeta,
        colorCount.isAcceptableOrUnknown(data['color_count']!, _colorCountMeta),
      );
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    }
    if (data.containsKey('supplemental_stars')) {
      context.handle(
        _supplementalStarsMeta,
        supplementalStars.isAcceptableOrUnknown(
          data['supplemental_stars']!,
          _supplementalStarsMeta,
        ),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('play_cost')) {
      context.handle(
        _playCostMeta,
        playCost.isAcceptableOrUnknown(data['play_cost']!, _playCostMeta),
      );
    }
    if (data.containsKey('use_cost')) {
      context.handle(
        _useCostMeta,
        useCost.isAcceptableOrUnknown(data['use_cost']!, _useCostMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('dp')) {
      context.handle(_dpMeta, dp.isAcceptableOrUnknown(data['dp']!, _dpMeta));
    }
    if (data.containsKey('form')) {
      context.handle(
        _formMeta,
        form.isAcceptableOrUnknown(data['form']!, _formMeta),
      );
    }
    if (data.containsKey('attribute')) {
      context.handle(
        _attributeMeta,
        attribute.isAcceptableOrUnknown(data['attribute']!, _attributeMeta),
      );
    }
    if (data.containsKey('block_icon')) {
      context.handle(
        _blockIconMeta,
        blockIcon.isAcceptableOrUnknown(data['block_icon']!, _blockIconMeta),
      );
    }
    if (data.containsKey('traits')) {
      context.handle(
        _traitsMeta,
        traits.isAcceptableOrUnknown(data['traits']!, _traitsMeta),
      );
    }
    if (data.containsKey('keywords')) {
      context.handle(
        _keywordsMeta,
        keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta),
      );
    }
    if (data.containsKey('effect')) {
      context.handle(
        _effectMeta,
        effect.isAcceptableOrUnknown(data['effect']!, _effectMeta),
      );
    }
    if (data.containsKey('inherited_effect')) {
      context.handle(
        _inheritedEffectMeta,
        inheritedEffect.isAcceptableOrUnknown(
          data['inherited_effect']!,
          _inheritedEffectMeta,
        ),
      );
    }
    if (data.containsKey('security_effect')) {
      context.handle(
        _securityEffectMeta,
        securityEffect.isAcceptableOrUnknown(
          data['security_effect']!,
          _securityEffectMeta,
        ),
      );
    }
    if (data.containsKey('digivolve_cost_min')) {
      context.handle(
        _digivolveCostMinMeta,
        digivolveCostMin.isAcceptableOrUnknown(
          data['digivolve_cost_min']!,
          _digivolveCostMinMeta,
        ),
      );
    }
    if (data.containsKey('digivolve_cost_max')) {
      context.handle(
        _digivolveCostMaxMeta,
        digivolveCostMax.isAcceptableOrUnknown(
          data['digivolve_cost_max']!,
          _digivolveCostMaxMeta,
        ),
      );
    }
    if (data.containsKey('digivolution_requirements')) {
      context.handle(
        _digivolutionRequirementsMeta,
        digivolutionRequirements.isAcceptableOrUnknown(
          data['digivolution_requirements']!,
          _digivolutionRequirementsMeta,
        ),
      );
    }
    if (data.containsKey('dual_face')) {
      context.handle(
        _dualFaceMeta,
        dualFace.isAcceptableOrUnknown(data['dual_face']!, _dualFaceMeta),
      );
    }
    if (data.containsKey('dual_category')) {
      context.handle(
        _dualCategoryMeta,
        dualCategory.isAcceptableOrUnknown(
          data['dual_category']!,
          _dualCategoryMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('faqs')) {
      context.handle(
        _faqsMeta,
        faqs.isAcceptableOrUnknown(data['faqs']!, _faqsMeta),
      );
    }
    if (data.containsKey('errata')) {
      context.handle(
        _errataMeta,
        errata.isAcceptableOrUnknown(data['errata']!, _errataMeta),
      );
    }
    if (data.containsKey('limitations')) {
      context.handle(
        _limitationsMeta,
        limitations.isAcceptableOrUnknown(
          data['limitations']!,
          _limitationsMeta,
        ),
      );
    }
    if (data.containsKey('copy_limit')) {
      context.handle(
        _copyLimitMeta,
        copyLimit.isAcceptableOrUnknown(data['copy_limit']!, _copyLimitMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_imageUrlMeta);
    }
    if (data.containsKey('release_ids')) {
      context.handle(
        _releaseIdsMeta,
        releaseIds.isAcceptableOrUnknown(data['release_ids']!, _releaseIdsMeta),
      );
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('number_sort')) {
      context.handle(
        _numberSortMeta,
        numberSort.isAcceptableOrUnknown(data['number_sort']!, _numberSortMeta),
      );
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
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number'],
      )!,
      parallelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parallel_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      colors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colors'],
      )!,
      colorCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_count'],
      )!,
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      ),
      supplementalStars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}supplemental_stars'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      ),
      playCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_cost'],
      ),
      useCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}use_cost'],
      ),
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost'],
      ),
      dp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dp'],
      ),
      form: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form'],
      ),
      attribute: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attribute'],
      ),
      blockIcon: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}block_icon'],
      ),
      traits: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}traits'],
      )!,
      keywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keywords'],
      )!,
      effect: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effect'],
      ),
      inheritedEffect: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inherited_effect'],
      ),
      securityEffect: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}security_effect'],
      ),
      digivolveCostMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}digivolve_cost_min'],
      ),
      digivolveCostMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}digivolve_cost_max'],
      ),
      digivolutionRequirements: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}digivolution_requirements'],
      )!,
      dualFace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dual_face'],
      ),
      dualCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dual_category'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      faqs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}faqs'],
      )!,
      errata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}errata'],
      ),
      limitations: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}limitations'],
      )!,
      copyLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}copy_limit'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      )!,
      releaseIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_ids'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      numberSort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}number_sort'],
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
  final String number;
  final int parallelId;
  final String name;
  final String category;

  /// Delimited colour list, e.g. `|red|blue|`.
  final String colors;
  final int colorCount;
  final String? rarity;
  final int? supplementalStars;
  final int? level;
  final int? playCost;
  final int? useCost;

  /// Play cost, or use cost for Options. Denormalised so a single "cost"
  /// filter and sort works across every category.
  final int? cost;
  final int? dp;
  final String? form;
  final String? attribute;
  final int? blockIcon;
  final String traits;
  final String keywords;
  final String? effect;
  final String? inheritedEffect;
  final String? securityEffect;

  /// Cheapest and priciest digivolution requirement, so a range filter on
  /// digivolve cost does not have to parse the JSON below.
  final int? digivolveCostMin;
  final int? digivolveCostMax;
  final String digivolutionRequirements;

  /// The other face of a dual card, which is both a Digimon and an Option.
  /// Stored as JSON; only the BT-25 dual cards have one.
  final String? dualFace;

  /// [dualFace]'s category, so a category filter matches either face.
  final String? dualCategory;
  final String? notes;
  final String faqs;
  final String? errata;
  final String limitations;

  /// Copies allowed by the restriction list, precomputed for deck validation.
  final int copyLimit;
  final String imageUrl;
  final String releaseIds;

  /// True for the one printing per [number] that the library lists when
  /// alternate arts are collapsed. Usually the `parallelId == 0` printing, but
  /// computed as the lowest [parallelId] so cards that only exist as a
  /// parallel still show up.
  final bool isPrimary;

  /// Collator key that sorts `BT25-002` after `BT25-001` rather than
  /// lexicographically.
  final String numberSort;
  const CardRow({
    required this.id,
    required this.number,
    required this.parallelId,
    required this.name,
    required this.category,
    required this.colors,
    required this.colorCount,
    this.rarity,
    this.supplementalStars,
    this.level,
    this.playCost,
    this.useCost,
    this.cost,
    this.dp,
    this.form,
    this.attribute,
    this.blockIcon,
    required this.traits,
    required this.keywords,
    this.effect,
    this.inheritedEffect,
    this.securityEffect,
    this.digivolveCostMin,
    this.digivolveCostMax,
    required this.digivolutionRequirements,
    this.dualFace,
    this.dualCategory,
    this.notes,
    required this.faqs,
    this.errata,
    required this.limitations,
    required this.copyLimit,
    required this.imageUrl,
    required this.releaseIds,
    required this.isPrimary,
    required this.numberSort,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['number'] = Variable<String>(number);
    map['parallel_id'] = Variable<int>(parallelId);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['colors'] = Variable<String>(colors);
    map['color_count'] = Variable<int>(colorCount);
    if (!nullToAbsent || rarity != null) {
      map['rarity'] = Variable<String>(rarity);
    }
    if (!nullToAbsent || supplementalStars != null) {
      map['supplemental_stars'] = Variable<int>(supplementalStars);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<int>(level);
    }
    if (!nullToAbsent || playCost != null) {
      map['play_cost'] = Variable<int>(playCost);
    }
    if (!nullToAbsent || useCost != null) {
      map['use_cost'] = Variable<int>(useCost);
    }
    if (!nullToAbsent || cost != null) {
      map['cost'] = Variable<int>(cost);
    }
    if (!nullToAbsent || dp != null) {
      map['dp'] = Variable<int>(dp);
    }
    if (!nullToAbsent || form != null) {
      map['form'] = Variable<String>(form);
    }
    if (!nullToAbsent || attribute != null) {
      map['attribute'] = Variable<String>(attribute);
    }
    if (!nullToAbsent || blockIcon != null) {
      map['block_icon'] = Variable<int>(blockIcon);
    }
    map['traits'] = Variable<String>(traits);
    map['keywords'] = Variable<String>(keywords);
    if (!nullToAbsent || effect != null) {
      map['effect'] = Variable<String>(effect);
    }
    if (!nullToAbsent || inheritedEffect != null) {
      map['inherited_effect'] = Variable<String>(inheritedEffect);
    }
    if (!nullToAbsent || securityEffect != null) {
      map['security_effect'] = Variable<String>(securityEffect);
    }
    if (!nullToAbsent || digivolveCostMin != null) {
      map['digivolve_cost_min'] = Variable<int>(digivolveCostMin);
    }
    if (!nullToAbsent || digivolveCostMax != null) {
      map['digivolve_cost_max'] = Variable<int>(digivolveCostMax);
    }
    map['digivolution_requirements'] = Variable<String>(
      digivolutionRequirements,
    );
    if (!nullToAbsent || dualFace != null) {
      map['dual_face'] = Variable<String>(dualFace);
    }
    if (!nullToAbsent || dualCategory != null) {
      map['dual_category'] = Variable<String>(dualCategory);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['faqs'] = Variable<String>(faqs);
    if (!nullToAbsent || errata != null) {
      map['errata'] = Variable<String>(errata);
    }
    map['limitations'] = Variable<String>(limitations);
    map['copy_limit'] = Variable<int>(copyLimit);
    map['image_url'] = Variable<String>(imageUrl);
    map['release_ids'] = Variable<String>(releaseIds);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['number_sort'] = Variable<String>(numberSort);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      number: Value(number),
      parallelId: Value(parallelId),
      name: Value(name),
      category: Value(category),
      colors: Value(colors),
      colorCount: Value(colorCount),
      rarity: rarity == null && nullToAbsent
          ? const Value.absent()
          : Value(rarity),
      supplementalStars: supplementalStars == null && nullToAbsent
          ? const Value.absent()
          : Value(supplementalStars),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      playCost: playCost == null && nullToAbsent
          ? const Value.absent()
          : Value(playCost),
      useCost: useCost == null && nullToAbsent
          ? const Value.absent()
          : Value(useCost),
      cost: cost == null && nullToAbsent ? const Value.absent() : Value(cost),
      dp: dp == null && nullToAbsent ? const Value.absent() : Value(dp),
      form: form == null && nullToAbsent ? const Value.absent() : Value(form),
      attribute: attribute == null && nullToAbsent
          ? const Value.absent()
          : Value(attribute),
      blockIcon: blockIcon == null && nullToAbsent
          ? const Value.absent()
          : Value(blockIcon),
      traits: Value(traits),
      keywords: Value(keywords),
      effect: effect == null && nullToAbsent
          ? const Value.absent()
          : Value(effect),
      inheritedEffect: inheritedEffect == null && nullToAbsent
          ? const Value.absent()
          : Value(inheritedEffect),
      securityEffect: securityEffect == null && nullToAbsent
          ? const Value.absent()
          : Value(securityEffect),
      digivolveCostMin: digivolveCostMin == null && nullToAbsent
          ? const Value.absent()
          : Value(digivolveCostMin),
      digivolveCostMax: digivolveCostMax == null && nullToAbsent
          ? const Value.absent()
          : Value(digivolveCostMax),
      digivolutionRequirements: Value(digivolutionRequirements),
      dualFace: dualFace == null && nullToAbsent
          ? const Value.absent()
          : Value(dualFace),
      dualCategory: dualCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(dualCategory),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      faqs: Value(faqs),
      errata: errata == null && nullToAbsent
          ? const Value.absent()
          : Value(errata),
      limitations: Value(limitations),
      copyLimit: Value(copyLimit),
      imageUrl: Value(imageUrl),
      releaseIds: Value(releaseIds),
      isPrimary: Value(isPrimary),
      numberSort: Value(numberSort),
    );
  }

  factory CardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardRow(
      id: serializer.fromJson<String>(json['id']),
      number: serializer.fromJson<String>(json['number']),
      parallelId: serializer.fromJson<int>(json['parallelId']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      colors: serializer.fromJson<String>(json['colors']),
      colorCount: serializer.fromJson<int>(json['colorCount']),
      rarity: serializer.fromJson<String?>(json['rarity']),
      supplementalStars: serializer.fromJson<int?>(json['supplementalStars']),
      level: serializer.fromJson<int?>(json['level']),
      playCost: serializer.fromJson<int?>(json['playCost']),
      useCost: serializer.fromJson<int?>(json['useCost']),
      cost: serializer.fromJson<int?>(json['cost']),
      dp: serializer.fromJson<int?>(json['dp']),
      form: serializer.fromJson<String?>(json['form']),
      attribute: serializer.fromJson<String?>(json['attribute']),
      blockIcon: serializer.fromJson<int?>(json['blockIcon']),
      traits: serializer.fromJson<String>(json['traits']),
      keywords: serializer.fromJson<String>(json['keywords']),
      effect: serializer.fromJson<String?>(json['effect']),
      inheritedEffect: serializer.fromJson<String?>(json['inheritedEffect']),
      securityEffect: serializer.fromJson<String?>(json['securityEffect']),
      digivolveCostMin: serializer.fromJson<int?>(json['digivolveCostMin']),
      digivolveCostMax: serializer.fromJson<int?>(json['digivolveCostMax']),
      digivolutionRequirements: serializer.fromJson<String>(
        json['digivolutionRequirements'],
      ),
      dualFace: serializer.fromJson<String?>(json['dualFace']),
      dualCategory: serializer.fromJson<String?>(json['dualCategory']),
      notes: serializer.fromJson<String?>(json['notes']),
      faqs: serializer.fromJson<String>(json['faqs']),
      errata: serializer.fromJson<String?>(json['errata']),
      limitations: serializer.fromJson<String>(json['limitations']),
      copyLimit: serializer.fromJson<int>(json['copyLimit']),
      imageUrl: serializer.fromJson<String>(json['imageUrl']),
      releaseIds: serializer.fromJson<String>(json['releaseIds']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      numberSort: serializer.fromJson<String>(json['numberSort']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'number': serializer.toJson<String>(number),
      'parallelId': serializer.toJson<int>(parallelId),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'colors': serializer.toJson<String>(colors),
      'colorCount': serializer.toJson<int>(colorCount),
      'rarity': serializer.toJson<String?>(rarity),
      'supplementalStars': serializer.toJson<int?>(supplementalStars),
      'level': serializer.toJson<int?>(level),
      'playCost': serializer.toJson<int?>(playCost),
      'useCost': serializer.toJson<int?>(useCost),
      'cost': serializer.toJson<int?>(cost),
      'dp': serializer.toJson<int?>(dp),
      'form': serializer.toJson<String?>(form),
      'attribute': serializer.toJson<String?>(attribute),
      'blockIcon': serializer.toJson<int?>(blockIcon),
      'traits': serializer.toJson<String>(traits),
      'keywords': serializer.toJson<String>(keywords),
      'effect': serializer.toJson<String?>(effect),
      'inheritedEffect': serializer.toJson<String?>(inheritedEffect),
      'securityEffect': serializer.toJson<String?>(securityEffect),
      'digivolveCostMin': serializer.toJson<int?>(digivolveCostMin),
      'digivolveCostMax': serializer.toJson<int?>(digivolveCostMax),
      'digivolutionRequirements': serializer.toJson<String>(
        digivolutionRequirements,
      ),
      'dualFace': serializer.toJson<String?>(dualFace),
      'dualCategory': serializer.toJson<String?>(dualCategory),
      'notes': serializer.toJson<String?>(notes),
      'faqs': serializer.toJson<String>(faqs),
      'errata': serializer.toJson<String?>(errata),
      'limitations': serializer.toJson<String>(limitations),
      'copyLimit': serializer.toJson<int>(copyLimit),
      'imageUrl': serializer.toJson<String>(imageUrl),
      'releaseIds': serializer.toJson<String>(releaseIds),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'numberSort': serializer.toJson<String>(numberSort),
    };
  }

  CardRow copyWith({
    String? id,
    String? number,
    int? parallelId,
    String? name,
    String? category,
    String? colors,
    int? colorCount,
    Value<String?> rarity = const Value.absent(),
    Value<int?> supplementalStars = const Value.absent(),
    Value<int?> level = const Value.absent(),
    Value<int?> playCost = const Value.absent(),
    Value<int?> useCost = const Value.absent(),
    Value<int?> cost = const Value.absent(),
    Value<int?> dp = const Value.absent(),
    Value<String?> form = const Value.absent(),
    Value<String?> attribute = const Value.absent(),
    Value<int?> blockIcon = const Value.absent(),
    String? traits,
    String? keywords,
    Value<String?> effect = const Value.absent(),
    Value<String?> inheritedEffect = const Value.absent(),
    Value<String?> securityEffect = const Value.absent(),
    Value<int?> digivolveCostMin = const Value.absent(),
    Value<int?> digivolveCostMax = const Value.absent(),
    String? digivolutionRequirements,
    Value<String?> dualFace = const Value.absent(),
    Value<String?> dualCategory = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? faqs,
    Value<String?> errata = const Value.absent(),
    String? limitations,
    int? copyLimit,
    String? imageUrl,
    String? releaseIds,
    bool? isPrimary,
    String? numberSort,
  }) => CardRow(
    id: id ?? this.id,
    number: number ?? this.number,
    parallelId: parallelId ?? this.parallelId,
    name: name ?? this.name,
    category: category ?? this.category,
    colors: colors ?? this.colors,
    colorCount: colorCount ?? this.colorCount,
    rarity: rarity.present ? rarity.value : this.rarity,
    supplementalStars: supplementalStars.present
        ? supplementalStars.value
        : this.supplementalStars,
    level: level.present ? level.value : this.level,
    playCost: playCost.present ? playCost.value : this.playCost,
    useCost: useCost.present ? useCost.value : this.useCost,
    cost: cost.present ? cost.value : this.cost,
    dp: dp.present ? dp.value : this.dp,
    form: form.present ? form.value : this.form,
    attribute: attribute.present ? attribute.value : this.attribute,
    blockIcon: blockIcon.present ? blockIcon.value : this.blockIcon,
    traits: traits ?? this.traits,
    keywords: keywords ?? this.keywords,
    effect: effect.present ? effect.value : this.effect,
    inheritedEffect: inheritedEffect.present
        ? inheritedEffect.value
        : this.inheritedEffect,
    securityEffect: securityEffect.present
        ? securityEffect.value
        : this.securityEffect,
    digivolveCostMin: digivolveCostMin.present
        ? digivolveCostMin.value
        : this.digivolveCostMin,
    digivolveCostMax: digivolveCostMax.present
        ? digivolveCostMax.value
        : this.digivolveCostMax,
    digivolutionRequirements:
        digivolutionRequirements ?? this.digivolutionRequirements,
    dualFace: dualFace.present ? dualFace.value : this.dualFace,
    dualCategory: dualCategory.present ? dualCategory.value : this.dualCategory,
    notes: notes.present ? notes.value : this.notes,
    faqs: faqs ?? this.faqs,
    errata: errata.present ? errata.value : this.errata,
    limitations: limitations ?? this.limitations,
    copyLimit: copyLimit ?? this.copyLimit,
    imageUrl: imageUrl ?? this.imageUrl,
    releaseIds: releaseIds ?? this.releaseIds,
    isPrimary: isPrimary ?? this.isPrimary,
    numberSort: numberSort ?? this.numberSort,
  );
  CardRow copyWithCompanion(CardsCompanion data) {
    return CardRow(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      parallelId: data.parallelId.present
          ? data.parallelId.value
          : this.parallelId,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      colors: data.colors.present ? data.colors.value : this.colors,
      colorCount: data.colorCount.present
          ? data.colorCount.value
          : this.colorCount,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      supplementalStars: data.supplementalStars.present
          ? data.supplementalStars.value
          : this.supplementalStars,
      level: data.level.present ? data.level.value : this.level,
      playCost: data.playCost.present ? data.playCost.value : this.playCost,
      useCost: data.useCost.present ? data.useCost.value : this.useCost,
      cost: data.cost.present ? data.cost.value : this.cost,
      dp: data.dp.present ? data.dp.value : this.dp,
      form: data.form.present ? data.form.value : this.form,
      attribute: data.attribute.present ? data.attribute.value : this.attribute,
      blockIcon: data.blockIcon.present ? data.blockIcon.value : this.blockIcon,
      traits: data.traits.present ? data.traits.value : this.traits,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
      effect: data.effect.present ? data.effect.value : this.effect,
      inheritedEffect: data.inheritedEffect.present
          ? data.inheritedEffect.value
          : this.inheritedEffect,
      securityEffect: data.securityEffect.present
          ? data.securityEffect.value
          : this.securityEffect,
      digivolveCostMin: data.digivolveCostMin.present
          ? data.digivolveCostMin.value
          : this.digivolveCostMin,
      digivolveCostMax: data.digivolveCostMax.present
          ? data.digivolveCostMax.value
          : this.digivolveCostMax,
      digivolutionRequirements: data.digivolutionRequirements.present
          ? data.digivolutionRequirements.value
          : this.digivolutionRequirements,
      dualFace: data.dualFace.present ? data.dualFace.value : this.dualFace,
      dualCategory: data.dualCategory.present
          ? data.dualCategory.value
          : this.dualCategory,
      notes: data.notes.present ? data.notes.value : this.notes,
      faqs: data.faqs.present ? data.faqs.value : this.faqs,
      errata: data.errata.present ? data.errata.value : this.errata,
      limitations: data.limitations.present
          ? data.limitations.value
          : this.limitations,
      copyLimit: data.copyLimit.present ? data.copyLimit.value : this.copyLimit,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      releaseIds: data.releaseIds.present
          ? data.releaseIds.value
          : this.releaseIds,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      numberSort: data.numberSort.present
          ? data.numberSort.value
          : this.numberSort,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardRow(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('parallelId: $parallelId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('colors: $colors, ')
          ..write('colorCount: $colorCount, ')
          ..write('rarity: $rarity, ')
          ..write('supplementalStars: $supplementalStars, ')
          ..write('level: $level, ')
          ..write('playCost: $playCost, ')
          ..write('useCost: $useCost, ')
          ..write('cost: $cost, ')
          ..write('dp: $dp, ')
          ..write('form: $form, ')
          ..write('attribute: $attribute, ')
          ..write('blockIcon: $blockIcon, ')
          ..write('traits: $traits, ')
          ..write('keywords: $keywords, ')
          ..write('effect: $effect, ')
          ..write('inheritedEffect: $inheritedEffect, ')
          ..write('securityEffect: $securityEffect, ')
          ..write('digivolveCostMin: $digivolveCostMin, ')
          ..write('digivolveCostMax: $digivolveCostMax, ')
          ..write('digivolutionRequirements: $digivolutionRequirements, ')
          ..write('dualFace: $dualFace, ')
          ..write('dualCategory: $dualCategory, ')
          ..write('notes: $notes, ')
          ..write('faqs: $faqs, ')
          ..write('errata: $errata, ')
          ..write('limitations: $limitations, ')
          ..write('copyLimit: $copyLimit, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('releaseIds: $releaseIds, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('numberSort: $numberSort')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    number,
    parallelId,
    name,
    category,
    colors,
    colorCount,
    rarity,
    supplementalStars,
    level,
    playCost,
    useCost,
    cost,
    dp,
    form,
    attribute,
    blockIcon,
    traits,
    keywords,
    effect,
    inheritedEffect,
    securityEffect,
    digivolveCostMin,
    digivolveCostMax,
    digivolutionRequirements,
    dualFace,
    dualCategory,
    notes,
    faqs,
    errata,
    limitations,
    copyLimit,
    imageUrl,
    releaseIds,
    isPrimary,
    numberSort,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardRow &&
          other.id == this.id &&
          other.number == this.number &&
          other.parallelId == this.parallelId &&
          other.name == this.name &&
          other.category == this.category &&
          other.colors == this.colors &&
          other.colorCount == this.colorCount &&
          other.rarity == this.rarity &&
          other.supplementalStars == this.supplementalStars &&
          other.level == this.level &&
          other.playCost == this.playCost &&
          other.useCost == this.useCost &&
          other.cost == this.cost &&
          other.dp == this.dp &&
          other.form == this.form &&
          other.attribute == this.attribute &&
          other.blockIcon == this.blockIcon &&
          other.traits == this.traits &&
          other.keywords == this.keywords &&
          other.effect == this.effect &&
          other.inheritedEffect == this.inheritedEffect &&
          other.securityEffect == this.securityEffect &&
          other.digivolveCostMin == this.digivolveCostMin &&
          other.digivolveCostMax == this.digivolveCostMax &&
          other.digivolutionRequirements == this.digivolutionRequirements &&
          other.dualFace == this.dualFace &&
          other.dualCategory == this.dualCategory &&
          other.notes == this.notes &&
          other.faqs == this.faqs &&
          other.errata == this.errata &&
          other.limitations == this.limitations &&
          other.copyLimit == this.copyLimit &&
          other.imageUrl == this.imageUrl &&
          other.releaseIds == this.releaseIds &&
          other.isPrimary == this.isPrimary &&
          other.numberSort == this.numberSort);
}

class CardsCompanion extends UpdateCompanion<CardRow> {
  final Value<String> id;
  final Value<String> number;
  final Value<int> parallelId;
  final Value<String> name;
  final Value<String> category;
  final Value<String> colors;
  final Value<int> colorCount;
  final Value<String?> rarity;
  final Value<int?> supplementalStars;
  final Value<int?> level;
  final Value<int?> playCost;
  final Value<int?> useCost;
  final Value<int?> cost;
  final Value<int?> dp;
  final Value<String?> form;
  final Value<String?> attribute;
  final Value<int?> blockIcon;
  final Value<String> traits;
  final Value<String> keywords;
  final Value<String?> effect;
  final Value<String?> inheritedEffect;
  final Value<String?> securityEffect;
  final Value<int?> digivolveCostMin;
  final Value<int?> digivolveCostMax;
  final Value<String> digivolutionRequirements;
  final Value<String?> dualFace;
  final Value<String?> dualCategory;
  final Value<String?> notes;
  final Value<String> faqs;
  final Value<String?> errata;
  final Value<String> limitations;
  final Value<int> copyLimit;
  final Value<String> imageUrl;
  final Value<String> releaseIds;
  final Value<bool> isPrimary;
  final Value<String> numberSort;
  final Value<int> rowid;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.parallelId = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.colors = const Value.absent(),
    this.colorCount = const Value.absent(),
    this.rarity = const Value.absent(),
    this.supplementalStars = const Value.absent(),
    this.level = const Value.absent(),
    this.playCost = const Value.absent(),
    this.useCost = const Value.absent(),
    this.cost = const Value.absent(),
    this.dp = const Value.absent(),
    this.form = const Value.absent(),
    this.attribute = const Value.absent(),
    this.blockIcon = const Value.absent(),
    this.traits = const Value.absent(),
    this.keywords = const Value.absent(),
    this.effect = const Value.absent(),
    this.inheritedEffect = const Value.absent(),
    this.securityEffect = const Value.absent(),
    this.digivolveCostMin = const Value.absent(),
    this.digivolveCostMax = const Value.absent(),
    this.digivolutionRequirements = const Value.absent(),
    this.dualFace = const Value.absent(),
    this.dualCategory = const Value.absent(),
    this.notes = const Value.absent(),
    this.faqs = const Value.absent(),
    this.errata = const Value.absent(),
    this.limitations = const Value.absent(),
    this.copyLimit = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.releaseIds = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.numberSort = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String id,
    required String number,
    this.parallelId = const Value.absent(),
    required String name,
    required String category,
    this.colors = const Value.absent(),
    this.colorCount = const Value.absent(),
    this.rarity = const Value.absent(),
    this.supplementalStars = const Value.absent(),
    this.level = const Value.absent(),
    this.playCost = const Value.absent(),
    this.useCost = const Value.absent(),
    this.cost = const Value.absent(),
    this.dp = const Value.absent(),
    this.form = const Value.absent(),
    this.attribute = const Value.absent(),
    this.blockIcon = const Value.absent(),
    this.traits = const Value.absent(),
    this.keywords = const Value.absent(),
    this.effect = const Value.absent(),
    this.inheritedEffect = const Value.absent(),
    this.securityEffect = const Value.absent(),
    this.digivolveCostMin = const Value.absent(),
    this.digivolveCostMax = const Value.absent(),
    this.digivolutionRequirements = const Value.absent(),
    this.dualFace = const Value.absent(),
    this.dualCategory = const Value.absent(),
    this.notes = const Value.absent(),
    this.faqs = const Value.absent(),
    this.errata = const Value.absent(),
    this.limitations = const Value.absent(),
    this.copyLimit = const Value.absent(),
    required String imageUrl,
    this.releaseIds = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.numberSort = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       number = Value(number),
       name = Value(name),
       category = Value(category),
       imageUrl = Value(imageUrl);
  static Insertable<CardRow> custom({
    Expression<String>? id,
    Expression<String>? number,
    Expression<int>? parallelId,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? colors,
    Expression<int>? colorCount,
    Expression<String>? rarity,
    Expression<int>? supplementalStars,
    Expression<int>? level,
    Expression<int>? playCost,
    Expression<int>? useCost,
    Expression<int>? cost,
    Expression<int>? dp,
    Expression<String>? form,
    Expression<String>? attribute,
    Expression<int>? blockIcon,
    Expression<String>? traits,
    Expression<String>? keywords,
    Expression<String>? effect,
    Expression<String>? inheritedEffect,
    Expression<String>? securityEffect,
    Expression<int>? digivolveCostMin,
    Expression<int>? digivolveCostMax,
    Expression<String>? digivolutionRequirements,
    Expression<String>? dualFace,
    Expression<String>? dualCategory,
    Expression<String>? notes,
    Expression<String>? faqs,
    Expression<String>? errata,
    Expression<String>? limitations,
    Expression<int>? copyLimit,
    Expression<String>? imageUrl,
    Expression<String>? releaseIds,
    Expression<bool>? isPrimary,
    Expression<String>? numberSort,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (parallelId != null) 'parallel_id': parallelId,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (colors != null) 'colors': colors,
      if (colorCount != null) 'color_count': colorCount,
      if (rarity != null) 'rarity': rarity,
      if (supplementalStars != null) 'supplemental_stars': supplementalStars,
      if (level != null) 'level': level,
      if (playCost != null) 'play_cost': playCost,
      if (useCost != null) 'use_cost': useCost,
      if (cost != null) 'cost': cost,
      if (dp != null) 'dp': dp,
      if (form != null) 'form': form,
      if (attribute != null) 'attribute': attribute,
      if (blockIcon != null) 'block_icon': blockIcon,
      if (traits != null) 'traits': traits,
      if (keywords != null) 'keywords': keywords,
      if (effect != null) 'effect': effect,
      if (inheritedEffect != null) 'inherited_effect': inheritedEffect,
      if (securityEffect != null) 'security_effect': securityEffect,
      if (digivolveCostMin != null) 'digivolve_cost_min': digivolveCostMin,
      if (digivolveCostMax != null) 'digivolve_cost_max': digivolveCostMax,
      if (digivolutionRequirements != null)
        'digivolution_requirements': digivolutionRequirements,
      if (dualFace != null) 'dual_face': dualFace,
      if (dualCategory != null) 'dual_category': dualCategory,
      if (notes != null) 'notes': notes,
      if (faqs != null) 'faqs': faqs,
      if (errata != null) 'errata': errata,
      if (limitations != null) 'limitations': limitations,
      if (copyLimit != null) 'copy_limit': copyLimit,
      if (imageUrl != null) 'image_url': imageUrl,
      if (releaseIds != null) 'release_ids': releaseIds,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (numberSort != null) 'number_sort': numberSort,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith({
    Value<String>? id,
    Value<String>? number,
    Value<int>? parallelId,
    Value<String>? name,
    Value<String>? category,
    Value<String>? colors,
    Value<int>? colorCount,
    Value<String?>? rarity,
    Value<int?>? supplementalStars,
    Value<int?>? level,
    Value<int?>? playCost,
    Value<int?>? useCost,
    Value<int?>? cost,
    Value<int?>? dp,
    Value<String?>? form,
    Value<String?>? attribute,
    Value<int?>? blockIcon,
    Value<String>? traits,
    Value<String>? keywords,
    Value<String?>? effect,
    Value<String?>? inheritedEffect,
    Value<String?>? securityEffect,
    Value<int?>? digivolveCostMin,
    Value<int?>? digivolveCostMax,
    Value<String>? digivolutionRequirements,
    Value<String?>? dualFace,
    Value<String?>? dualCategory,
    Value<String?>? notes,
    Value<String>? faqs,
    Value<String?>? errata,
    Value<String>? limitations,
    Value<int>? copyLimit,
    Value<String>? imageUrl,
    Value<String>? releaseIds,
    Value<bool>? isPrimary,
    Value<String>? numberSort,
    Value<int>? rowid,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      parallelId: parallelId ?? this.parallelId,
      name: name ?? this.name,
      category: category ?? this.category,
      colors: colors ?? this.colors,
      colorCount: colorCount ?? this.colorCount,
      rarity: rarity ?? this.rarity,
      supplementalStars: supplementalStars ?? this.supplementalStars,
      level: level ?? this.level,
      playCost: playCost ?? this.playCost,
      useCost: useCost ?? this.useCost,
      cost: cost ?? this.cost,
      dp: dp ?? this.dp,
      form: form ?? this.form,
      attribute: attribute ?? this.attribute,
      blockIcon: blockIcon ?? this.blockIcon,
      traits: traits ?? this.traits,
      keywords: keywords ?? this.keywords,
      effect: effect ?? this.effect,
      inheritedEffect: inheritedEffect ?? this.inheritedEffect,
      securityEffect: securityEffect ?? this.securityEffect,
      digivolveCostMin: digivolveCostMin ?? this.digivolveCostMin,
      digivolveCostMax: digivolveCostMax ?? this.digivolveCostMax,
      digivolutionRequirements:
          digivolutionRequirements ?? this.digivolutionRequirements,
      dualFace: dualFace ?? this.dualFace,
      dualCategory: dualCategory ?? this.dualCategory,
      notes: notes ?? this.notes,
      faqs: faqs ?? this.faqs,
      errata: errata ?? this.errata,
      limitations: limitations ?? this.limitations,
      copyLimit: copyLimit ?? this.copyLimit,
      imageUrl: imageUrl ?? this.imageUrl,
      releaseIds: releaseIds ?? this.releaseIds,
      isPrimary: isPrimary ?? this.isPrimary,
      numberSort: numberSort ?? this.numberSort,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (parallelId.present) {
      map['parallel_id'] = Variable<int>(parallelId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (colors.present) {
      map['colors'] = Variable<String>(colors.value);
    }
    if (colorCount.present) {
      map['color_count'] = Variable<int>(colorCount.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (supplementalStars.present) {
      map['supplemental_stars'] = Variable<int>(supplementalStars.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (playCost.present) {
      map['play_cost'] = Variable<int>(playCost.value);
    }
    if (useCost.present) {
      map['use_cost'] = Variable<int>(useCost.value);
    }
    if (cost.present) {
      map['cost'] = Variable<int>(cost.value);
    }
    if (dp.present) {
      map['dp'] = Variable<int>(dp.value);
    }
    if (form.present) {
      map['form'] = Variable<String>(form.value);
    }
    if (attribute.present) {
      map['attribute'] = Variable<String>(attribute.value);
    }
    if (blockIcon.present) {
      map['block_icon'] = Variable<int>(blockIcon.value);
    }
    if (traits.present) {
      map['traits'] = Variable<String>(traits.value);
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (effect.present) {
      map['effect'] = Variable<String>(effect.value);
    }
    if (inheritedEffect.present) {
      map['inherited_effect'] = Variable<String>(inheritedEffect.value);
    }
    if (securityEffect.present) {
      map['security_effect'] = Variable<String>(securityEffect.value);
    }
    if (digivolveCostMin.present) {
      map['digivolve_cost_min'] = Variable<int>(digivolveCostMin.value);
    }
    if (digivolveCostMax.present) {
      map['digivolve_cost_max'] = Variable<int>(digivolveCostMax.value);
    }
    if (digivolutionRequirements.present) {
      map['digivolution_requirements'] = Variable<String>(
        digivolutionRequirements.value,
      );
    }
    if (dualFace.present) {
      map['dual_face'] = Variable<String>(dualFace.value);
    }
    if (dualCategory.present) {
      map['dual_category'] = Variable<String>(dualCategory.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (faqs.present) {
      map['faqs'] = Variable<String>(faqs.value);
    }
    if (errata.present) {
      map['errata'] = Variable<String>(errata.value);
    }
    if (limitations.present) {
      map['limitations'] = Variable<String>(limitations.value);
    }
    if (copyLimit.present) {
      map['copy_limit'] = Variable<int>(copyLimit.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (releaseIds.present) {
      map['release_ids'] = Variable<String>(releaseIds.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (numberSort.present) {
      map['number_sort'] = Variable<String>(numberSort.value);
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
          ..write('number: $number, ')
          ..write('parallelId: $parallelId, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('colors: $colors, ')
          ..write('colorCount: $colorCount, ')
          ..write('rarity: $rarity, ')
          ..write('supplementalStars: $supplementalStars, ')
          ..write('level: $level, ')
          ..write('playCost: $playCost, ')
          ..write('useCost: $useCost, ')
          ..write('cost: $cost, ')
          ..write('dp: $dp, ')
          ..write('form: $form, ')
          ..write('attribute: $attribute, ')
          ..write('blockIcon: $blockIcon, ')
          ..write('traits: $traits, ')
          ..write('keywords: $keywords, ')
          ..write('effect: $effect, ')
          ..write('inheritedEffect: $inheritedEffect, ')
          ..write('securityEffect: $securityEffect, ')
          ..write('digivolveCostMin: $digivolveCostMin, ')
          ..write('digivolveCostMax: $digivolveCostMax, ')
          ..write('digivolutionRequirements: $digivolutionRequirements, ')
          ..write('dualFace: $dualFace, ')
          ..write('dualCategory: $dualCategory, ')
          ..write('notes: $notes, ')
          ..write('faqs: $faqs, ')
          ..write('errata: $errata, ')
          ..write('limitations: $limitations, ')
          ..write('copyLimit: $copyLimit, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('releaseIds: $releaseIds, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('numberSort: $numberSort, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTraitsTable extends CardTraits
    with TableInfo<$CardTraitsTable, CardTraitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTraitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _traitMeta = const VerificationMeta('trait');
  @override
  late final GeneratedColumn<String> trait = GeneratedColumn<String>(
    'trait',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cardId, trait];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_traits';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardTraitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('trait')) {
      context.handle(
        _traitMeta,
        trait.isAcceptableOrUnknown(data['trait']!, _traitMeta),
      );
    } else if (isInserting) {
      context.missing(_traitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, trait};
  @override
  CardTraitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTraitRow(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      trait: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trait'],
      )!,
    );
  }

  @override
  $CardTraitsTable createAlias(String alias) {
    return $CardTraitsTable(attachedDatabase, alias);
  }
}

class CardTraitRow extends DataClass implements Insertable<CardTraitRow> {
  final String cardId;
  final String trait;
  const CardTraitRow({required this.cardId, required this.trait});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['trait'] = Variable<String>(trait);
    return map;
  }

  CardTraitsCompanion toCompanion(bool nullToAbsent) {
    return CardTraitsCompanion(cardId: Value(cardId), trait: Value(trait));
  }

  factory CardTraitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTraitRow(
      cardId: serializer.fromJson<String>(json['cardId']),
      trait: serializer.fromJson<String>(json['trait']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'trait': serializer.toJson<String>(trait),
    };
  }

  CardTraitRow copyWith({String? cardId, String? trait}) =>
      CardTraitRow(cardId: cardId ?? this.cardId, trait: trait ?? this.trait);
  CardTraitRow copyWithCompanion(CardTraitsCompanion data) {
    return CardTraitRow(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      trait: data.trait.present ? data.trait.value : this.trait,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTraitRow(')
          ..write('cardId: $cardId, ')
          ..write('trait: $trait')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, trait);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTraitRow &&
          other.cardId == this.cardId &&
          other.trait == this.trait);
}

class CardTraitsCompanion extends UpdateCompanion<CardTraitRow> {
  final Value<String> cardId;
  final Value<String> trait;
  final Value<int> rowid;
  const CardTraitsCompanion({
    this.cardId = const Value.absent(),
    this.trait = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTraitsCompanion.insert({
    required String cardId,
    required String trait,
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       trait = Value(trait);
  static Insertable<CardTraitRow> custom({
    Expression<String>? cardId,
    Expression<String>? trait,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (trait != null) 'trait': trait,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTraitsCompanion copyWith({
    Value<String>? cardId,
    Value<String>? trait,
    Value<int>? rowid,
  }) {
    return CardTraitsCompanion(
      cardId: cardId ?? this.cardId,
      trait: trait ?? this.trait,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (trait.present) {
      map['trait'] = Variable<String>(trait.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTraitsCompanion(')
          ..write('cardId: $cardId, ')
          ..write('trait: $trait, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardKeywordsTable extends CardKeywords
    with TableInfo<$CardKeywordsTable, CardKeywordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardKeywordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _keywordMeta = const VerificationMeta(
    'keyword',
  );
  @override
  late final GeneratedColumn<String> keyword = GeneratedColumn<String>(
    'keyword',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cardId, keyword];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_keywords';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardKeywordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('keyword')) {
      context.handle(
        _keywordMeta,
        keyword.isAcceptableOrUnknown(data['keyword']!, _keywordMeta),
      );
    } else if (isInserting) {
      context.missing(_keywordMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, keyword};
  @override
  CardKeywordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardKeywordRow(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      keyword: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keyword'],
      )!,
    );
  }

  @override
  $CardKeywordsTable createAlias(String alias) {
    return $CardKeywordsTable(attachedDatabase, alias);
  }
}

class CardKeywordRow extends DataClass implements Insertable<CardKeywordRow> {
  final String cardId;
  final String keyword;
  const CardKeywordRow({required this.cardId, required this.keyword});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['keyword'] = Variable<String>(keyword);
    return map;
  }

  CardKeywordsCompanion toCompanion(bool nullToAbsent) {
    return CardKeywordsCompanion(
      cardId: Value(cardId),
      keyword: Value(keyword),
    );
  }

  factory CardKeywordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardKeywordRow(
      cardId: serializer.fromJson<String>(json['cardId']),
      keyword: serializer.fromJson<String>(json['keyword']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'keyword': serializer.toJson<String>(keyword),
    };
  }

  CardKeywordRow copyWith({String? cardId, String? keyword}) => CardKeywordRow(
    cardId: cardId ?? this.cardId,
    keyword: keyword ?? this.keyword,
  );
  CardKeywordRow copyWithCompanion(CardKeywordsCompanion data) {
    return CardKeywordRow(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      keyword: data.keyword.present ? data.keyword.value : this.keyword,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardKeywordRow(')
          ..write('cardId: $cardId, ')
          ..write('keyword: $keyword')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, keyword);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardKeywordRow &&
          other.cardId == this.cardId &&
          other.keyword == this.keyword);
}

class CardKeywordsCompanion extends UpdateCompanion<CardKeywordRow> {
  final Value<String> cardId;
  final Value<String> keyword;
  final Value<int> rowid;
  const CardKeywordsCompanion({
    this.cardId = const Value.absent(),
    this.keyword = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardKeywordsCompanion.insert({
    required String cardId,
    required String keyword,
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       keyword = Value(keyword);
  static Insertable<CardKeywordRow> custom({
    Expression<String>? cardId,
    Expression<String>? keyword,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (keyword != null) 'keyword': keyword,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardKeywordsCompanion copyWith({
    Value<String>? cardId,
    Value<String>? keyword,
    Value<int>? rowid,
  }) {
    return CardKeywordsCompanion(
      cardId: cardId ?? this.cardId,
      keyword: keyword ?? this.keyword,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (keyword.present) {
      map['keyword'] = Variable<String>(keyword.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardKeywordsCompanion(')
          ..write('cardId: $cardId, ')
          ..write('keyword: $keyword, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardReleaseLinksTable extends CardReleaseLinks
    with TableInfo<$CardReleaseLinksTable, CardReleaseLinkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardReleaseLinksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _releaseIdMeta = const VerificationMeta(
    'releaseId',
  );
  @override
  late final GeneratedColumn<String> releaseId = GeneratedColumn<String>(
    'release_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cardId, releaseId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_release_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardReleaseLinkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('release_id')) {
      context.handle(
        _releaseIdMeta,
        releaseId.isAcceptableOrUnknown(data['release_id']!, _releaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_releaseIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId, releaseId};
  @override
  CardReleaseLinkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardReleaseLinkRow(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_id'],
      )!,
      releaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}release_id'],
      )!,
    );
  }

  @override
  $CardReleaseLinksTable createAlias(String alias) {
    return $CardReleaseLinksTable(attachedDatabase, alias);
  }
}

class CardReleaseLinkRow extends DataClass
    implements Insertable<CardReleaseLinkRow> {
  final String cardId;
  final String releaseId;
  const CardReleaseLinkRow({required this.cardId, required this.releaseId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['release_id'] = Variable<String>(releaseId);
    return map;
  }

  CardReleaseLinksCompanion toCompanion(bool nullToAbsent) {
    return CardReleaseLinksCompanion(
      cardId: Value(cardId),
      releaseId: Value(releaseId),
    );
  }

  factory CardReleaseLinkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardReleaseLinkRow(
      cardId: serializer.fromJson<String>(json['cardId']),
      releaseId: serializer.fromJson<String>(json['releaseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'releaseId': serializer.toJson<String>(releaseId),
    };
  }

  CardReleaseLinkRow copyWith({String? cardId, String? releaseId}) =>
      CardReleaseLinkRow(
        cardId: cardId ?? this.cardId,
        releaseId: releaseId ?? this.releaseId,
      );
  CardReleaseLinkRow copyWithCompanion(CardReleaseLinksCompanion data) {
    return CardReleaseLinkRow(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      releaseId: data.releaseId.present ? data.releaseId.value : this.releaseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardReleaseLinkRow(')
          ..write('cardId: $cardId, ')
          ..write('releaseId: $releaseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, releaseId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardReleaseLinkRow &&
          other.cardId == this.cardId &&
          other.releaseId == this.releaseId);
}

class CardReleaseLinksCompanion extends UpdateCompanion<CardReleaseLinkRow> {
  final Value<String> cardId;
  final Value<String> releaseId;
  final Value<int> rowid;
  const CardReleaseLinksCompanion({
    this.cardId = const Value.absent(),
    this.releaseId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardReleaseLinksCompanion.insert({
    required String cardId,
    required String releaseId,
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       releaseId = Value(releaseId);
  static Insertable<CardReleaseLinkRow> custom({
    Expression<String>? cardId,
    Expression<String>? releaseId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (releaseId != null) 'release_id': releaseId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardReleaseLinksCompanion copyWith({
    Value<String>? cardId,
    Value<String>? releaseId,
    Value<int>? rowid,
  }) {
    return CardReleaseLinksCompanion(
      cardId: cardId ?? this.cardId,
      releaseId: releaseId ?? this.releaseId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (releaseId.present) {
      map['release_id'] = Variable<String>(releaseId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardReleaseLinksCompanion(')
          ..write('cardId: $cardId, ')
          ..write('releaseId: $releaseId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecksTable extends Decks with TableInfo<$DecksTable, DeckRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeRevisionIdMeta = const VerificationMeta(
    'activeRevisionId',
  );
  @override
  late final GeneratedColumn<int> activeRevisionId = GeneratedColumn<int>(
    'active_revision_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    activeRevisionId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckRow> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('active_revision_id')) {
      context.handle(
        _activeRevisionIdMeta,
        activeRevisionId.isAcceptableOrUnknown(
          data['active_revision_id']!,
          _activeRevisionIdMeta,
        ),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      activeRevisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active_revision_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class DeckRow extends DataClass implements Insertable<DeckRow> {
  final int id;
  final String name;
  final String? description;
  final int? activeRevisionId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DeckRow({
    required this.id,
    required this.name,
    this.description,
    this.activeRevisionId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || activeRevisionId != null) {
      map['active_revision_id'] = Variable<int>(activeRevisionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      activeRevisionId: activeRevisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeRevisionId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DeckRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      activeRevisionId: serializer.fromJson<int?>(json['activeRevisionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'activeRevisionId': serializer.toJson<int?>(activeRevisionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DeckRow copyWith({
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<int?> activeRevisionId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DeckRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    activeRevisionId: activeRevisionId.present
        ? activeRevisionId.value
        : this.activeRevisionId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DeckRow copyWithCompanion(DecksCompanion data) {
    return DeckRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      activeRevisionId: data.activeRevisionId.present
          ? data.activeRevisionId.value
          : this.activeRevisionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('activeRevisionId: $activeRevisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    activeRevisionId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.activeRevisionId == this.activeRevisionId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DecksCompanion extends UpdateCompanion<DeckRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int?> activeRevisionId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.activeRevisionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DecksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.activeRevisionId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DeckRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? activeRevisionId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (activeRevisionId != null) 'active_revision_id': activeRevisionId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DecksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int?>? activeRevisionId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      activeRevisionId: activeRevisionId ?? this.activeRevisionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (activeRevisionId.present) {
      map['active_revision_id'] = Variable<int>(activeRevisionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('activeRevisionId: $activeRevisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DeckRevisionsTable extends DeckRevisions
    with TableInfo<$DeckRevisionsTable, DeckRevisionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckRevisionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    name,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckRevisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckRevisionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckRevisionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deck_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DeckRevisionsTable createAlias(String alias) {
    return $DeckRevisionsTable(attachedDatabase, alias);
  }
}

class DeckRevisionRow extends DataClass implements Insertable<DeckRevisionRow> {
  final int id;
  final int deckId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DeckRevisionRow({
    required this.id,
    required this.deckId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<int>(deckId);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DeckRevisionsCompanion toCompanion(bool nullToAbsent) {
    return DeckRevisionsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DeckRevisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckRevisionRow(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<int>(json['deckId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<int>(deckId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DeckRevisionRow copyWith({
    int? id,
    int? deckId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DeckRevisionRow(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DeckRevisionRow copyWithCompanion(DeckRevisionsCompanion data) {
    return DeckRevisionRow(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckRevisionRow(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deckId, name, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckRevisionRow &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DeckRevisionsCompanion extends UpdateCompanion<DeckRevisionRow> {
  final Value<int> id;
  final Value<int> deckId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DeckRevisionsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DeckRevisionsCompanion.insert({
    this.id = const Value.absent(),
    required int deckId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : deckId = Value(deckId),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DeckRevisionRow> custom({
    Expression<int>? id,
    Expression<int>? deckId,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DeckRevisionsCompanion copyWith({
    Value<int>? id,
    Value<int>? deckId,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DeckRevisionsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DeckEntriesTable extends DeckEntries
    with TableInfo<$DeckEntriesTable, DeckEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _revisionIdMeta = const VerificationMeta(
    'revisionId',
  );
  @override
  late final GeneratedColumn<int> revisionId = GeneratedColumn<int>(
    'revision_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES deck_revisions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cardNumberMeta = const VerificationMeta(
    'cardNumber',
  );
  @override
  late final GeneratedColumn<String> cardNumber = GeneratedColumn<String>(
    'card_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _printingIdMeta = const VerificationMeta(
    'printingId',
  );
  @override
  late final GeneratedColumn<String> printingId = GeneratedColumn<String>(
    'printing_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    revisionId,
    cardNumber,
    quantity,
    printingId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('revision_id')) {
      context.handle(
        _revisionIdMeta,
        revisionId.isAcceptableOrUnknown(data['revision_id']!, _revisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionIdMeta);
    }
    if (data.containsKey('card_number')) {
      context.handle(
        _cardNumberMeta,
        cardNumber.isAcceptableOrUnknown(data['card_number']!, _cardNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_cardNumberMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('printing_id')) {
      context.handle(
        _printingIdMeta,
        printingId.isAcceptableOrUnknown(data['printing_id']!, _printingIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {revisionId, cardNumber};
  @override
  DeckEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckEntryRow(
      revisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_id'],
      )!,
      cardNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_number'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      printingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}printing_id'],
      ),
    );
  }

  @override
  $DeckEntriesTable createAlias(String alias) {
    return $DeckEntriesTable(attachedDatabase, alias);
  }
}

class DeckEntryRow extends DataClass implements Insertable<DeckEntryRow> {
  final int revisionId;
  final String cardNumber;
  final int quantity;

  /// Printing whose art the user picked, or null for the base printing.
  final String? printingId;
  const DeckEntryRow({
    required this.revisionId,
    required this.cardNumber,
    required this.quantity,
    this.printingId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision_id'] = Variable<int>(revisionId);
    map['card_number'] = Variable<String>(cardNumber);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || printingId != null) {
      map['printing_id'] = Variable<String>(printingId);
    }
    return map;
  }

  DeckEntriesCompanion toCompanion(bool nullToAbsent) {
    return DeckEntriesCompanion(
      revisionId: Value(revisionId),
      cardNumber: Value(cardNumber),
      quantity: Value(quantity),
      printingId: printingId == null && nullToAbsent
          ? const Value.absent()
          : Value(printingId),
    );
  }

  factory DeckEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckEntryRow(
      revisionId: serializer.fromJson<int>(json['revisionId']),
      cardNumber: serializer.fromJson<String>(json['cardNumber']),
      quantity: serializer.fromJson<int>(json['quantity']),
      printingId: serializer.fromJson<String?>(json['printingId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revisionId': serializer.toJson<int>(revisionId),
      'cardNumber': serializer.toJson<String>(cardNumber),
      'quantity': serializer.toJson<int>(quantity),
      'printingId': serializer.toJson<String?>(printingId),
    };
  }

  DeckEntryRow copyWith({
    int? revisionId,
    String? cardNumber,
    int? quantity,
    Value<String?> printingId = const Value.absent(),
  }) => DeckEntryRow(
    revisionId: revisionId ?? this.revisionId,
    cardNumber: cardNumber ?? this.cardNumber,
    quantity: quantity ?? this.quantity,
    printingId: printingId.present ? printingId.value : this.printingId,
  );
  DeckEntryRow copyWithCompanion(DeckEntriesCompanion data) {
    return DeckEntryRow(
      revisionId: data.revisionId.present
          ? data.revisionId.value
          : this.revisionId,
      cardNumber: data.cardNumber.present
          ? data.cardNumber.value
          : this.cardNumber,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      printingId: data.printingId.present
          ? data.printingId.value
          : this.printingId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckEntryRow(')
          ..write('revisionId: $revisionId, ')
          ..write('cardNumber: $cardNumber, ')
          ..write('quantity: $quantity, ')
          ..write('printingId: $printingId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(revisionId, cardNumber, quantity, printingId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckEntryRow &&
          other.revisionId == this.revisionId &&
          other.cardNumber == this.cardNumber &&
          other.quantity == this.quantity &&
          other.printingId == this.printingId);
}

class DeckEntriesCompanion extends UpdateCompanion<DeckEntryRow> {
  final Value<int> revisionId;
  final Value<String> cardNumber;
  final Value<int> quantity;
  final Value<String?> printingId;
  final Value<int> rowid;
  const DeckEntriesCompanion({
    this.revisionId = const Value.absent(),
    this.cardNumber = const Value.absent(),
    this.quantity = const Value.absent(),
    this.printingId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeckEntriesCompanion.insert({
    required int revisionId,
    required String cardNumber,
    required int quantity,
    this.printingId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : revisionId = Value(revisionId),
       cardNumber = Value(cardNumber),
       quantity = Value(quantity);
  static Insertable<DeckEntryRow> custom({
    Expression<int>? revisionId,
    Expression<String>? cardNumber,
    Expression<int>? quantity,
    Expression<String>? printingId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revisionId != null) 'revision_id': revisionId,
      if (cardNumber != null) 'card_number': cardNumber,
      if (quantity != null) 'quantity': quantity,
      if (printingId != null) 'printing_id': printingId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeckEntriesCompanion copyWith({
    Value<int>? revisionId,
    Value<String>? cardNumber,
    Value<int>? quantity,
    Value<String?>? printingId,
    Value<int>? rowid,
  }) {
    return DeckEntriesCompanion(
      revisionId: revisionId ?? this.revisionId,
      cardNumber: cardNumber ?? this.cardNumber,
      quantity: quantity ?? this.quantity,
      printingId: printingId ?? this.printingId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revisionId.present) {
      map['revision_id'] = Variable<int>(revisionId.value);
    }
    if (cardNumber.present) {
      map['card_number'] = Variable<String>(cardNumber.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (printingId.present) {
      map['printing_id'] = Variable<String>(printingId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckEntriesCompanion(')
          ..write('revisionId: $revisionId, ')
          ..write('cardNumber: $cardNumber, ')
          ..write('quantity: $quantity, ')
          ..write('printingId: $printingId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _bulkUpdatedAtMeta = const VerificationMeta(
    'bulkUpdatedAt',
  );
  @override
  late final GeneratedColumn<String> bulkUpdatedAt = GeneratedColumn<String>(
    'bulk_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bulkIdMeta = const VerificationMeta('bulkId');
  @override
  late final GeneratedColumn<String> bulkId = GeneratedColumn<String>(
    'bulk_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardCountMeta = const VerificationMeta(
    'cardCount',
  );
  @override
  late final GeneratedColumn<int> cardCount = GeneratedColumn<int>(
    'card_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bulkUpdatedAt,
    bulkId,
    syncedAt,
    cardCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bulk_updated_at')) {
      context.handle(
        _bulkUpdatedAtMeta,
        bulkUpdatedAt.isAcceptableOrUnknown(
          data['bulk_updated_at']!,
          _bulkUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('bulk_id')) {
      context.handle(
        _bulkIdMeta,
        bulkId.isAcceptableOrUnknown(data['bulk_id']!, _bulkIdMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    if (data.containsKey('card_count')) {
      context.handle(
        _cardCountMeta,
        cardCount.isAcceptableOrUnknown(data['card_count']!, _cardCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bulkUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bulk_updated_at'],
      ),
      bulkId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bulk_id'],
      ),
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      ),
      cardCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_count'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateRow extends DataClass implements Insertable<SyncStateRow> {
  final int id;

  /// `updated-at` of the bulk file that produced the current data.
  final String? bulkUpdatedAt;

  /// Hash id of the bulk file, used to tell a re-publish from a new dataset.
  final String? bulkId;
  final DateTime? syncedAt;
  final int cardCount;
  const SyncStateRow({
    required this.id,
    this.bulkUpdatedAt,
    this.bulkId,
    this.syncedAt,
    required this.cardCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || bulkUpdatedAt != null) {
      map['bulk_updated_at'] = Variable<String>(bulkUpdatedAt);
    }
    if (!nullToAbsent || bulkId != null) {
      map['bulk_id'] = Variable<String>(bulkId);
    }
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    map['card_count'] = Variable<int>(cardCount);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      id: Value(id),
      bulkUpdatedAt: bulkUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(bulkUpdatedAt),
      bulkId: bulkId == null && nullToAbsent
          ? const Value.absent()
          : Value(bulkId),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      cardCount: Value(cardCount),
    );
  }

  factory SyncStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateRow(
      id: serializer.fromJson<int>(json['id']),
      bulkUpdatedAt: serializer.fromJson<String?>(json['bulkUpdatedAt']),
      bulkId: serializer.fromJson<String?>(json['bulkId']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      cardCount: serializer.fromJson<int>(json['cardCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bulkUpdatedAt': serializer.toJson<String?>(bulkUpdatedAt),
      'bulkId': serializer.toJson<String?>(bulkId),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'cardCount': serializer.toJson<int>(cardCount),
    };
  }

  SyncStateRow copyWith({
    int? id,
    Value<String?> bulkUpdatedAt = const Value.absent(),
    Value<String?> bulkId = const Value.absent(),
    Value<DateTime?> syncedAt = const Value.absent(),
    int? cardCount,
  }) => SyncStateRow(
    id: id ?? this.id,
    bulkUpdatedAt: bulkUpdatedAt.present
        ? bulkUpdatedAt.value
        : this.bulkUpdatedAt,
    bulkId: bulkId.present ? bulkId.value : this.bulkId,
    syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
    cardCount: cardCount ?? this.cardCount,
  );
  SyncStateRow copyWithCompanion(SyncStateCompanion data) {
    return SyncStateRow(
      id: data.id.present ? data.id.value : this.id,
      bulkUpdatedAt: data.bulkUpdatedAt.present
          ? data.bulkUpdatedAt.value
          : this.bulkUpdatedAt,
      bulkId: data.bulkId.present ? data.bulkId.value : this.bulkId,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
      cardCount: data.cardCount.present ? data.cardCount.value : this.cardCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateRow(')
          ..write('id: $id, ')
          ..write('bulkUpdatedAt: $bulkUpdatedAt, ')
          ..write('bulkId: $bulkId, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('cardCount: $cardCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bulkUpdatedAt, bulkId, syncedAt, cardCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateRow &&
          other.id == this.id &&
          other.bulkUpdatedAt == this.bulkUpdatedAt &&
          other.bulkId == this.bulkId &&
          other.syncedAt == this.syncedAt &&
          other.cardCount == this.cardCount);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateRow> {
  final Value<int> id;
  final Value<String?> bulkUpdatedAt;
  final Value<String?> bulkId;
  final Value<DateTime?> syncedAt;
  final Value<int> cardCount;
  const SyncStateCompanion({
    this.id = const Value.absent(),
    this.bulkUpdatedAt = const Value.absent(),
    this.bulkId = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.cardCount = const Value.absent(),
  });
  SyncStateCompanion.insert({
    this.id = const Value.absent(),
    this.bulkUpdatedAt = const Value.absent(),
    this.bulkId = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.cardCount = const Value.absent(),
  });
  static Insertable<SyncStateRow> custom({
    Expression<int>? id,
    Expression<String>? bulkUpdatedAt,
    Expression<String>? bulkId,
    Expression<DateTime>? syncedAt,
    Expression<int>? cardCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bulkUpdatedAt != null) 'bulk_updated_at': bulkUpdatedAt,
      if (bulkId != null) 'bulk_id': bulkId,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (cardCount != null) 'card_count': cardCount,
    });
  }

  SyncStateCompanion copyWith({
    Value<int>? id,
    Value<String?>? bulkUpdatedAt,
    Value<String?>? bulkId,
    Value<DateTime?>? syncedAt,
    Value<int>? cardCount,
  }) {
    return SyncStateCompanion(
      id: id ?? this.id,
      bulkUpdatedAt: bulkUpdatedAt ?? this.bulkUpdatedAt,
      bulkId: bulkId ?? this.bulkId,
      syncedAt: syncedAt ?? this.syncedAt,
      cardCount: cardCount ?? this.cardCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bulkUpdatedAt.present) {
      map['bulk_updated_at'] = Variable<String>(bulkUpdatedAt.value);
    }
    if (bulkId.present) {
      map['bulk_id'] = Variable<String>(bulkId.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (cardCount.present) {
      map['card_count'] = Variable<int>(cardCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('id: $id, ')
          ..write('bulkUpdatedAt: $bulkUpdatedAt, ')
          ..write('bulkId: $bulkId, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('cardCount: $cardCount')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ReleasesTable releases = $ReleasesTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $CardTraitsTable cardTraits = $CardTraitsTable(this);
  late final $CardKeywordsTable cardKeywords = $CardKeywordsTable(this);
  late final $CardReleaseLinksTable cardReleaseLinks = $CardReleaseLinksTable(
    this,
  );
  late final $DecksTable decks = $DecksTable(this);
  late final $DeckRevisionsTable deckRevisions = $DeckRevisionsTable(this);
  late final $DeckEntriesTable deckEntries = $DeckEntriesTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final CardDao cardDao = CardDao(this as AppDatabase);
  late final ReleaseDao releaseDao = ReleaseDao(this as AppDatabase);
  late final DeckDao deckDao = DeckDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    releases,
    cards,
    cardTraits,
    cardKeywords,
    cardReleaseLinks,
    decks,
    deckRevisions,
    deckEntries,
    syncState,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_traits', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_keywords', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('card_release_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('deck_revisions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'deck_revisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('deck_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ReleasesTableCreateCompanionBuilder =
    ReleasesCompanion Function({
      required String id,
      required String name,
      required String groupName,
      Value<String?> genre,
      Value<String?> releaseDate,
      Value<String?> imageUrl,
      Value<String?> thumbnailUrl,
      Value<String?> productUri,
      Value<String?> cardlistUri,
      Value<int> cardCount,
      Value<int> sortIndex,
      Value<int> rowid,
    });
typedef $$ReleasesTableUpdateCompanionBuilder =
    ReleasesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> groupName,
      Value<String?> genre,
      Value<String?> releaseDate,
      Value<String?> imageUrl,
      Value<String?> thumbnailUrl,
      Value<String?> productUri,
      Value<String?> cardlistUri,
      Value<int> cardCount,
      Value<int> sortIndex,
      Value<int> rowid,
    });

class $$ReleasesTableFilterComposer
    extends Composer<_$AppDatabase, $ReleasesTable> {
  $$ReleasesTableFilterComposer({
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

  ColumnFilters<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productUri => $composableBuilder(
    column: $table.productUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardlistUri => $composableBuilder(
    column: $table.cardlistUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardCount => $composableBuilder(
    column: $table.cardCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReleasesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReleasesTable> {
  $$ReleasesTableOrderingComposer({
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

  ColumnOrderings<String> get groupName => $composableBuilder(
    column: $table.groupName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productUri => $composableBuilder(
    column: $table.productUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardlistUri => $composableBuilder(
    column: $table.cardlistUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardCount => $composableBuilder(
    column: $table.cardCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortIndex => $composableBuilder(
    column: $table.sortIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReleasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReleasesTable> {
  $$ReleasesTableAnnotationComposer({
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

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get releaseDate => $composableBuilder(
    column: $table.releaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get productUri => $composableBuilder(
    column: $table.productUri,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardlistUri => $composableBuilder(
    column: $table.cardlistUri,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cardCount =>
      $composableBuilder(column: $table.cardCount, builder: (column) => column);

  GeneratedColumn<int> get sortIndex =>
      $composableBuilder(column: $table.sortIndex, builder: (column) => column);
}

class $$ReleasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReleasesTable,
          ReleaseRow,
          $$ReleasesTableFilterComposer,
          $$ReleasesTableOrderingComposer,
          $$ReleasesTableAnnotationComposer,
          $$ReleasesTableCreateCompanionBuilder,
          $$ReleasesTableUpdateCompanionBuilder,
          (
            ReleaseRow,
            BaseReferences<_$AppDatabase, $ReleasesTable, ReleaseRow>,
          ),
          ReleaseRow,
          PrefetchHooks Function()
        > {
  $$ReleasesTableTableManager(_$AppDatabase db, $ReleasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReleasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReleasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReleasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> groupName = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> productUri = const Value.absent(),
                Value<String?> cardlistUri = const Value.absent(),
                Value<int> cardCount = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReleasesCompanion(
                id: id,
                name: name,
                groupName: groupName,
                genre: genre,
                releaseDate: releaseDate,
                imageUrl: imageUrl,
                thumbnailUrl: thumbnailUrl,
                productUri: productUri,
                cardlistUri: cardlistUri,
                cardCount: cardCount,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String groupName,
                Value<String?> genre = const Value.absent(),
                Value<String?> releaseDate = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<String?> thumbnailUrl = const Value.absent(),
                Value<String?> productUri = const Value.absent(),
                Value<String?> cardlistUri = const Value.absent(),
                Value<int> cardCount = const Value.absent(),
                Value<int> sortIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReleasesCompanion.insert(
                id: id,
                name: name,
                groupName: groupName,
                genre: genre,
                releaseDate: releaseDate,
                imageUrl: imageUrl,
                thumbnailUrl: thumbnailUrl,
                productUri: productUri,
                cardlistUri: cardlistUri,
                cardCount: cardCount,
                sortIndex: sortIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReleasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReleasesTable,
      ReleaseRow,
      $$ReleasesTableFilterComposer,
      $$ReleasesTableOrderingComposer,
      $$ReleasesTableAnnotationComposer,
      $$ReleasesTableCreateCompanionBuilder,
      $$ReleasesTableUpdateCompanionBuilder,
      (ReleaseRow, BaseReferences<_$AppDatabase, $ReleasesTable, ReleaseRow>),
      ReleaseRow,
      PrefetchHooks Function()
    >;
typedef $$CardsTableCreateCompanionBuilder =
    CardsCompanion Function({
      required String id,
      required String number,
      Value<int> parallelId,
      required String name,
      required String category,
      Value<String> colors,
      Value<int> colorCount,
      Value<String?> rarity,
      Value<int?> supplementalStars,
      Value<int?> level,
      Value<int?> playCost,
      Value<int?> useCost,
      Value<int?> cost,
      Value<int?> dp,
      Value<String?> form,
      Value<String?> attribute,
      Value<int?> blockIcon,
      Value<String> traits,
      Value<String> keywords,
      Value<String?> effect,
      Value<String?> inheritedEffect,
      Value<String?> securityEffect,
      Value<int?> digivolveCostMin,
      Value<int?> digivolveCostMax,
      Value<String> digivolutionRequirements,
      Value<String?> dualFace,
      Value<String?> dualCategory,
      Value<String?> notes,
      Value<String> faqs,
      Value<String?> errata,
      Value<String> limitations,
      Value<int> copyLimit,
      required String imageUrl,
      Value<String> releaseIds,
      Value<bool> isPrimary,
      Value<String> numberSort,
      Value<int> rowid,
    });
typedef $$CardsTableUpdateCompanionBuilder =
    CardsCompanion Function({
      Value<String> id,
      Value<String> number,
      Value<int> parallelId,
      Value<String> name,
      Value<String> category,
      Value<String> colors,
      Value<int> colorCount,
      Value<String?> rarity,
      Value<int?> supplementalStars,
      Value<int?> level,
      Value<int?> playCost,
      Value<int?> useCost,
      Value<int?> cost,
      Value<int?> dp,
      Value<String?> form,
      Value<String?> attribute,
      Value<int?> blockIcon,
      Value<String> traits,
      Value<String> keywords,
      Value<String?> effect,
      Value<String?> inheritedEffect,
      Value<String?> securityEffect,
      Value<int?> digivolveCostMin,
      Value<int?> digivolveCostMax,
      Value<String> digivolutionRequirements,
      Value<String?> dualFace,
      Value<String?> dualCategory,
      Value<String?> notes,
      Value<String> faqs,
      Value<String?> errata,
      Value<String> limitations,
      Value<int> copyLimit,
      Value<String> imageUrl,
      Value<String> releaseIds,
      Value<bool> isPrimary,
      Value<String> numberSort,
      Value<int> rowid,
    });

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, CardRow> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardTraitsTable, List<CardTraitRow>>
  _cardTraitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardTraits,
    aliasName: $_aliasNameGenerator(db.cards.id, db.cardTraits.cardId),
  );

  $$CardTraitsTableProcessedTableManager get cardTraitsRefs {
    final manager = $$CardTraitsTableTableManager(
      $_db,
      $_db.cardTraits,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardTraitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardKeywordsTable, List<CardKeywordRow>>
  _cardKeywordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardKeywords,
    aliasName: $_aliasNameGenerator(db.cards.id, db.cardKeywords.cardId),
  );

  $$CardKeywordsTableProcessedTableManager get cardKeywordsRefs {
    final manager = $$CardKeywordsTableTableManager(
      $_db,
      $_db.cardKeywords,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardKeywordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardReleaseLinksTable, List<CardReleaseLinkRow>>
  _cardReleaseLinksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardReleaseLinks,
    aliasName: $_aliasNameGenerator(db.cards.id, db.cardReleaseLinks.cardId),
  );

  $$CardReleaseLinksTableProcessedTableManager get cardReleaseLinksRefs {
    final manager = $$CardReleaseLinksTableTableManager(
      $_db,
      $_db.cardReleaseLinks,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cardReleaseLinksRefsTable($_db),
    );
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

  ColumnFilters<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parallelId => $composableBuilder(
    column: $table.parallelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colors => $composableBuilder(
    column: $table.colors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorCount => $composableBuilder(
    column: $table.colorCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supplementalStars => $composableBuilder(
    column: $table.supplementalStars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCost => $composableBuilder(
    column: $table.playCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get useCost => $composableBuilder(
    column: $table.useCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dp => $composableBuilder(
    column: $table.dp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attribute => $composableBuilder(
    column: $table.attribute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get blockIcon => $composableBuilder(
    column: $table.blockIcon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get traits => $composableBuilder(
    column: $table.traits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effect => $composableBuilder(
    column: $table.effect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inheritedEffect => $composableBuilder(
    column: $table.inheritedEffect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get securityEffect => $composableBuilder(
    column: $table.securityEffect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get digivolveCostMin => $composableBuilder(
    column: $table.digivolveCostMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get digivolveCostMax => $composableBuilder(
    column: $table.digivolveCostMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get digivolutionRequirements => $composableBuilder(
    column: $table.digivolutionRequirements,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dualFace => $composableBuilder(
    column: $table.dualFace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dualCategory => $composableBuilder(
    column: $table.dualCategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get faqs => $composableBuilder(
    column: $table.faqs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errata => $composableBuilder(
    column: $table.errata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get limitations => $composableBuilder(
    column: $table.limitations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get copyLimit => $composableBuilder(
    column: $table.copyLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get releaseIds => $composableBuilder(
    column: $table.releaseIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get numberSort => $composableBuilder(
    column: $table.numberSort,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardTraitsRefs(
    Expression<bool> Function($$CardTraitsTableFilterComposer f) f,
  ) {
    final $$CardTraitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardTraits,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTraitsTableFilterComposer(
            $db: $db,
            $table: $db.cardTraits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardKeywordsRefs(
    Expression<bool> Function($$CardKeywordsTableFilterComposer f) f,
  ) {
    final $$CardKeywordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardKeywords,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardKeywordsTableFilterComposer(
            $db: $db,
            $table: $db.cardKeywords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardReleaseLinksRefs(
    Expression<bool> Function($$CardReleaseLinksTableFilterComposer f) f,
  ) {
    final $$CardReleaseLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardReleaseLinks,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardReleaseLinksTableFilterComposer(
            $db: $db,
            $table: $db.cardReleaseLinks,
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

  ColumnOrderings<String> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parallelId => $composableBuilder(
    column: $table.parallelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colors => $composableBuilder(
    column: $table.colors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorCount => $composableBuilder(
    column: $table.colorCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supplementalStars => $composableBuilder(
    column: $table.supplementalStars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCost => $composableBuilder(
    column: $table.playCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get useCost => $composableBuilder(
    column: $table.useCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dp => $composableBuilder(
    column: $table.dp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attribute => $composableBuilder(
    column: $table.attribute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get blockIcon => $composableBuilder(
    column: $table.blockIcon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get traits => $composableBuilder(
    column: $table.traits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effect => $composableBuilder(
    column: $table.effect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inheritedEffect => $composableBuilder(
    column: $table.inheritedEffect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get securityEffect => $composableBuilder(
    column: $table.securityEffect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get digivolveCostMin => $composableBuilder(
    column: $table.digivolveCostMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get digivolveCostMax => $composableBuilder(
    column: $table.digivolveCostMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get digivolutionRequirements => $composableBuilder(
    column: $table.digivolutionRequirements,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dualFace => $composableBuilder(
    column: $table.dualFace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dualCategory => $composableBuilder(
    column: $table.dualCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get faqs => $composableBuilder(
    column: $table.faqs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errata => $composableBuilder(
    column: $table.errata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get limitations => $composableBuilder(
    column: $table.limitations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get copyLimit => $composableBuilder(
    column: $table.copyLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get releaseIds => $composableBuilder(
    column: $table.releaseIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get numberSort => $composableBuilder(
    column: $table.numberSort,
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

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get parallelId => $composableBuilder(
    column: $table.parallelId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get colors =>
      $composableBuilder(column: $table.colors, builder: (column) => column);

  GeneratedColumn<int> get colorCount => $composableBuilder(
    column: $table.colorCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<int> get supplementalStars => $composableBuilder(
    column: $table.supplementalStars,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get playCost =>
      $composableBuilder(column: $table.playCost, builder: (column) => column);

  GeneratedColumn<int> get useCost =>
      $composableBuilder(column: $table.useCost, builder: (column) => column);

  GeneratedColumn<int> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<int> get dp =>
      $composableBuilder(column: $table.dp, builder: (column) => column);

  GeneratedColumn<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  GeneratedColumn<String> get attribute =>
      $composableBuilder(column: $table.attribute, builder: (column) => column);

  GeneratedColumn<int> get blockIcon =>
      $composableBuilder(column: $table.blockIcon, builder: (column) => column);

  GeneratedColumn<String> get traits =>
      $composableBuilder(column: $table.traits, builder: (column) => column);

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  GeneratedColumn<String> get effect =>
      $composableBuilder(column: $table.effect, builder: (column) => column);

  GeneratedColumn<String> get inheritedEffect => $composableBuilder(
    column: $table.inheritedEffect,
    builder: (column) => column,
  );

  GeneratedColumn<String> get securityEffect => $composableBuilder(
    column: $table.securityEffect,
    builder: (column) => column,
  );

  GeneratedColumn<int> get digivolveCostMin => $composableBuilder(
    column: $table.digivolveCostMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get digivolveCostMax => $composableBuilder(
    column: $table.digivolveCostMax,
    builder: (column) => column,
  );

  GeneratedColumn<String> get digivolutionRequirements => $composableBuilder(
    column: $table.digivolutionRequirements,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dualFace =>
      $composableBuilder(column: $table.dualFace, builder: (column) => column);

  GeneratedColumn<String> get dualCategory => $composableBuilder(
    column: $table.dualCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get faqs =>
      $composableBuilder(column: $table.faqs, builder: (column) => column);

  GeneratedColumn<String> get errata =>
      $composableBuilder(column: $table.errata, builder: (column) => column);

  GeneratedColumn<String> get limitations => $composableBuilder(
    column: $table.limitations,
    builder: (column) => column,
  );

  GeneratedColumn<int> get copyLimit =>
      $composableBuilder(column: $table.copyLimit, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get releaseIds => $composableBuilder(
    column: $table.releaseIds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<String> get numberSort => $composableBuilder(
    column: $table.numberSort,
    builder: (column) => column,
  );

  Expression<T> cardTraitsRefs<T extends Object>(
    Expression<T> Function($$CardTraitsTableAnnotationComposer a) f,
  ) {
    final $$CardTraitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardTraits,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTraitsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardTraits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardKeywordsRefs<T extends Object>(
    Expression<T> Function($$CardKeywordsTableAnnotationComposer a) f,
  ) {
    final $$CardKeywordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardKeywords,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardKeywordsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardKeywords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardReleaseLinksRefs<T extends Object>(
    Expression<T> Function($$CardReleaseLinksTableAnnotationComposer a) f,
  ) {
    final $$CardReleaseLinksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardReleaseLinks,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardReleaseLinksTableAnnotationComposer(
            $db: $db,
            $table: $db.cardReleaseLinks,
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
          PrefetchHooks Function({
            bool cardTraitsRefs,
            bool cardKeywordsRefs,
            bool cardReleaseLinksRefs,
          })
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
                Value<String> number = const Value.absent(),
                Value<int> parallelId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> colors = const Value.absent(),
                Value<int> colorCount = const Value.absent(),
                Value<String?> rarity = const Value.absent(),
                Value<int?> supplementalStars = const Value.absent(),
                Value<int?> level = const Value.absent(),
                Value<int?> playCost = const Value.absent(),
                Value<int?> useCost = const Value.absent(),
                Value<int?> cost = const Value.absent(),
                Value<int?> dp = const Value.absent(),
                Value<String?> form = const Value.absent(),
                Value<String?> attribute = const Value.absent(),
                Value<int?> blockIcon = const Value.absent(),
                Value<String> traits = const Value.absent(),
                Value<String> keywords = const Value.absent(),
                Value<String?> effect = const Value.absent(),
                Value<String?> inheritedEffect = const Value.absent(),
                Value<String?> securityEffect = const Value.absent(),
                Value<int?> digivolveCostMin = const Value.absent(),
                Value<int?> digivolveCostMax = const Value.absent(),
                Value<String> digivolutionRequirements = const Value.absent(),
                Value<String?> dualFace = const Value.absent(),
                Value<String?> dualCategory = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> faqs = const Value.absent(),
                Value<String?> errata = const Value.absent(),
                Value<String> limitations = const Value.absent(),
                Value<int> copyLimit = const Value.absent(),
                Value<String> imageUrl = const Value.absent(),
                Value<String> releaseIds = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<String> numberSort = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                number: number,
                parallelId: parallelId,
                name: name,
                category: category,
                colors: colors,
                colorCount: colorCount,
                rarity: rarity,
                supplementalStars: supplementalStars,
                level: level,
                playCost: playCost,
                useCost: useCost,
                cost: cost,
                dp: dp,
                form: form,
                attribute: attribute,
                blockIcon: blockIcon,
                traits: traits,
                keywords: keywords,
                effect: effect,
                inheritedEffect: inheritedEffect,
                securityEffect: securityEffect,
                digivolveCostMin: digivolveCostMin,
                digivolveCostMax: digivolveCostMax,
                digivolutionRequirements: digivolutionRequirements,
                dualFace: dualFace,
                dualCategory: dualCategory,
                notes: notes,
                faqs: faqs,
                errata: errata,
                limitations: limitations,
                copyLimit: copyLimit,
                imageUrl: imageUrl,
                releaseIds: releaseIds,
                isPrimary: isPrimary,
                numberSort: numberSort,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String number,
                Value<int> parallelId = const Value.absent(),
                required String name,
                required String category,
                Value<String> colors = const Value.absent(),
                Value<int> colorCount = const Value.absent(),
                Value<String?> rarity = const Value.absent(),
                Value<int?> supplementalStars = const Value.absent(),
                Value<int?> level = const Value.absent(),
                Value<int?> playCost = const Value.absent(),
                Value<int?> useCost = const Value.absent(),
                Value<int?> cost = const Value.absent(),
                Value<int?> dp = const Value.absent(),
                Value<String?> form = const Value.absent(),
                Value<String?> attribute = const Value.absent(),
                Value<int?> blockIcon = const Value.absent(),
                Value<String> traits = const Value.absent(),
                Value<String> keywords = const Value.absent(),
                Value<String?> effect = const Value.absent(),
                Value<String?> inheritedEffect = const Value.absent(),
                Value<String?> securityEffect = const Value.absent(),
                Value<int?> digivolveCostMin = const Value.absent(),
                Value<int?> digivolveCostMax = const Value.absent(),
                Value<String> digivolutionRequirements = const Value.absent(),
                Value<String?> dualFace = const Value.absent(),
                Value<String?> dualCategory = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> faqs = const Value.absent(),
                Value<String?> errata = const Value.absent(),
                Value<String> limitations = const Value.absent(),
                Value<int> copyLimit = const Value.absent(),
                required String imageUrl,
                Value<String> releaseIds = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<String> numberSort = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                number: number,
                parallelId: parallelId,
                name: name,
                category: category,
                colors: colors,
                colorCount: colorCount,
                rarity: rarity,
                supplementalStars: supplementalStars,
                level: level,
                playCost: playCost,
                useCost: useCost,
                cost: cost,
                dp: dp,
                form: form,
                attribute: attribute,
                blockIcon: blockIcon,
                traits: traits,
                keywords: keywords,
                effect: effect,
                inheritedEffect: inheritedEffect,
                securityEffect: securityEffect,
                digivolveCostMin: digivolveCostMin,
                digivolveCostMax: digivolveCostMax,
                digivolutionRequirements: digivolutionRequirements,
                dualFace: dualFace,
                dualCategory: dualCategory,
                notes: notes,
                faqs: faqs,
                errata: errata,
                limitations: limitations,
                copyLimit: copyLimit,
                imageUrl: imageUrl,
                releaseIds: releaseIds,
                isPrimary: isPrimary,
                numberSort: numberSort,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CardsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cardTraitsRefs = false,
                cardKeywordsRefs = false,
                cardReleaseLinksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cardTraitsRefs) db.cardTraits,
                    if (cardKeywordsRefs) db.cardKeywords,
                    if (cardReleaseLinksRefs) db.cardReleaseLinks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cardTraitsRefs)
                        await $_getPrefetchedData<
                          CardRow,
                          $CardsTable,
                          CardTraitRow
                        >(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._cardTraitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardTraitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cardKeywordsRefs)
                        await $_getPrefetchedData<
                          CardRow,
                          $CardsTable,
                          CardKeywordRow
                        >(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._cardKeywordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardKeywordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cardReleaseLinksRefs)
                        await $_getPrefetchedData<
                          CardRow,
                          $CardsTable,
                          CardReleaseLinkRow
                        >(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._cardReleaseLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardReleaseLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
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
      PrefetchHooks Function({
        bool cardTraitsRefs,
        bool cardKeywordsRefs,
        bool cardReleaseLinksRefs,
      })
    >;
typedef $$CardTraitsTableCreateCompanionBuilder =
    CardTraitsCompanion Function({
      required String cardId,
      required String trait,
      Value<int> rowid,
    });
typedef $$CardTraitsTableUpdateCompanionBuilder =
    CardTraitsCompanion Function({
      Value<String> cardId,
      Value<String> trait,
      Value<int> rowid,
    });

final class $$CardTraitsTableReferences
    extends BaseReferences<_$AppDatabase, $CardTraitsTable, CardTraitRow> {
  $$CardTraitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardsTable _cardIdTable(_$AppDatabase db) => db.cards.createAlias(
    $_aliasNameGenerator(db.cardTraits.cardId, db.cards.id),
  );

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

class $$CardTraitsTableFilterComposer
    extends Composer<_$AppDatabase, $CardTraitsTable> {
  $$CardTraitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trait => $composableBuilder(
    column: $table.trait,
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

class $$CardTraitsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTraitsTable> {
  $$CardTraitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trait => $composableBuilder(
    column: $table.trait,
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

class $$CardTraitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTraitsTable> {
  $$CardTraitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trait =>
      $composableBuilder(column: $table.trait, builder: (column) => column);

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

class $$CardTraitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardTraitsTable,
          CardTraitRow,
          $$CardTraitsTableFilterComposer,
          $$CardTraitsTableOrderingComposer,
          $$CardTraitsTableAnnotationComposer,
          $$CardTraitsTableCreateCompanionBuilder,
          $$CardTraitsTableUpdateCompanionBuilder,
          (CardTraitRow, $$CardTraitsTableReferences),
          CardTraitRow,
          PrefetchHooks Function({bool cardId})
        > {
  $$CardTraitsTableTableManager(_$AppDatabase db, $CardTraitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTraitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTraitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTraitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> trait = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardTraitsCompanion(
                cardId: cardId,
                trait: trait,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String trait,
                Value<int> rowid = const Value.absent(),
              }) => CardTraitsCompanion.insert(
                cardId: cardId,
                trait: trait,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardTraitsTableReferences(db, table, e),
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
                                referencedTable: $$CardTraitsTableReferences
                                    ._cardIdTable(db),
                                referencedColumn: $$CardTraitsTableReferences
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

typedef $$CardTraitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardTraitsTable,
      CardTraitRow,
      $$CardTraitsTableFilterComposer,
      $$CardTraitsTableOrderingComposer,
      $$CardTraitsTableAnnotationComposer,
      $$CardTraitsTableCreateCompanionBuilder,
      $$CardTraitsTableUpdateCompanionBuilder,
      (CardTraitRow, $$CardTraitsTableReferences),
      CardTraitRow,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$CardKeywordsTableCreateCompanionBuilder =
    CardKeywordsCompanion Function({
      required String cardId,
      required String keyword,
      Value<int> rowid,
    });
typedef $$CardKeywordsTableUpdateCompanionBuilder =
    CardKeywordsCompanion Function({
      Value<String> cardId,
      Value<String> keyword,
      Value<int> rowid,
    });

final class $$CardKeywordsTableReferences
    extends BaseReferences<_$AppDatabase, $CardKeywordsTable, CardKeywordRow> {
  $$CardKeywordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardsTable _cardIdTable(_$AppDatabase db) => db.cards.createAlias(
    $_aliasNameGenerator(db.cardKeywords.cardId, db.cards.id),
  );

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

class $$CardKeywordsTableFilterComposer
    extends Composer<_$AppDatabase, $CardKeywordsTable> {
  $$CardKeywordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get keyword => $composableBuilder(
    column: $table.keyword,
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

class $$CardKeywordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardKeywordsTable> {
  $$CardKeywordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get keyword => $composableBuilder(
    column: $table.keyword,
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

class $$CardKeywordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardKeywordsTable> {
  $$CardKeywordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get keyword =>
      $composableBuilder(column: $table.keyword, builder: (column) => column);

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

class $$CardKeywordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardKeywordsTable,
          CardKeywordRow,
          $$CardKeywordsTableFilterComposer,
          $$CardKeywordsTableOrderingComposer,
          $$CardKeywordsTableAnnotationComposer,
          $$CardKeywordsTableCreateCompanionBuilder,
          $$CardKeywordsTableUpdateCompanionBuilder,
          (CardKeywordRow, $$CardKeywordsTableReferences),
          CardKeywordRow,
          PrefetchHooks Function({bool cardId})
        > {
  $$CardKeywordsTableTableManager(_$AppDatabase db, $CardKeywordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardKeywordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardKeywordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardKeywordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> keyword = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardKeywordsCompanion(
                cardId: cardId,
                keyword: keyword,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String keyword,
                Value<int> rowid = const Value.absent(),
              }) => CardKeywordsCompanion.insert(
                cardId: cardId,
                keyword: keyword,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardKeywordsTableReferences(db, table, e),
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
                                referencedTable: $$CardKeywordsTableReferences
                                    ._cardIdTable(db),
                                referencedColumn: $$CardKeywordsTableReferences
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

typedef $$CardKeywordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardKeywordsTable,
      CardKeywordRow,
      $$CardKeywordsTableFilterComposer,
      $$CardKeywordsTableOrderingComposer,
      $$CardKeywordsTableAnnotationComposer,
      $$CardKeywordsTableCreateCompanionBuilder,
      $$CardKeywordsTableUpdateCompanionBuilder,
      (CardKeywordRow, $$CardKeywordsTableReferences),
      CardKeywordRow,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$CardReleaseLinksTableCreateCompanionBuilder =
    CardReleaseLinksCompanion Function({
      required String cardId,
      required String releaseId,
      Value<int> rowid,
    });
typedef $$CardReleaseLinksTableUpdateCompanionBuilder =
    CardReleaseLinksCompanion Function({
      Value<String> cardId,
      Value<String> releaseId,
      Value<int> rowid,
    });

final class $$CardReleaseLinksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CardReleaseLinksTable,
          CardReleaseLinkRow
        > {
  $$CardReleaseLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CardsTable _cardIdTable(_$AppDatabase db) => db.cards.createAlias(
    $_aliasNameGenerator(db.cardReleaseLinks.cardId, db.cards.id),
  );

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

class $$CardReleaseLinksTableFilterComposer
    extends Composer<_$AppDatabase, $CardReleaseLinksTable> {
  $$CardReleaseLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
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

class $$CardReleaseLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $CardReleaseLinksTable> {
  $$CardReleaseLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get releaseId => $composableBuilder(
    column: $table.releaseId,
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

class $$CardReleaseLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardReleaseLinksTable> {
  $$CardReleaseLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get releaseId =>
      $composableBuilder(column: $table.releaseId, builder: (column) => column);

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

class $$CardReleaseLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardReleaseLinksTable,
          CardReleaseLinkRow,
          $$CardReleaseLinksTableFilterComposer,
          $$CardReleaseLinksTableOrderingComposer,
          $$CardReleaseLinksTableAnnotationComposer,
          $$CardReleaseLinksTableCreateCompanionBuilder,
          $$CardReleaseLinksTableUpdateCompanionBuilder,
          (CardReleaseLinkRow, $$CardReleaseLinksTableReferences),
          CardReleaseLinkRow,
          PrefetchHooks Function({bool cardId})
        > {
  $$CardReleaseLinksTableTableManager(
    _$AppDatabase db,
    $CardReleaseLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardReleaseLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardReleaseLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardReleaseLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> releaseId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardReleaseLinksCompanion(
                cardId: cardId,
                releaseId: releaseId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String releaseId,
                Value<int> rowid = const Value.absent(),
              }) => CardReleaseLinksCompanion.insert(
                cardId: cardId,
                releaseId: releaseId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardReleaseLinksTableReferences(db, table, e),
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
                                referencedTable:
                                    $$CardReleaseLinksTableReferences
                                        ._cardIdTable(db),
                                referencedColumn:
                                    $$CardReleaseLinksTableReferences
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

typedef $$CardReleaseLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardReleaseLinksTable,
      CardReleaseLinkRow,
      $$CardReleaseLinksTableFilterComposer,
      $$CardReleaseLinksTableOrderingComposer,
      $$CardReleaseLinksTableAnnotationComposer,
      $$CardReleaseLinksTableCreateCompanionBuilder,
      $$CardReleaseLinksTableUpdateCompanionBuilder,
      (CardReleaseLinkRow, $$CardReleaseLinksTableReferences),
      CardReleaseLinkRow,
      PrefetchHooks Function({bool cardId})
    >;
typedef $$DecksTableCreateCompanionBuilder =
    DecksCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<int?> activeRevisionId,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$DecksTableUpdateCompanionBuilder =
    DecksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<int?> activeRevisionId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$DecksTableReferences
    extends BaseReferences<_$AppDatabase, $DecksTable, DeckRow> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DeckRevisionsTable, List<DeckRevisionRow>>
  _deckRevisionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deckRevisions,
    aliasName: $_aliasNameGenerator(db.decks.id, db.deckRevisions.deckId),
  );

  $$DeckRevisionsTableProcessedTableManager get deckRevisionsRefs {
    final manager = $$DeckRevisionsTableTableManager(
      $_db,
      $_db.deckRevisions,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_deckRevisionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DecksTableFilterComposer extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get activeRevisionId => $composableBuilder(
    column: $table.activeRevisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> deckRevisionsRefs(
    Expression<bool> Function($$DeckRevisionsTableFilterComposer f) f,
  ) {
    final $$DeckRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deckRevisions,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeckRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.deckRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get activeRevisionId => $composableBuilder(
    column: $table.activeRevisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get activeRevisionId => $composableBuilder(
    column: $table.activeRevisionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> deckRevisionsRefs<T extends Object>(
    Expression<T> Function($$DeckRevisionsTableAnnotationComposer a) f,
  ) {
    final $$DeckRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deckRevisions,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeckRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.deckRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecksTable,
          DeckRow,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (DeckRow, $$DecksTableReferences),
          DeckRow,
          PrefetchHooks Function({bool deckRevisionsRefs})
        > {
  $$DecksTableTableManager(_$AppDatabase db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> activeRevisionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DecksCompanion(
                id: id,
                name: name,
                description: description,
                activeRevisionId: activeRevisionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<int?> activeRevisionId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => DecksCompanion.insert(
                id: id,
                name: name,
                description: description,
                activeRevisionId: activeRevisionId,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DecksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({deckRevisionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (deckRevisionsRefs) db.deckRevisions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (deckRevisionsRefs)
                    await $_getPrefetchedData<
                      DeckRow,
                      $DecksTable,
                      DeckRevisionRow
                    >(
                      currentTable: table,
                      referencedTable: $$DecksTableReferences
                          ._deckRevisionsRefsTable(db),
                      managerFromTypedResult: (p0) => $$DecksTableReferences(
                        db,
                        table,
                        p0,
                      ).deckRevisionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.deckId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecksTable,
      DeckRow,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (DeckRow, $$DecksTableReferences),
      DeckRow,
      PrefetchHooks Function({bool deckRevisionsRefs})
    >;
typedef $$DeckRevisionsTableCreateCompanionBuilder =
    DeckRevisionsCompanion Function({
      Value<int> id,
      required int deckId,
      required String name,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$DeckRevisionsTableUpdateCompanionBuilder =
    DeckRevisionsCompanion Function({
      Value<int> id,
      Value<int> deckId,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$DeckRevisionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $DeckRevisionsTable, DeckRevisionRow> {
  $$DeckRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DecksTable _deckIdTable(_$AppDatabase db) => db.decks.createAlias(
    $_aliasNameGenerator(db.deckRevisions.deckId, db.decks.id),
  );

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<int>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DeckEntriesTable, List<DeckEntryRow>>
  _deckEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deckEntries,
    aliasName: $_aliasNameGenerator(
      db.deckRevisions.id,
      db.deckEntries.revisionId,
    ),
  );

  $$DeckEntriesTableProcessedTableManager get deckEntriesRefs {
    final manager = $$DeckEntriesTableTableManager(
      $_db,
      $_db.deckEntries,
    ).filter((f) => f.revisionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_deckEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DeckRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $DeckRevisionsTable> {
  $$DeckRevisionsTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> deckEntriesRefs(
    Expression<bool> Function($$DeckEntriesTableFilterComposer f) f,
  ) {
    final $$DeckEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deckEntries,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeckEntriesTableFilterComposer(
            $db: $db,
            $table: $db.deckEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DeckRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeckRevisionsTable> {
  $$DeckRevisionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeckRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeckRevisionsTable> {
  $$DeckRevisionsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> deckEntriesRefs<T extends Object>(
    Expression<T> Function($$DeckEntriesTableAnnotationComposer a) f,
  ) {
    final $$DeckEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deckEntries,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeckEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.deckEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DeckRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeckRevisionsTable,
          DeckRevisionRow,
          $$DeckRevisionsTableFilterComposer,
          $$DeckRevisionsTableOrderingComposer,
          $$DeckRevisionsTableAnnotationComposer,
          $$DeckRevisionsTableCreateCompanionBuilder,
          $$DeckRevisionsTableUpdateCompanionBuilder,
          (DeckRevisionRow, $$DeckRevisionsTableReferences),
          DeckRevisionRow,
          PrefetchHooks Function({bool deckId, bool deckEntriesRefs})
        > {
  $$DeckRevisionsTableTableManager(_$AppDatabase db, $DeckRevisionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeckRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeckRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeckRevisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deckId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DeckRevisionsCompanion(
                id: id,
                deckId: deckId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deckId,
                required String name,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => DeckRevisionsCompanion.insert(
                id: id,
                deckId: deckId,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeckRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deckId = false, deckEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (deckEntriesRefs) db.deckEntries],
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
                    if (deckId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deckId,
                                referencedTable: $$DeckRevisionsTableReferences
                                    ._deckIdTable(db),
                                referencedColumn: $$DeckRevisionsTableReferences
                                    ._deckIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (deckEntriesRefs)
                    await $_getPrefetchedData<
                      DeckRevisionRow,
                      $DeckRevisionsTable,
                      DeckEntryRow
                    >(
                      currentTable: table,
                      referencedTable: $$DeckRevisionsTableReferences
                          ._deckEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DeckRevisionsTableReferences(
                            db,
                            table,
                            p0,
                          ).deckEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.revisionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DeckRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeckRevisionsTable,
      DeckRevisionRow,
      $$DeckRevisionsTableFilterComposer,
      $$DeckRevisionsTableOrderingComposer,
      $$DeckRevisionsTableAnnotationComposer,
      $$DeckRevisionsTableCreateCompanionBuilder,
      $$DeckRevisionsTableUpdateCompanionBuilder,
      (DeckRevisionRow, $$DeckRevisionsTableReferences),
      DeckRevisionRow,
      PrefetchHooks Function({bool deckId, bool deckEntriesRefs})
    >;
typedef $$DeckEntriesTableCreateCompanionBuilder =
    DeckEntriesCompanion Function({
      required int revisionId,
      required String cardNumber,
      required int quantity,
      Value<String?> printingId,
      Value<int> rowid,
    });
typedef $$DeckEntriesTableUpdateCompanionBuilder =
    DeckEntriesCompanion Function({
      Value<int> revisionId,
      Value<String> cardNumber,
      Value<int> quantity,
      Value<String?> printingId,
      Value<int> rowid,
    });

final class $$DeckEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $DeckEntriesTable, DeckEntryRow> {
  $$DeckEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DeckRevisionsTable _revisionIdTable(_$AppDatabase db) =>
      db.deckRevisions.createAlias(
        $_aliasNameGenerator(db.deckEntries.revisionId, db.deckRevisions.id),
      );

  $$DeckRevisionsTableProcessedTableManager get revisionId {
    final $_column = $_itemColumn<int>('revision_id')!;

    final manager = $$DeckRevisionsTableTableManager(
      $_db,
      $_db.deckRevisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_revisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DeckEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DeckEntriesTable> {
  $$DeckEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardNumber => $composableBuilder(
    column: $table.cardNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get printingId => $composableBuilder(
    column: $table.printingId,
    builder: (column) => ColumnFilters(column),
  );

  $$DeckRevisionsTableFilterComposer get revisionId {
    final $$DeckRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.deckRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeckRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.deckRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeckEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeckEntriesTable> {
  $$DeckEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardNumber => $composableBuilder(
    column: $table.cardNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get printingId => $composableBuilder(
    column: $table.printingId,
    builder: (column) => ColumnOrderings(column),
  );

  $$DeckRevisionsTableOrderingComposer get revisionId {
    final $$DeckRevisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.deckRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeckRevisionsTableOrderingComposer(
            $db: $db,
            $table: $db.deckRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeckEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeckEntriesTable> {
  $$DeckEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardNumber => $composableBuilder(
    column: $table.cardNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get printingId => $composableBuilder(
    column: $table.printingId,
    builder: (column) => column,
  );

  $$DeckRevisionsTableAnnotationComposer get revisionId {
    final $$DeckRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.deckRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeckRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.deckRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeckEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeckEntriesTable,
          DeckEntryRow,
          $$DeckEntriesTableFilterComposer,
          $$DeckEntriesTableOrderingComposer,
          $$DeckEntriesTableAnnotationComposer,
          $$DeckEntriesTableCreateCompanionBuilder,
          $$DeckEntriesTableUpdateCompanionBuilder,
          (DeckEntryRow, $$DeckEntriesTableReferences),
          DeckEntryRow,
          PrefetchHooks Function({bool revisionId})
        > {
  $$DeckEntriesTableTableManager(_$AppDatabase db, $DeckEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeckEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeckEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeckEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> revisionId = const Value.absent(),
                Value<String> cardNumber = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String?> printingId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeckEntriesCompanion(
                revisionId: revisionId,
                cardNumber: cardNumber,
                quantity: quantity,
                printingId: printingId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int revisionId,
                required String cardNumber,
                required int quantity,
                Value<String?> printingId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeckEntriesCompanion.insert(
                revisionId: revisionId,
                cardNumber: cardNumber,
                quantity: quantity,
                printingId: printingId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeckEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({revisionId = false}) {
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
                    if (revisionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.revisionId,
                                referencedTable: $$DeckEntriesTableReferences
                                    ._revisionIdTable(db),
                                referencedColumn: $$DeckEntriesTableReferences
                                    ._revisionIdTable(db)
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

typedef $$DeckEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeckEntriesTable,
      DeckEntryRow,
      $$DeckEntriesTableFilterComposer,
      $$DeckEntriesTableOrderingComposer,
      $$DeckEntriesTableAnnotationComposer,
      $$DeckEntriesTableCreateCompanionBuilder,
      $$DeckEntriesTableUpdateCompanionBuilder,
      (DeckEntryRow, $$DeckEntriesTableReferences),
      DeckEntryRow,
      PrefetchHooks Function({bool revisionId})
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      Value<int> id,
      Value<String?> bulkUpdatedAt,
      Value<String?> bulkId,
      Value<DateTime?> syncedAt,
      Value<int> cardCount,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<int> id,
      Value<String?> bulkUpdatedAt,
      Value<String?> bulkId,
      Value<DateTime?> syncedAt,
      Value<int> cardCount,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
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

  ColumnFilters<String> get bulkUpdatedAt => $composableBuilder(
    column: $table.bulkUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bulkId => $composableBuilder(
    column: $table.bulkId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardCount => $composableBuilder(
    column: $table.cardCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
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

  ColumnOrderings<String> get bulkUpdatedAt => $composableBuilder(
    column: $table.bulkUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bulkId => $composableBuilder(
    column: $table.bulkId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardCount => $composableBuilder(
    column: $table.cardCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bulkUpdatedAt => $composableBuilder(
    column: $table.bulkUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bulkId =>
      $composableBuilder(column: $table.bulkId, builder: (column) => column);

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);

  GeneratedColumn<int> get cardCount =>
      $composableBuilder(column: $table.cardCount, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateRow,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateRow,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
          ),
          SyncStateRow,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> bulkUpdatedAt = const Value.absent(),
                Value<String?> bulkId = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> cardCount = const Value.absent(),
              }) => SyncStateCompanion(
                id: id,
                bulkUpdatedAt: bulkUpdatedAt,
                bulkId: bulkId,
                syncedAt: syncedAt,
                cardCount: cardCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> bulkUpdatedAt = const Value.absent(),
                Value<String?> bulkId = const Value.absent(),
                Value<DateTime?> syncedAt = const Value.absent(),
                Value<int> cardCount = const Value.absent(),
              }) => SyncStateCompanion.insert(
                id: id,
                bulkUpdatedAt: bulkUpdatedAt,
                bulkId: bulkId,
                syncedAt: syncedAt,
                cardCount: cardCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateRow,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateRow,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateRow>,
      ),
      SyncStateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ReleasesTableTableManager get releases =>
      $$ReleasesTableTableManager(_db, _db.releases);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$CardTraitsTableTableManager get cardTraits =>
      $$CardTraitsTableTableManager(_db, _db.cardTraits);
  $$CardKeywordsTableTableManager get cardKeywords =>
      $$CardKeywordsTableTableManager(_db, _db.cardKeywords);
  $$CardReleaseLinksTableTableManager get cardReleaseLinks =>
      $$CardReleaseLinksTableTableManager(_db, _db.cardReleaseLinks);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$DeckRevisionsTableTableManager get deckRevisions =>
      $$DeckRevisionsTableTableManager(_db, _db.deckRevisions);
  $$DeckEntriesTableTableManager get deckEntries =>
      $$DeckEntriesTableTableManager(_db, _db.deckEntries);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
}
