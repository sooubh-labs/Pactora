import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/promise_model.dart';
import '../data/promise_repository.dart';

part 'promise_provider.g.dart';

@riverpod
PromiseRepository promiseRepository(PromiseRepositoryRef ref) {
  return PromiseRepository();
}

@riverpod
Stream<List<Promise>> allPromises(AllPromisesRef ref) {
  return ref.watch(promiseRepositoryProvider).watchAllPromises();
}

@riverpod
Stream<List<Promise>> archivedPromises(ArchivedPromisesRef ref) {
  return ref.watch(promiseRepositoryProvider).watchArchivedPromises();
}

@riverpod
Stream<List<Promise>> promisesByPerson(PromisesByPersonRef ref, int personId) {
  return ref.watch(promiseRepositoryProvider).watchPromisesByPerson(personId);
}

@riverpod
Stream<List<Promise>> dueTodayPromises(DueTodayPromisesRef ref) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  return ref.watch(promiseRepositoryProvider).watchPromisesInRange(startOfDay, endOfDay);
}

@riverpod
Future<Promise?> promiseDetail(PromiseDetailRef ref, int id) {
  return ref.watch(promiseRepositoryProvider).getPromiseById(id);
}
