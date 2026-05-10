import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../domain/money_model.dart';
import '../../promises/domain/promise_enums.dart';
import 'money_provider.dart';
import '../../../core/theme/app_colors.dart';

class MoneyScreen extends ConsumerWidget {
  const MoneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(allMoneyRecordsProvider);

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'I Owe'),
              Tab(text: 'Owed to Me'),
              Tab(text: 'Settled'),
            ],
          ),
          Expanded(
            child: recordsAsync.when(
              data: (records) {
                return TabBarView(
                  children: [
                    _RecordList(records: records),
                    _RecordList(records: records.where((r) => r.iOwe && r.status != MoneyStatus.paid).toList()),
                    _RecordList(records: records.where((r) => !r.iOwe && r.status != MoneyStatus.paid).toList()),
                    _RecordList(records: records.where((r) => r.status == MoneyStatus.paid).toList()),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordList extends ConsumerWidget {
  final List<MoneyRecord> records;

  const _RecordList({required this.records});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (records.isEmpty) {
      return const Center(child: Text('No records found'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final record = records[index];
        return _RecordCard(record: record);
      },
    );
  }
}

class _RecordCard extends ConsumerWidget {
  final MoneyRecord record;

  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = record.dueDate != null && record.dueDate!.isBefore(DateTime.now()) && record.status != MoneyStatus.paid;

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              await ref.read(moneyRepositoryProvider).deleteRecord(record.id);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      startActionPane: record.status != MoneyStatus.paid ? ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async {
              final updated = record..status = MoneyStatus.paid;
              await ref.read(moneyRepositoryProvider).saveRecord(updated);
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Settled',
          ),
        ],
      ) : null,
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: record.iOwe ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
            child: Icon(
              record.iOwe ? Icons.trending_down : Icons.trending_up,
              color: record.iOwe ? Colors.red : Colors.green,
            ),
          ),
          title: Text('${record.currency} ${record.amount}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(record.iOwe ? 'I Owe' : 'They Owe Me'),
              if (record.description != null) Text(record.description!),
              if (record.dueDate != null)
                Text(
                  'Due: ${DateFormat('MMM dd').format(record.dueDate!)}',
                  style: TextStyle(color: isOverdue ? AppColors.overdue : null),
                ),
            ],
          ),
          trailing: _StatusChip(status: record.status, isOverdue: isOverdue),
          onTap: () => context.push('/money/${record.id}'),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final MoneyStatus status;
  final bool isOverdue;

  const _StatusChip({required this.status, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.grey;
    String label = status.name.toUpperCase();

    if (isOverdue) {
      color = AppColors.overdue;
      label = 'OVERDUE';
    } else {
      switch (status) {
        case MoneyStatus.pending:
          color = AppColors.pending;
          break;
        case MoneyStatus.paid:
          color = AppColors.complete;
          break;
        case MoneyStatus.partial:
          color = Colors.blue;
          break;
        default:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
