import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import '../domain/money_model.dart';
import '../../promises/domain/promise_enums.dart';
import 'money_provider.dart';
import '../../people/presentation/person_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/person_avatar.dart';

class MoneyRecordDetailScreen extends ConsumerWidget {
  final int id;

  const MoneyRecordDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(moneyRecordDetailProvider(id));

    return recordAsync.when(
      data: (record) {
        if (record == null) {
          return const Scaffold(body: Center(child: Text('Record not found')));
        }

        final personAsync = ref.watch(personDetailProvider(record.personId));
        final isOverdue = record.dueDate != null &&
            record.dueDate!.isBefore(DateTime.now()) &&
            record.status != MoneyStatus.paid;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Transaction Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () => context.push('/money/edit/$id'),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                onPressed: () => _showDeleteDialog(context, ref),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, record, isOverdue),
                const Gap(32),
                _buildSectionTitle(context, 'Details'),
                const Gap(16),
                _buildDetailCard([
                  _DetailRow(
                    icon: Icons.person_outline_rounded,
                    label: record.iOwe ? 'Owed to' : 'Owed by',
                    value: personAsync.when(
                      data: (person) => person?.name ?? 'Unknown',
                      loading: () => '...',
                      error: (_, __) => 'Error',
                    ),
                    trailing: personAsync.when(
                      data: (person) => PersonAvatar(name: person?.name ?? 'U', radius: 14),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Due Date',
                    value: record.dueDate != null
                        ? DateFormat('EEEE, MMM dd, yyyy').format(record.dueDate!)
                        : 'No due date',
                    valueColor: isOverdue ? AppColors.error : null,
                  ),
                  _DetailRow(
                    icon: Icons.info_outline_rounded,
                    label: 'Status',
                    value: record.status.name.toUpperCase(),
                    valueColor: isOverdue ? AppColors.error : AppColors.primary,
                    isLast: true,
                  ),
                ]),
                if (record.description?.isNotEmpty == true) ...[
                  const Gap(32),
                  _buildSectionTitle(context, 'Description'),
                  const Gap(16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      record.description!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
                if (record.photoPath != null) ...[
                  const Gap(32),
                  _buildSectionTitle(context, 'Proof of Transfer'),
                  const Gap(16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      File(record.photoPath!),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                const Gap(48),
                _buildActionButtons(context, ref, record),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
    );
  }

  Widget _buildHeader(BuildContext context, MoneyRecord record, bool isOverdue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StatusBadge(status: record.status, isOverdue: isOverdue),
        const Gap(16),
        Text(
          '${record.iOwe ? '-' : '+'}${record.currency} ${record.amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: record.iOwe ? AppColors.error : AppColors.success,
              ),
        ),
        const Gap(4),
        Text(
          record.iOwe ? 'You owe this amount' : 'This amount is owed to you',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textTertiary,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, MoneyRecord record) {
    return Row(
      children: [
        if (record.status != MoneyStatus.paid)
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () => _markSettled(ref, record),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Mark Settled', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        if (record.status != MoneyStatus.paid) const Gap(12),
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _sendReminder(record, ref),
              icon: const Icon(Icons.share_rounded, size: 20),
              label: const Text('Send Reminder', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _markSettled(WidgetRef ref, MoneyRecord record) async {
    final updated = record..status = MoneyStatus.paid;
    await ref.read(moneyRepositoryProvider).saveRecord(updated);
  }

  void _sendReminder(MoneyRecord record, WidgetRef ref) async {
    final person = await ref.read(personDetailProvider(record.personId).future);
    final name = person?.name ?? 'there';
    final message = 'Hey $name, just a friendly reminder about the ${record.currency} ${record.amount} ${record.iOwe ? 'I owe you' : 'you owe me'} 🙂';
    Share.share(message);
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Record?'),
        content: const Text('Are you sure you want to delete this money record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(moneyRepositoryProvider).deleteRecord(id);
              if (context.mounted) {
                context.pop();
                context.pop();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MoneyStatus status;
  final bool isOverdue;

  const _StatusBadge({required this.status, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.pendingText;
    Color bgColor = AppColors.pendingBg;
    String label = status.name.toUpperCase();

    if (isOverdue) {
      color = AppColors.overdueText;
      bgColor = AppColors.overdueBg;
      label = 'OVERDUE';
    } else {
      switch (status) {
        case MoneyStatus.pending:
          color = AppColors.pendingText;
          bgColor = AppColors.pendingBg;
          break;
        case MoneyStatus.paid:
          color = AppColors.doneText;
          bgColor = AppColors.doneBg;
          label = 'SETTLED';
          break;
        case MoneyStatus.partial:
          color = AppColors.primaryLight;
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final Color? valueColor;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: AppColors.primary.withOpacity(0.6)),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary, fontWeight: FontWeight.w600)),
                    const Gap(2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: valueColor ?? AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, thickness: 0.5, indent: 64),
      ],
    );
  }
}
