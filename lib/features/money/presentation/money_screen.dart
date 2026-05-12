import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
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

        final owedToMe = records.where((r) => !r.iOwe && r.status != MoneyStatus.paid).fold(0.0, (sum, r) => sum + r.amount);
        final iOwe = records.where((r) => r.iOwe && r.status != MoneyStatus.paid).fold(0.0, (sum, r) => sum + r.amount);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCards(owedToMe, iOwe),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                    child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _RecordList(records: records),
              const SizedBox(height: 140), // padding for floating nav
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildSummaryCards(double owedToMe, double iOwe) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0F0), // Very light red
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.overdueText.withOpacity(0.1),
                      child: const Icon(Icons.arrow_upward_rounded, size: 16, color: AppColors.overdueText),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'I Owe',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '\$${iOwe.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF), // Very light blue
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.pendingText.withOpacity(0.1),
                      child: const Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.pendingText),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Owed to Me',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '\$${owedToMe.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payments_outlined, size: 48, color: AppColors.textTertiary.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('No money records found', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      );
    }

    return Column(
      children: records.map((record) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _RecordCard(record: record),
      )).toList(),
    );
  }
}

class _RecordCard extends ConsumerWidget {
  final MoneyRecord record;

  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue = record.dueDate != null && record.dueDate!.isBefore(DateTime.now()) && record.status != MoneyStatus.paid;
    
    // Determine card accent and background based on status
    Color accentColor = AppColors.pendingText; // Blue default
    Color iconBgColor = AppColors.pendingBg;
    if (record.status == MoneyStatus.paid) {
      accentColor = AppColors.doneText;
      iconBgColor = AppColors.doneBg;
    } else if (isOverdue || record.iOwe) {
      accentColor = AppColors.overdueText;
      iconBgColor = AppColors.overdueBg;
    }

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
            borderRadius: BorderRadius.circular(32),
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
            borderRadius: BorderRadius.circular(32),
            child: const Icon(Icons.check_rounded),
          ),
        ],
      ) : null,
      child: GestureDetector(
        onTap: () => context.push('/money/${record.id}'),
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Left Accent Border
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    bottomLeft: Radius.circular(32),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      // Avatar mock (initials)
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: iconBgColor,
                        child: Text(
                          'MT', // Mock initials
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Mike Thompson', // Mock person name
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: record.status == MoneyStatus.paid ? AppColors.textSecondary : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              record.description ?? 'No description',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${record.iOwe ? '-' : '+'}\$${record.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _StatusChip(status: record.status, isOverdue: isOverdue),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
    Color textColor = AppColors.pendingText;
    Color bgColor = AppColors.pendingBg;
    String label = status.name.toUpperCase();

    if (isOverdue) {
      textColor = AppColors.overdueText;
      bgColor = AppColors.overdueBg;
      label = 'OVERDUE';
    } else {
      switch (status) {
        case MoneyStatus.pending:
          textColor = AppColors.pendingText;
          bgColor = AppColors.pendingBg;
          break;
        case MoneyStatus.paid:
          textColor = AppColors.doneText;
          bgColor = AppColors.doneBg;
          label = 'SETTLED';
          break;
        case MoneyStatus.partial:
          textColor = AppColors.primaryLight;
          bgColor = AppColors.primaryLight.withOpacity(0.1);
          label = 'PARTIAL';
          break;
        default:
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor, 
          fontSize: 9, 
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
