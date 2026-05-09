import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../promises/presentation/promise_provider.dart';
import '../../money/presentation/money_provider.dart';
import '../../promises/domain/promise_enums.dart';

part 'stats_provider.g.dart';

class PactoraStats {
  final int totalPromises;
  final int completedPromises;
  final double completionRate;
  final Map<PromiseCategory, int> categoryDistribution;
  final Map<PromiseStatus, int> statusDistribution;
  final double totalMoneyOwedToMe;
  final double totalMoneyIOwe;

  const PactoraStats({
    required this.totalPromises,
    required this.completedPromises,
    required this.completionRate,
    required this.categoryDistribution,
    required this.statusDistribution,
    required this.totalMoneyOwedToMe,
    required this.totalMoneyIOwe,
  });
}

@riverpod
Future<PactoraStats> pactoraStats(PactoraStatsRef ref) async {
  final promises = await ref.watch(allPromisesProvider.future);
  final records = await ref.watch(allMoneyRecordsProvider.future);

  final totalPromises = promises.length;
  final completedPromises = promises.where((p) => p.status == PromiseStatus.completed).length;
  final completionRate = totalPromises > 0 ? (completedPromises / totalPromises) * 100 : 0.0;

  final categoryDistribution = <PromiseCategory, int>{};
  for (final p in promises) {
    categoryDistribution[p.category] = (categoryDistribution[p.category] ?? 0) + 1;
  }

  final statusDistribution = <PromiseStatus, int>{};
  for (final p in promises) {
    statusDistribution[p.status] = (statusDistribution[p.status] ?? 0) + 1;
  }

  final moneyOwedToMe = records.where((r) => !r.iOwe && r.status != MoneyStatus.paid).fold(0.0, (sum, r) => sum + r.amount);
  final moneyIOwe = records.where((r) => r.iOwe && r.status != MoneyStatus.paid).fold(0.0, (sum, r) => sum + r.amount);

  return PactoraStats(
    totalPromises: totalPromises,
    completedPromises: completedPromises,
    completionRate: completionRate,
    categoryDistribution: categoryDistribution,
    statusDistribution: statusDistribution,
    totalMoneyOwedToMe: moneyOwedToMe,
    totalMoneyIOwe: moneyIOwe,
  );
}
