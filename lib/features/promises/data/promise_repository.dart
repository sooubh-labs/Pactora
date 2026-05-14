import 'package:isar/isar.dart';
import '../domain/promise_model.dart';
import '../domain/promise_enums.dart';
import '../../../core/services/isar_service.dart';
import '../../../core/services/notification_service.dart';

class PromiseRepository {
  final Isar _db = IsarService.db;

  Stream<List<Promise>> watchAllPromises() {
    return _db.promises.filter().isArchivedEqualTo(false).sortByDueDate().watch(fireImmediately: true);
  }

  Stream<List<Promise>> watchArchivedPromises() {
    return _db.promises.filter().isArchivedEqualTo(true).sortByDueDate().watch(fireImmediately: true);
  }

  Future<Promise?> getPromiseById(int id) async {
    return await _db.promises.get(id);
  }

  Future<void> savePromise(Promise promise) async {
    await _db.writeTxn(() async {
      await _db.promises.put(promise);
    });
    await NotificationService.schedulePromiseNotification(promise);
  }

  Future<void> completePromise(Promise promise) async {
    Promise? nextPromise;
    await _db.writeTxn(() async {
      promise.status = PromiseStatus.completed;
      promise.completedAt = DateTime.now();
      await _db.promises.put(promise);

      if (promise.recurrence != RecurrenceType.none && promise.dueDate != null) {
        nextPromise = Promise()
          ..title = promise.title
          ..description = promise.description
          ..personId = promise.personId
          ..type = promise.type
          ..category = promise.category
          ..priority = promise.priority
          ..iMadeThisPromise = promise.iMadeThisPromise
          ..recurrence = promise.recurrence
          ..parentPromiseId = promise.id
          ..dueDate = _calculateNextDueDate(promise.dueDate!, promise.recurrence);
        
        await _db.promises.put(nextPromise!);
      }
    });

    await NotificationService.cancelPromiseNotification(promise.id);
    if (nextPromise != null) {
      await NotificationService.schedulePromiseNotification(nextPromise!);
    }
  }

  DateTime _calculateNextDueDate(DateTime current, RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return current.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        return current.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        return DateTime(current.year, current.month + 1, current.day);
      case RecurrenceType.yearly:
        return DateTime(current.year + 1, current.month, current.day);
      case RecurrenceType.none:
        return current;
    }
  }

  Future<void> deletePromise(int id) async {
    await _db.writeTxn(() async {
      await _db.promises.delete(id);
    });
    await NotificationService.cancelPromiseNotification(id);
  }

  Stream<List<Promise>> watchPromisesByPerson(int personId) {
    return _db.promises
        .filter()
        .personIdEqualTo(personId)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }

  Stream<List<Promise>> watchPromisesInRange(DateTime start, DateTime end) {
    return _db.promises
        .filter()
        .dueDateBetween(start, end)
        .statusEqualTo(PromiseStatus.pending)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }
}
