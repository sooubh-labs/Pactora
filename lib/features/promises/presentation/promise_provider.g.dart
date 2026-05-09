// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promise_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$promiseRepositoryHash() => r'ace47561f657288ac40a401cc51a44bbd9851b84';

/// See also [promiseRepository].
@ProviderFor(promiseRepository)
final promiseRepositoryProvider =
    AutoDisposeProvider<PromiseRepository>.internal(
  promiseRepository,
  name: r'promiseRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$promiseRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PromiseRepositoryRef = AutoDisposeProviderRef<PromiseRepository>;
String _$allPromisesHash() => r'c599afe9b56c90bda204f239b3f5a741bd618f8d';

/// See also [allPromises].
@ProviderFor(allPromises)
final allPromisesProvider = AutoDisposeStreamProvider<List<Promise>>.internal(
  allPromises,
  name: r'allPromisesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allPromisesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllPromisesRef = AutoDisposeStreamProviderRef<List<Promise>>;
String _$archivedPromisesHash() => r'67a735e03b8fed6f760fb4ed3b22f09e09390bdf';

/// See also [archivedPromises].
@ProviderFor(archivedPromises)
final archivedPromisesProvider =
    AutoDisposeStreamProvider<List<Promise>>.internal(
  archivedPromises,
  name: r'archivedPromisesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$archivedPromisesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ArchivedPromisesRef = AutoDisposeStreamProviderRef<List<Promise>>;
String _$promisesByPersonHash() => r'e9b11562b49c1f2a5eb139742c69997be581c347';

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

/// See also [promisesByPerson].
@ProviderFor(promisesByPerson)
const promisesByPersonProvider = PromisesByPersonFamily();

/// See also [promisesByPerson].
class PromisesByPersonFamily extends Family<AsyncValue<List<Promise>>> {
  /// See also [promisesByPerson].
  const PromisesByPersonFamily();

  /// See also [promisesByPerson].
  PromisesByPersonProvider call(
    int personId,
  ) {
    return PromisesByPersonProvider(
      personId,
    );
  }

  @override
  PromisesByPersonProvider getProviderOverride(
    covariant PromisesByPersonProvider provider,
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
  String? get name => r'promisesByPersonProvider';
}

/// See also [promisesByPerson].
class PromisesByPersonProvider
    extends AutoDisposeStreamProvider<List<Promise>> {
  /// See also [promisesByPerson].
  PromisesByPersonProvider(
    int personId,
  ) : this._internal(
          (ref) => promisesByPerson(
            ref as PromisesByPersonRef,
            personId,
          ),
          from: promisesByPersonProvider,
          name: r'promisesByPersonProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$promisesByPersonHash,
          dependencies: PromisesByPersonFamily._dependencies,
          allTransitiveDependencies:
              PromisesByPersonFamily._allTransitiveDependencies,
          personId: personId,
        );

  PromisesByPersonProvider._internal(
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
    Stream<List<Promise>> Function(PromisesByPersonRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PromisesByPersonProvider._internal(
        (ref) => create(ref as PromisesByPersonRef),
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
  AutoDisposeStreamProviderElement<List<Promise>> createElement() {
    return _PromisesByPersonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PromisesByPersonProvider && other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PromisesByPersonRef on AutoDisposeStreamProviderRef<List<Promise>> {
  /// The parameter `personId` of this provider.
  int get personId;
}

class _PromisesByPersonProviderElement
    extends AutoDisposeStreamProviderElement<List<Promise>>
    with PromisesByPersonRef {
  _PromisesByPersonProviderElement(super.provider);

  @override
  int get personId => (origin as PromisesByPersonProvider).personId;
}

String _$dueTodayPromisesHash() => r'817c75bef6ec996afa9e8d1c320747cb70d2a4d9';

/// See also [dueTodayPromises].
@ProviderFor(dueTodayPromises)
final dueTodayPromisesProvider =
    AutoDisposeStreamProvider<List<Promise>>.internal(
  dueTodayPromises,
  name: r'dueTodayPromisesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$dueTodayPromisesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DueTodayPromisesRef = AutoDisposeStreamProviderRef<List<Promise>>;
String _$promiseDetailHash() => r'aab678b943093374f86f9d33badbf594285d153c';

/// See also [promiseDetail].
@ProviderFor(promiseDetail)
const promiseDetailProvider = PromiseDetailFamily();

/// See also [promiseDetail].
class PromiseDetailFamily extends Family<AsyncValue<Promise?>> {
  /// See also [promiseDetail].
  const PromiseDetailFamily();

  /// See also [promiseDetail].
  PromiseDetailProvider call(
    int id,
  ) {
    return PromiseDetailProvider(
      id,
    );
  }

  @override
  PromiseDetailProvider getProviderOverride(
    covariant PromiseDetailProvider provider,
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
  String? get name => r'promiseDetailProvider';
}

/// See also [promiseDetail].
class PromiseDetailProvider extends AutoDisposeFutureProvider<Promise?> {
  /// See also [promiseDetail].
  PromiseDetailProvider(
    int id,
  ) : this._internal(
          (ref) => promiseDetail(
            ref as PromiseDetailRef,
            id,
          ),
          from: promiseDetailProvider,
          name: r'promiseDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$promiseDetailHash,
          dependencies: PromiseDetailFamily._dependencies,
          allTransitiveDependencies:
              PromiseDetailFamily._allTransitiveDependencies,
          id: id,
        );

  PromiseDetailProvider._internal(
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
    FutureOr<Promise?> Function(PromiseDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PromiseDetailProvider._internal(
        (ref) => create(ref as PromiseDetailRef),
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
  AutoDisposeFutureProviderElement<Promise?> createElement() {
    return _PromiseDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PromiseDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PromiseDetailRef on AutoDisposeFutureProviderRef<Promise?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _PromiseDetailProviderElement
    extends AutoDisposeFutureProviderElement<Promise?> with PromiseDetailRef {
  _PromiseDetailProviderElement(super.provider);

  @override
  int get id => (origin as PromiseDetailProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
