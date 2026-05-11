import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:table_calendar/table_calendar.dart';
import '../domain/money_model.dart';
import '../../promises/domain/promise_enums.dart';
import 'money_provider.dart';
import '../../../core/theme/app_colors.dart';

class MoneyScreen extends ConsumerWidget {
  final DateTime? selectedDate;
  const MoneyScreen({super.key, this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(allMoneyRecordsProvider);

    return recordsAsync.when(
      data: (allRecords) {
        final records = selectedDate == null 
          ? allRecords 
          : allRecords.where((r) => r.dueDate != null && isSameDay(r.dueDate, selectedDate)).toList();

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
    );
  }
}

class _RecordList extends ConsumerWidget {
  final List<MoneyRecord> records;

  const _RecordList({required this.records});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments_outlined, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No money records found', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: records.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
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
    final color = record.iOwe ? AppColors.error : AppColors.success;

    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              await ref.read(moneyRepositoryProvider).deleteRecord(record.id);
            },
            backgroundColor: AppColors.error.withOpacity(0.1),
            foregroundColor: AppColors.error,
            child: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      startActionPane: record.status != MoneyStatus.paid ? ActionPane(
        extentRatio: 0.25,
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              final updated = record..status = MoneyStatus.paid;
              await ref.read(moneyRepositoryProvider).saveRecord(updated);
            },
            backgroundColor: AppColors.success.withOpacity(0.1),
            foregroundColor: AppColors.success,
            child: const Icon(Icons.check_rounded),
          ),
        ],
      ) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.black.withOpacity(0.04)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              record.iOwe ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color,
              size: 24,
            ),
          ),
          title: Text(
            '${record.currency} ${record.amount}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                record.iOwe ? 'I Owe' : 'They Owe Me',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
              ),
              if (record.description != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    record.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
    Color color = AppColors.textTertiary;
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
          label = 'PAID';
          break;
        case MoneyStatus.partial:
          color = AppColors.info;
          label = 'PARTIAL';
          break;
        default:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color, 
          fontSize: 10, 
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
