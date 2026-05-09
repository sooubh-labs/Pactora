import 'package:isar/isar.dart';
import '../domain/item_model.dart';
import '../../../core/services/isar_service.dart';

class ItemRepository {
  final Isar _db = IsarService.db;

  Stream<List<BorrowItem>> watchAllItems() {
    return _db.borrowItems.filter().isArchivedEqualTo(false).sortByCreatedAtDesc().watch(fireImmediately: true);
  }

  Stream<List<BorrowItem>> watchArchivedItems() {
    return _db.borrowItems.filter().isArchivedEqualTo(true).sortByCreatedAtDesc().watch(fireImmediately: true);
  }

  Future<BorrowItem?> getItemById(int id) async {
    return await _db.borrowItems.get(id);
  }

  Future<void> saveItem(BorrowItem item) async {
    await _db.writeTxn(() async {
      await _db.borrowItems.put(item);
    });
  }

  Future<void> deleteItem(int id) async {
    await _db.writeTxn(() async {
      await _db.borrowItems.delete(id);
    });
  }

  Stream<List<BorrowItem>> watchItemsByPerson(int personId) {
    return _db.borrowItems
        .filter()
        .personIdEqualTo(personId)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }
}
