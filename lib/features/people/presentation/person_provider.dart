import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/person_model.dart';
import '../data/person_repository.dart';

part 'person_provider.g.dart';

@riverpod
PersonRepository personRepository(PersonRepositoryRef ref) {
  return PersonRepository();
}

@riverpod
Stream<List<Person>> allPeople(AllPeopleRef ref) {
  return ref.watch(personRepositoryProvider).watchAllPeople();
}

@riverpod
class PersonSearch extends _$PersonSearch {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

@riverpod
Future<List<Person>> searchedPeople(SearchedPeopleRef ref) async {
  final query = ref.watch(personSearchProvider);
  if (query.isEmpty) {
    return [];
  }
  return ref.watch(personRepositoryProvider).searchPeople(query);
}

@riverpod
Future<Person?> personDetail(PersonDetailRef ref, int id) {
  return ref.watch(personRepositoryProvider).getPersonById(id);
}
