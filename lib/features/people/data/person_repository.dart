import 'package:isar/isar.dart';
import '../domain/person_model.dart';
import '../../../core/services/isar_service.dart';

class PersonRepository {
  final Isar _db = IsarService.db;

  Stream<List<Person>> watchAllPeople() {
    return _db.persons.where().sortByName().watch(fireImmediately: true);
  }

  Future<List<Person>> getAllPeople() async {
    return await _db.persons.where().sortByName().findAll();
  }

  Future<Person?> getPersonById(int id) async {
    return await _db.persons.get(id);
  }

  Future<int> savePerson(Person person) async {
    return await _db.writeTxn(() async {
      return await _db.persons.put(person);
    });
  }

  Future<void> deletePerson(int id) async {
    await _db.writeTxn(() async {
      await _db.persons.delete(id);
    });
  }

  Future<List<Person>> searchPeople(String query) async {
    return await _db.persons
        .filter()
        .nameContains(query, caseSensitive: false)
        .sortByName()
        .findAll();
  }
}
