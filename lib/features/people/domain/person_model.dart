import 'package:isar/isar.dart';

part 'person_model.g.dart';

@collection
class Person {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  late String name;

  String? phone;
  String? avatarPath;
  String? notes;
  late DateTime createdAt;

  Person() {
    createdAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'avatarPath': avatarPath,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Person.fromJson(Map<String, dynamic> json) => Person()
    ..id = json['id'] as int
    ..name = json['name'] as String
    ..phone = json['phone'] as String?
    ..avatarPath = json['avatarPath'] as String?
    ..notes = json['notes'] as String?
    ..createdAt = DateTime.parse(json['createdAt'] as String);
}
