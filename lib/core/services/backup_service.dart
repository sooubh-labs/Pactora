import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'isar_service.dart';
import '../../features/people/domain/person_model.dart';
import '../../features/promises/domain/promise_model.dart';
import '../../features/borrow/domain/item_model.dart';
import '../../features/money/domain/money_model.dart';
import 'package:isar/isar.dart';

class BackupService {
  static Future<void> exportBackup() async {
    final db = IsarService.db;

    final people = await db.persons.where().findAll();
    final promises = await db.promises.where().findAll();
    final items = await db.borrowItems.where().findAll();
    final records = await db.moneyRecords.where().findAll();

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'people': people.map((p) => p.toJson()).toList(),
      'promises': promises.map((p) => p.toJson()).toList(),
      'items': items.map((i) => i.toJson()).toList(),
      'records': records.map((r) => r.toJson()).toList(),
    };

    final jsonString = jsonEncode(data);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/pactora_backup.json');
    await file.writeAsString(jsonString);

    await Share.shareXFiles([XFile(file.path)], text: 'Pactora Backup');
  }

  static Future<bool> importBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.single.path == null) return false;

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    if (data['version'] != 1) {
      throw Exception('Unsupported backup version');
    }

    final db = IsarService.db;

    await db.writeTxn(() async {
      // Clear existing data? Or merge? 
      // For now, let's merge/put which will overwrite if IDs match
      
      final people = (data['people'] as List).map((p) => Person.fromJson(p)).toList();
      final promises = (data['promises'] as List).map((p) => Promise.fromJson(p)).toList();
      final items = (data['items'] as List).map((i) => BorrowItem.fromJson(i)).toList();
      final records = (data['records'] as List).map((r) => MoneyRecord.fromJson(r)).toList();

      await db.persons.putAll(people);
      await db.promises.putAll(promises);
      await db.borrowItems.putAll(items);
      await db.moneyRecords.putAll(records);
    });

    return true;
  }
}
