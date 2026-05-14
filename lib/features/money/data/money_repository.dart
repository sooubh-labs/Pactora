import 'package:isar/isar.dart';
import '../domain/money_model.dart';
import '../../../core/services/isar_service.dart';
import '../../../core/services/notification_service.dart';

class MoneyRepository {
  final Isar _db = IsarService.db;

  Stream<List<MoneyRecord>> watchAllRecords() {
    return _db.moneyRecords.filter().isArchivedEqualTo(false).sortByCreatedAtDesc().watch(fireImmediately: true);
  }

  Stream<List<MoneyRecord>> watchArchivedRecords() {
    return _db.moneyRecords.filter().isArchivedEqualTo(true).sortByCreatedAtDesc().watch(fireImmediately: true);
  }

  Future<MoneyRecord?> getRecordById(int id) async {
    return await _db.moneyRecords.get(id);
  }

  Future<void> saveRecord(MoneyRecord record) async {
    await _db.writeTxn(() async {
      await _db.moneyRecords.put(record);
    });
    await NotificationService.scheduleMoneyNotification(record);
  }

  Future<void> deleteRecord(int id) async {
    await _db.writeTxn(() async {
      await _db.moneyRecords.delete(id);
    });
    await NotificationService.cancelMoneyNotification(id);
  }

  Stream<List<MoneyRecord>> watchRecordsByPerson(int personId) {
    return _db.moneyRecords
        .filter()
        .personIdEqualTo(personId)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }
}
