import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../promises/presentation/promise_provider.dart';
import '../../borrow/presentation/item_provider.dart';
import '../../money/presentation/money_provider.dart';
import '../../promises/domain/promise_enums.dart';

part 'dashboard_provider.g.dart';

class DashboardSummary {
  final int pendingPromises;
  final int overduePromises;
  final int activeBorrows;
  final double moneyOwedToMe;
  final double moneyIOwe;

  const DashboardSummary({
    required this.pendingPromises,
    required this.overduePromises,
    required this.activeBorrows,
    required this.moneyOwedToMe,
    required this.moneyIOwe,
  });
}

@riverpod
Future<DashboardSummary> dashboardSummary(DashboardSummaryRef ref) async {
  final promises = await ref.watch(allPromisesProvider.future);
  final items = await ref.watch(allItemsProvider.future);
  final records = await ref.watch(allMoneyRecordsProvider.future);

  final now = DateTime.now();

  return DashboardSummary(
    pendingPromises: promises.where((p) => p.status == PromiseStatus.pending).length,
    overduePromises: promises.where((p) => p.status == PromiseStatus.pending && p.dueDate != null && p.dueDate!.isBefore(now)).length,
    activeBorrows: items.where((i) => i.status == ItemStatus.active).length,
    moneyOwedToMe: records.where((r) => !r.iOwe && r.status != MoneyStatus.paid).fold(0.0, (sum, r) => sum + r.amount),
    moneyIOwe: records.where((r) => r.iOwe && r.status != MoneyStatus.paid).fold(0.0, (sum, r) => sum + r.amount),
  );
}
