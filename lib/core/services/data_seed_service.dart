import '../services/isar_service.dart';
import '../../features/people/domain/person_model.dart';
import '../../features/promises/domain/promise_model.dart';
import '../../features/promises/domain/promise_enums.dart';
import '../../features/borrow/domain/item_model.dart';
import '../../features/money/domain/money_model.dart';

class DataSeedService {
  static Future<void> seed() async {
    final db = IsarService.db;
    
    // Check if already seeded or has data
    final count = await db.persons.count();
    if (count > 0) return;

    await db.writeTxn(() async {
      // 1. Seed People
      final sarah = Person()..name = 'Sarah';
      final john = Person()..name = 'John';
      await db.persons.putAll([sarah, john]);

      // 2. Seed Promise
      final promise = Promise()
        ..title = 'Call Sarah about the trip'
        ..personId = sarah.id
        ..category = PromiseCategory.task
        ..priority = Priority.medium
        ..status = PromiseStatus.pending
        ..type = PromiseType.theyPromised
        ..iMadeThisPromise = false
        ..dueDate = DateTime.now().add(const Duration(days: 2));
      await db.promises.put(promise);

      // 3. Seed Borrow
      final borrow = BorrowItem()
        ..name = 'Clean Code Book'
        ..personId = john.id
        ..iLent = true
        ..status = ItemStatus.active
        ..expectedReturn = DateTime.now().add(const Duration(days: 7));
      await db.borrowItems.put(borrow);

      // 4. Seed Money
      final money = MoneyRecord()
        ..description = 'Dinner at Italian Place'
        ..personId = sarah.id
        ..amount = 20.0
        ..currency = 'USD'
        ..iOwe = true
        ..status = MoneyStatus.pending
        ..dueDate = DateTime.now().add(const Duration(days: 1));
      await db.moneyRecords.put(money);
    });
  }
}
