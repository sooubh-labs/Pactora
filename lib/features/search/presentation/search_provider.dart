import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../promises/domain/promise_model.dart';
import '../../borrow/domain/item_model.dart';
import '../../money/domain/money_model.dart';
import '../../people/domain/person_model.dart';
import '../../../core/services/isar_service.dart';
import 'package:isar/isar.dart';

part 'search_provider.g.dart';

class SearchResults {
  final List<Promise> promises;
  final List<BorrowItem> items;
  final List<MoneyRecord> records;
  final List<Person> people;

  const SearchResults({
    required this.promises,
    required this.items,
    required this.records,
    required this.people,
  });

  bool get isEmpty => promises.isEmpty && items.isEmpty && records.isEmpty && people.isEmpty;
}

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

@riverpod
Future<SearchResults> globalSearch(GlobalSearchRef ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) {
    return const SearchResults(promises: [], items: [], records: [], people: []);
  }

  final db = IsarService.db;
  
  final promises = await db.promises.filter()
      .titleContains(query, caseSensitive: false)
      .or()
      .descriptionContains(query, caseSensitive: false)
      .findAll();

  final items = await db.borrowItems.filter()
      .nameContains(query, caseSensitive: false)
      .or()
      .notesContains(query, caseSensitive: false)
      .findAll();

  final records = await db.moneyRecords.filter()
      .descriptionContains(query, caseSensitive: false)
      .findAll();

  final people = await db.persons.filter()
      .nameContains(query, caseSensitive: false)
      .findAll();

  return SearchResults(
    promises: promises,
    items: items,
    records: records,
    people: people,
  );
}
