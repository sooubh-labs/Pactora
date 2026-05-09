import 'package:isar/isar.dart';
import '../../promises/domain/promise_enums.dart';

part 'item_model.g.dart';

@collection
class BorrowItem {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  String? photoPath;
  late int personId;
  late bool iLent; // true = I lent; false = I borrowed

  @enumerated
  late ItemStatus status;

  String? condition; // good, fair, damaged
  double? estimatedValue;
  DateTime? handoverDate;
  DateTime? expectedReturn;
  String? notes;
  late DateTime createdAt;

  bool isArchived = false;

  BorrowItem() {
    createdAt = DateTime.now();
    status = ItemStatus.active;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'photoPath': photoPath,
        'personId': personId,
        'iLent': iLent,
        'status': status.index,
        'condition': condition,
        'estimatedValue': estimatedValue,
        'handoverDate': handoverDate?.toIso8601String(),
        'expectedReturn': expectedReturn?.toIso8601String(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'isArchived': isArchived,
      };

  factory BorrowItem.fromJson(Map<String, dynamic> json) => BorrowItem()
    ..id = json['id'] as int
    ..name = json['name'] as String
    ..photoPath = json['photoPath'] as String?
    ..personId = json['personId'] as int
    ..iLent = json['iLent'] as bool
    ..status = ItemStatus.values[json['status'] as int]
    ..condition = json['condition'] as String?
    ..estimatedValue = json['estimatedValue'] as double?
    ..handoverDate = json['handoverDate'] != null ? DateTime.parse(json['handoverDate'] as String) : null
    ..expectedReturn = json['expectedReturn'] != null ? DateTime.parse(json['expectedReturn'] as String) : null
    ..notes = json['notes'] as String?
    ..createdAt = DateTime.parse(json['createdAt'] as String)
    ..isArchived = json['isArchived'] as bool? ?? false;
}
