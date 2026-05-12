import 'package:isar/isar.dart';
import '../../promises/domain/promise_enums.dart';

part 'money_model.g.dart';

@collection
class MoneyRecord {
  Id id = Isar.autoIncrement;

  late int personId;
  late double amount;
  late String currency; // 'INR', 'USD' etc.
  late bool iOwe; // true = I owe them; false = they owe me
  String? photoPath;

  @enumerated
  late MoneyStatus status;

  double paidAmount = 0.0;
  String? description;
  DateTime? dueDate;
  late DateTime createdAt;

  bool isArchived = false;

  MoneyRecord() {
    createdAt = DateTime.now();
    status = MoneyStatus.pending;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'personId': personId,
        'amount': amount,
        'currency': currency,
        'iOwe': iOwe,
        'photoPath': photoPath,
        'status': status.index,
        'paidAmount': paidAmount,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'isArchived': isArchived,
      };

  factory MoneyRecord.fromJson(Map<String, dynamic> json) => MoneyRecord()
    ..id = json['id'] as int
    ..personId = json['personId'] as int
    ..amount = json['amount'] as double
    ..currency = json['currency'] as String
    ..iOwe = json['iOwe'] as bool
    ..photoPath = json['photoPath'] as String?
    ..status = MoneyStatus.values[json['status'] as int]
    ..paidAmount = json['paidAmount'] as double
    ..description = json['description'] as String?
    ..dueDate = json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null
    ..createdAt = DateTime.parse(json['createdAt'] as String)
    ..isArchived = json['isArchived'] as bool? ?? false;
}
