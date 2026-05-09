import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/money_model.dart';
import '../data/money_repository.dart';

part 'money_provider.g.dart';

@riverpod
MoneyRepository moneyRepository(MoneyRepositoryRef ref) {
  return MoneyRepository();
}

@riverpod
Stream<List<MoneyRecord>> allMoneyRecords(AllMoneyRecordsRef ref) {
  return ref.watch(moneyRepositoryProvider).watchAllRecords();
}

@riverpod
Stream<List<MoneyRecord>> archivedMoneyRecords(ArchivedMoneyRecordsRef ref) {
  return ref.watch(moneyRepositoryProvider).watchArchivedRecords();
}

@riverpod
Future<MoneyRecord?> moneyRecordDetail(MoneyRecordDetailRef ref, int id) {
  return ref.watch(moneyRepositoryProvider).getRecordById(id);
}

@riverpod
Stream<List<MoneyRecord>> recordsByPerson(RecordsByPersonRef ref, int personId) {
  return ref.watch(moneyRepositoryProvider).watchRecordsByPerson(personId);
}
