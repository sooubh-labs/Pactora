import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/item_model.dart';
import '../data/item_repository.dart';

part 'item_provider.g.dart';

@riverpod
ItemRepository itemRepository(ItemRepositoryRef ref) {
  return ItemRepository();
}

@riverpod
Stream<List<BorrowItem>> allItems(AllItemsRef ref) {
  return ref.watch(itemRepositoryProvider).watchAllItems();
}

@riverpod
Stream<List<BorrowItem>> archivedItems(ArchivedItemsRef ref) {
  return ref.watch(itemRepositoryProvider).watchArchivedItems();
}

@riverpod
Future<BorrowItem?> borrowItemDetail(BorrowItemDetailRef ref, int id) {
  return ref.watch(itemRepositoryProvider).getItemById(id);
}

@riverpod
Stream<List<BorrowItem>> itemsByPerson(ItemsByPersonRef ref, int personId) {
  // Add watch method to ItemRepository first
  return ref.watch(itemRepositoryProvider).watchItemsByPerson(personId);
}
