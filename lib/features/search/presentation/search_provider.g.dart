// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$globalSearchHash() => r'8020c1302f42fa80cdf6c88d13f60b95c356c2e7';

/// See also [globalSearch].
@ProviderFor(globalSearch)
final globalSearchProvider = AutoDisposeFutureProvider<SearchResults>.internal(
  globalSearch,
  name: r'globalSearchProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$globalSearchHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GlobalSearchRef = AutoDisposeFutureProviderRef<SearchResults>;
String _$searchQueryHash() => r'32848c18dd36b350439a45fa6338bf2df6758978';

/// See also [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
  SearchQuery.new,
  name: r'searchQueryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchQuery = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
