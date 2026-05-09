// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$personRepositoryHash() => r'329daa225d9565e12c5e5a6dedac671f983ee374';

/// See also [personRepository].
@ProviderFor(personRepository)
final personRepositoryProvider = AutoDisposeProvider<PersonRepository>.internal(
  personRepository,
  name: r'personRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$personRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PersonRepositoryRef = AutoDisposeProviderRef<PersonRepository>;
String _$allPeopleHash() => r'8fa4c50ea84b1f37219e43bd7977b59f18a08b29';

/// See also [allPeople].
@ProviderFor(allPeople)
final allPeopleProvider = AutoDisposeStreamProvider<List<Person>>.internal(
  allPeople,
  name: r'allPeopleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allPeopleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllPeopleRef = AutoDisposeStreamProviderRef<List<Person>>;
String _$searchedPeopleHash() => r'5b6f8f2a78350e58b07c296bf9e14ff712ee4f3e';

/// See also [searchedPeople].
@ProviderFor(searchedPeople)
final searchedPeopleProvider = AutoDisposeFutureProvider<List<Person>>.internal(
  searchedPeople,
  name: r'searchedPeopleProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchedPeopleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SearchedPeopleRef = AutoDisposeFutureProviderRef<List<Person>>;
String _$personDetailHash() => r'd4a9577fcc0aea947928d6b25fe24ad25dea98cd';

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

/// See also [personDetail].
@ProviderFor(personDetail)
const personDetailProvider = PersonDetailFamily();

/// See also [personDetail].
class PersonDetailFamily extends Family<AsyncValue<Person?>> {
  /// See also [personDetail].
  const PersonDetailFamily();

  /// See also [personDetail].
  PersonDetailProvider call(
    int id,
  ) {
    return PersonDetailProvider(
      id,
    );
  }

  @override
  PersonDetailProvider getProviderOverride(
    covariant PersonDetailProvider provider,
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
  String? get name => r'personDetailProvider';
}

/// See also [personDetail].
class PersonDetailProvider extends AutoDisposeFutureProvider<Person?> {
  /// See also [personDetail].
  PersonDetailProvider(
    int id,
  ) : this._internal(
          (ref) => personDetail(
            ref as PersonDetailRef,
            id,
          ),
          from: personDetailProvider,
          name: r'personDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$personDetailHash,
          dependencies: PersonDetailFamily._dependencies,
          allTransitiveDependencies:
              PersonDetailFamily._allTransitiveDependencies,
          id: id,
        );

  PersonDetailProvider._internal(
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
    FutureOr<Person?> Function(PersonDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PersonDetailProvider._internal(
        (ref) => create(ref as PersonDetailRef),
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
  AutoDisposeFutureProviderElement<Person?> createElement() {
    return _PersonDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PersonDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PersonDetailRef on AutoDisposeFutureProviderRef<Person?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _PersonDetailProviderElement
    extends AutoDisposeFutureProviderElement<Person?> with PersonDetailRef {
  _PersonDetailProviderElement(super.provider);

  @override
  int get id => (origin as PersonDetailProvider).id;
}

String _$personSearchHash() => r'587abb1e6bdc8d1b2fde0d1aedb3f2c123060a49';

/// See also [PersonSearch].
@ProviderFor(PersonSearch)
final personSearchProvider =
    AutoDisposeNotifierProvider<PersonSearch, String>.internal(
  PersonSearch.new,
  name: r'personSearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$personSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PersonSearch = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
