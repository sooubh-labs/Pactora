import 'package:isar/isar.dart';
import 'promise_enums.dart';

part 'promise_model.g.dart';

@collection
class Promise {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String title;

  String? description;
  late int personId; // FK to Person

  @enumerated
  late PromiseType type;

  @enumerated
  late PromiseStatus status;

  @enumerated
  late PromiseCategory category;

  @enumerated
  late Priority priority;

  DateTime? dueDate;
  DateTime? dueTime;
  DateTime? completedAt;
  late DateTime createdAt;

  String? notes;
  List<String> attachmentPaths = [];

  // Reminder config stored as JSON string
  String? reminderConfigJson;

  // Who made promise — direction
  late bool iMadeThisPromise; // true = I promised; false = they promised me

  bool isArchived = false;

  @enumerated
  RecurrenceType recurrence = RecurrenceType.none;

  int? parentPromiseId; // If this is an instance of a recurring promise

  Promise() {
    createdAt = DateTime.now();
    status = PromiseStatus.pending;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'personId': personId,
        'type': type.index,
        'status': status.index,
        'category': category.index,
        'priority': priority.index,
        'dueDate': dueDate?.toIso8601String(),
        'dueTime': dueTime?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'notes': notes,
        'attachmentPaths': attachmentPaths,
        'reminderConfigJson': reminderConfigJson,
        'iMadeThisPromise': iMadeThisPromise,
        'isArchived': isArchived,
        'recurrence': recurrence.index,
        'parentPromiseId': parentPromiseId,
      };

  factory Promise.fromJson(Map<String, dynamic> json) => Promise()
    ..id = json['id'] as int
    ..title = json['title'] as String
    ..description = json['description'] as String?
    ..personId = json['personId'] as int
    ..type = PromiseType.values[json['type'] as int]
    ..status = PromiseStatus.values[json['status'] as int]
    ..category = PromiseCategory.values[json['category'] as int]
    ..priority = Priority.values[json['priority'] as int]
    ..dueDate = json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null
    ..dueTime = json['dueTime'] != null ? DateTime.parse(json['dueTime'] as String) : null
    ..completedAt = json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null
    ..createdAt = DateTime.parse(json['createdAt'] as String)
    ..notes = json['notes'] as String?
    ..attachmentPaths = (json['attachmentPaths'] as List).cast<String>()
    ..reminderConfigJson = json['reminderConfigJson'] as String?
    ..iMadeThisPromise = json['iMadeThisPromise'] as bool
    ..isArchived = json['isArchived'] as bool? ?? false
    ..recurrence = json['recurrence'] != null ? RecurrenceType.values[json['recurrence'] as int] : RecurrenceType.none
    ..parentPromiseId = json['parentPromiseId'] as int?;
}
