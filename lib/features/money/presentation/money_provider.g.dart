// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$moneyRepositoryHash() => r'4925c506ede289dad67ea57340a8f157f74b0865';

/// See also [moneyRepository].
@ProviderFor(moneyRepository)
final moneyRepositoryProvider = AutoDisposeProvider<MoneyRepository>.internal(
  moneyRepository,
  name: r'moneyRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$moneyRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MoneyRepositoryRef = AutoDisposeProviderRef<MoneyRepository>;
String _$allMoneyRecordsHash() => r'd8a3f5b156b497e0c93d86c3baeabc038cdb0ba1';

/// See also [allMoneyRecords].
@ProviderFor(allMoneyRecords)
final allMoneyRecordsProvider =
    AutoDisposeStreamProvider<List<MoneyRecord>>.internal(
  allMoneyRecords,
  name: r'allMoneyRecordsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allMoneyRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllMoneyRecordsRef = AutoDisposeStreamProviderRef<List<MoneyRecord>>;
String _$archivedMoneyRecordsHash() =>
    r'ffa62caf4d2e3b393fe5426d26e2c8512a5a6ad2';

/// See also [archivedMoneyRecords].
@ProviderFor(archivedMoneyRecords)
final archivedMoneyRecordsProvider =
    AutoDisposeStreamProvider<List<MoneyRecord>>.internal(
  archivedMoneyRecords,
  name: r'archivedMoneyRecordsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$archivedMoneyRecordsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ArchivedMoneyRecordsRef
    = AutoDisposeStreamProviderRef<List<MoneyRecord>>;
String _$moneyRecordDetailHash() => r'c80fd7317cada9ac6088f67f74be27444bb29010';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [moneyRecordDetail].
@ProviderFor(moneyRecordDetail)
const moneyRecordDetailProvider = MoneyRecordDetailFamily();

/// See also [moneyRecordDetail].
class MoneyRecordDetailFamily extends Family<AsyncValue<MoneyRecord?>> {
  /// See also [moneyRecordDetail].
  const MoneyRecordDetailFamily();

  /// See also [moneyRecordDetail].
  MoneyRecordDetailProvider call(
    int id,
  ) {
    return MoneyRecordDetailProvider(
      id,
    );
  }

  @override
  MoneyRecordDetailProvider getProviderOverride(
    covariant MoneyRecordDetailProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'moneyRecordDetailProvider';
}

/// See also [moneyRecordDetail].
class MoneyRecordDetailProvider
    extends AutoDisposeFutureProvider<MoneyRecord?> {
  /// See also [moneyRecordDetail].
  MoneyRecordDetailProvider(
    int id,
  ) : this._internal(
          (ref) => moneyRecordDetail(
            ref as MoneyRecordDetailRef,
            id,
          ),
          from: moneyRecordDetailProvider,
          name: r'moneyRecordDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$moneyRecordDetailHash,
          dependencies: MoneyRecordDetailFamily._dependencies,
          allTransitiveDependencies:
              MoneyRecordDetailFamily._allTransitiveDependencies,
          id: id,
        );

  MoneyRecordDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<MoneyRecord?> Function(MoneyRecordDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MoneyRecordDetailProvider._internal(
        (ref) => create(ref as MoneyRecordDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MoneyRecord?> createElement() {
    return _MoneyRecordDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MoneyRecordDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MoneyRecordDetailRef on AutoDisposeFutureProviderRef<MoneyRecord?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _MoneyRecordDetailProviderElement
    extends AutoDisposeFutureProviderElement<MoneyRecord?>
    with MoneyRecordDetailRef {
  _MoneyRecordDetailProviderElement(super.provider);

  @override
  int get id => (origin as MoneyRecordDetailProvider).id;
}

String _$recordsByPersonHash() => r'e2bee683a99ff82a2d8af13b7e480f3e742e33d2';

/// See also [recordsByPerson].
@ProviderFor(recordsByPerson)
const recordsByPersonProvider = RecordsByPersonFamily();

/// See also [recordsByPerson].
class RecordsByPersonFamily extends Family<AsyncValue<List<MoneyRecord>>> {
  /// See also [recordsByPerson].
  const RecordsByPersonFamily();

  /// See also [recordsByPerson].
  RecordsByPersonProvider call(
    int personId,
  ) {
    return RecordsByPersonProvider(
      personId,
    );
  }

  @override
  RecordsByPersonProvider getProviderOverride(
    covariant RecordsByPersonProvider provider,
  ) {
    return call(
      provider.personId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'recordsByPersonProvider';
}

/// See also [recordsByPerson].
class RecordsByPersonProvider
    extends AutoDisposeStreamProvider<List<MoneyRecord>> {
  /// See also [recordsByPerson].
  RecordsByPersonProvider(
    int personId,
  ) : this._internal(
          (ref) => recordsByPerson(
            ref as RecordsByPersonRef,
            personId,
          ),
          from: recordsByPersonProvider,
          name: r'recordsByPersonProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$recordsByPersonHash,
          dependencies: RecordsByPersonFamily._dependencies,
          allTransitiveDependencies:
              RecordsByPersonFamily._allTransitiveDependencies,
          personId: personId,
        );

  RecordsByPersonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.personId,
  }) : super.internal();

  final int personId;

  @override
  Override overrideWith(
    Stream<List<MoneyRecord>> Function(RecordsByPersonRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RecordsByPersonProvider._internal(
        (ref) => create(ref as RecordsByPersonRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        personId: personId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<MoneyRecord>> createElement() {
    return _RecordsByPersonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RecordsByPersonProvider && other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RecordsByPersonRef on AutoDisposeStreamProviderRef<List<MoneyRecord>> {
  /// The parameter `personId` of this provider.
  int get personId;
}

class _RecordsByPersonProviderElement
    extends AutoDisposeStreamProviderElement<List<MoneyRecord>>
    with RecordsByPersonRef {
  _RecordsByPersonProviderElement(super.provider);

  @override
  int get personId => (origin as RecordsByPersonProvider).personId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
