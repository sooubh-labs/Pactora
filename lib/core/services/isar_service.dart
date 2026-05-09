import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/people/domain/person_model.dart';
import '../../features/promises/domain/promise_model.dart';
import '../../features/borrow/domain/item_model.dart';
import '../../features/money/domain/money_model.dart';

class IsarService {
  static late Isar _isar;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [
        PersonSchema,
        PromiseSchema,
        BorrowItemSchema,
        MoneyRecordSchema,
      ],
      directory: dir.path,
    );
    _initialized = true;
  }

  static Isar get db => _isar;
}
