import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../promises/presentation/promise_provider.dart';
import '../../borrow/presentation/item_provider.dart';
import '../../money/presentation/money_provider.dart';
import '../../promises/domain/promise_enums.dart';

part 'dashboard_provider.g.dart';

enum ActivityType { promise, borrow, money }

class ActivityItemData {
  final int id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime date;
  final bool isCompleted;

  const ActivityItemData({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.isCompleted,
  });
}

class DashboardSummary {
  final int pendingPromises;
  final int overduePromises;
  final int activeBorrows;
  final double moneyOwedToMe;
  final double moneyIOwe;
  final List<ActivityItemData> recentActivity;

  const DashboardSummary({
    required this.pendingPromises,
    required this.overduePromises,
    required this.activeBorrows,
    required this.moneyOwedToMe,
    required this.moneyIOwe,
    required this.recentActivity,
  });
}

@riverpod
Future<DashboardSummary> dashboardSummary(DashboardSummaryRef ref) async {
  final promises = await ref.watch(allPromisesProvider.future);
  final items = await ref.watch(allItemsProvider.future);
  final records = await ref.watch(allMoneyRecordsProvider.future);

  final now = DateTime.now();

  List<ActivityItemData> activityList = [];

  // Add Promises
  for (var p in promises) {
    activityList.add(ActivityItemData(
      id: p.id,
      type: ActivityType.promise,
      title: p.title,
      subtitle: p.status == PromiseStatus.completed ? 'Completed' : (p.dueDate != null ? 'Due: \${p.dueDate!.toLocal().toString().split(' ')[0]}' : 'No Date'),
      date: p.dueDate ?? p.createdAt,
      isCompleted: p.status == PromiseStatus.completed,
    ));
  }

  // Add Borrow Items
  for (var i in items) {
    activityList.add(ActivityItemData(
      id: i.id,
      type: ActivityType.borrow,
      title: 'Borrowed: \${i.name}',
      subtitle: i.status == ItemStatus.returned ? 'Returned' : (i.expectedReturn != null ? 'Due: \${i.expectedReturn!.toLocal().toString().split(' ')[0]}' : 'Active'),
      date: i.expectedReturn ?? i.createdAt,
      isCompleted: i.status == ItemStatus.returned,
    ));
  }

  // Add Money Records
  for (var r in records) {
    activityList.add(ActivityItemData(
      id: r.id,
      type: ActivityType.money,
      title: r.description?.isNotEmpty == true ? r.description! : (r.iOwe ? 'I owe money' : 'Owed to me'),
      subtitle: r.status == MoneyStatus.paid ? 'Settled' : 'Amount: \$\${r.amount.toStringAsFixed(0)}',
      date: r.dueDate ?? r.createdAt,
      isCompleted: r.status == MoneyStatus.paid,
    ));
  }

  // Sort by date (closest to now or most recently created)
  activityList.sort((a, b) => b.date.compareTo(a.date));

  return DashboardSummary(
    pendingPromises: promises.where((p) => p.status == PromiseStatus.pending).length,
    overduePromises: promises.where((p) => p.status == PromiseStatus.pending && p.dueDate != null && p.dueDate!.isBefore(now)).length,
    activeBorrows: items.where((i) => i.status == ItemStatus.active).length,
    moneyOwedToMe: records.where((r) => !r.iOwe && r.status != MoneyStatus.paid).fold(0.0, (sum, r) => sum + r.amount),
    moneyIOwe: records.where((r) => r.iOwe && r.status != MoneyStatus.paid).fold(0.0, (sum, r) => sum + r.amount),
    recentActivity: activityList.take(5).toList(), // Show only top 5 recent
  );
}
