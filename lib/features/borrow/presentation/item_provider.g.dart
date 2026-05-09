// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$itemRepositoryHash() => r'558d682fdf5ed450656eb87877ac00cee3575ced';

/// See also [itemRepository].
@ProviderFor(itemRepository)
final itemRepositoryProvider = AutoDisposeProvider<ItemRepository>.internal(
  itemRepository,
  name: r'itemRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$itemRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ItemRepositoryRef = AutoDisposeProviderRef<ItemRepository>;
String _$allItemsHash() => r'1967908c940d90670a112002bdd7479dc3ff2272';

/// See also [allItems].
@ProviderFor(allItems)
final allItemsProvider = AutoDisposeStreamProvider<List<BorrowItem>>.internal(
  allItems,
  name: r'allItemsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AllItemsRef = AutoDisposeStreamProviderRef<List<BorrowItem>>;
String _$archivedItemsHash() => r'17f1a80772be0620792b505e275f2f6f5f919e4f';

/// See also [archivedItems].
@ProviderFor(archivedItems)
final archivedItemsProvider =
    AutoDisposeStreamProvider<List<BorrowItem>>.internal(
  archivedItems,
  name: r'archivedItemsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$archivedItemsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ArchivedItemsRef = AutoDisposeStreamProviderRef<List<BorrowItem>>;
String _$borrowItemDetailHash() => r'6ea97eb9a186ad852f8fa5d0a247ae1710495ead';

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

/// See also [borrowItemDetail].
@ProviderFor(borrowItemDetail)
const borrowItemDetailProvider = BorrowItemDetailFamily();

/// See also [borrowItemDetail].
class BorrowItemDetailFamily extends Family<AsyncValue<BorrowItem?>> {
  /// See also [borrowItemDetail].
  const BorrowItemDetailFamily();

  /// See also [borrowItemDetail].
  BorrowItemDetailProvider call(
    int id,
  ) {
    return BorrowItemDetailProvider(
      id,
    );
  }

  @override
  BorrowItemDetailProvider getProviderOverride(
    covariant BorrowItemDetailProvider provider,
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
  String? get name => r'borrowItemDetailProvider';
}

/// See also [borrowItemDetail].
class BorrowItemDetailProvider extends AutoDisposeFutureProvider<BorrowItem?> {
  /// See also [borrowItemDetail].
  BorrowItemDetailProvider(
    int id,
  ) : this._internal(
          (ref) => borrowItemDetail(
            ref as BorrowItemDetailRef,
            id,
          ),
          from: borrowItemDetailProvider,
          name: r'borrowItemDetailProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$borrowItemDetailHash,
          dependencies: BorrowItemDetailFamily._dependencies,
          allTransitiveDependencies:
              BorrowItemDetailFamily._allTransitiveDependencies,
          id: id,
        );

  BorrowItemDetailProvider._internal(
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
    FutureOr<BorrowItem?> Function(BorrowItemDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BorrowItemDetailProvider._internal(
        (ref) => create(ref as BorrowItemDetailRef),
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
  AutoDisposeFutureProviderElement<BorrowItem?> createElement() {
    return _BorrowItemDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BorrowItemDetailProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BorrowItemDetailRef on AutoDisposeFutureProviderRef<BorrowItem?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _BorrowItemDetailProviderElement
    extends AutoDisposeFutureProviderElement<BorrowItem?>
    with BorrowItemDetailRef {
  _BorrowItemDetailProviderElement(super.provider);

  @override
  int get id => (origin as BorrowItemDetailProvider).id;
}

String _$itemsByPersonHash() => r'2debab8e3dd31e274317a8f68e816df410be7d45';

/// See also [itemsByPerson].
@ProviderFor(itemsByPerson)
const itemsByPersonProvider = ItemsByPersonFamily();

/// See also [itemsByPerson].
class ItemsByPersonFamily extends Family<AsyncValue<List<BorrowItem>>> {
  /// See also [itemsByPerson].
  const ItemsByPersonFamily();

  /// See also [itemsByPerson].
  ItemsByPersonProvider call(
    int personId,
  ) {
    return ItemsByPersonProvider(
      personId,
    );
  }

  @override
  ItemsByPersonProvider getProviderOverride(
    covariant ItemsByPersonProvider provider,
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
  String? get name => r'itemsByPersonProvider';
}

/// See also [itemsByPerson].
class ItemsByPersonProvider
    extends AutoDisposeStreamProvider<List<BorrowItem>> {
  /// See also [itemsByPerson].
  ItemsByPersonProvider(
    int personId,
  ) : this._internal(
          (ref) => itemsByPerson(
            ref as ItemsByPersonRef,
            personId,
          ),
          from: itemsByPersonProvider,
          name: r'itemsByPersonProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$itemsByPersonHash,
          dependencies: ItemsByPersonFamily._dependencies,
          allTransitiveDependencies:
              ItemsByPersonFamily._allTransitiveDependencies,
          personId: personId,
        );

  ItemsByPersonProvider._internal(
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
    Stream<List<BorrowItem>> Function(ItemsByPersonRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ItemsByPersonProvider._internal(
        (ref) => create(ref as ItemsByPersonRef),
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
  AutoDisposeStreamProviderElement<List<BorrowItem>> createElement() {
    return _ItemsByPersonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemsByPersonProvider && other.personId == personId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, personId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ItemsByPersonRef on AutoDisposeStreamProviderRef<List<BorrowItem>> {
  /// The parameter `personId` of this provider.
  int get personId;
}

class _ItemsByPersonProviderElement
    extends AutoDisposeStreamProviderElement<List<BorrowItem>>
    with ItemsByPersonRef {
  _ItemsByPersonProviderElement(super.provider);

  @override
  int get personId => (origin as ItemsByPersonProvider).personId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
